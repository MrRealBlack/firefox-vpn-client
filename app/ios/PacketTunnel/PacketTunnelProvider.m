#import "PacketTunnelProvider.h"
#import <Core/Mobile.objc.h>
#import <stdatomic.h>
#import <sys/socket.h>

@implementation PacketTunnelProvider {
    atomic_bool _stopping;
    atomic_uint _generation;
    dispatch_queue_t _coreQueue;
    dispatch_queue_t _outputQueue;
    dispatch_source_t _healthTimer;
}

- (instancetype)init {
    if ((self = [super init])) {
        atomic_init(&_stopping, true);
        atomic_init(&_generation, 0);
        _coreQueue = dispatch_queue_create("vpn.core.lifecycle", DISPATCH_QUEUE_SERIAL);
        _outputQueue = dispatch_queue_create("vpn.core.packets", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)startTunnelWithOptions:(NSDictionary<NSString *, NSObject *> *)options
            completionHandler:(void (^)(NSError *))completionHandler {
    unsigned int generation = atomic_fetch_add(&_generation, 1) + 1;
    // Both signed targets must declare the same App Group. The host stores
    // accounts/config here while disconnected and stops its core before
    // starting this provider; only one daemon may own the folder at a time.
    NETunnelProviderProtocol *configuration = (NETunnelProviderProtocol *)self.protocolConfiguration;
    NSString *group = [configuration.providerConfiguration objectForKey:@"appGroup"];
    NSURL *shared = group.length ? [[NSFileManager defaultManager]
        containerURLForSecurityApplicationGroupIdentifier:group] : nil;
    if (!shared) {
        completionHandler([NSError errorWithDomain:@"FirefoxVPN" code:1 userInfo:@{
            NSLocalizedDescriptionKey: @"The shared VPN App Group is not configured."
        }]);
        return;
    }
    NSString *dataDir = [[shared URLByAppendingPathComponent:@"core" isDirectory:YES] path];
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]
        initWithTunnelRemoteAddress:@"192.0.2.1"];
    settings.MTU = @1500;
    settings.IPv4Settings = [[NEIPv4Settings alloc]
        initWithAddresses:@[@"172.19.0.1"] subnetMasks:@[@"255.255.255.252"]];
    settings.IPv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    settings.IPv6Settings = [[NEIPv6Settings alloc]
        initWithAddresses:@[@"fdfe:dcba:9876::1"] networkPrefixLengths:@[@126]];
    settings.IPv6Settings.includedRoutes = @[[NEIPv6Route defaultRoute]];
    settings.DNSSettings = [[NEDNSSettings alloc] initWithServers:@[@"172.19.0.2"]];
    settings.DNSSettings.matchDomains = @[@""];
    // Set routes only after both the daemon and the stack have started.
    dispatch_async(_coreQueue, ^{
        if (atomic_load(&self->_generation) != generation) {
            completionHandler([NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]);
            return;
        }
        NSError *error = nil;
        if (!MobileStart(dataDir, NO, &error)) {
            completionHandler(error);
            return;
        }
        if (!MobileStartPacketTunnel(&error)) {
            MobileStop();
            completionHandler(error);
            return;
        }
        MobileConnect();
        __weak PacketTunnelProvider *weakProvider = self;
        [self setTunnelNetworkSettings:settings completionHandler:^(NSError *networkError) {
            PacketTunnelProvider *self = weakProvider;
            if (!self) return;
            dispatch_async(self->_coreQueue, ^{
                if (atomic_load(&self->_generation) != generation) {
                    completionHandler([NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]);
                    return; // stopTunnel owns cleanup for this generation.
                }
                if (networkError) {
                    MobileStop();
                    completionHandler(networkError);
                    return;
                }
                atomic_store(&self->_stopping, false);
                [self readIncomingPackets:generation];
                [self writeOutgoingPackets:generation];
                self->_healthTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self->_coreQueue);
                dispatch_source_set_timer(self->_healthTimer, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                                          2 * NSEC_PER_SEC, NSEC_PER_SEC / 4);
                __weak PacketTunnelProvider *weakSelf = self;
                dispatch_source_set_event_handler(self->_healthTimer, ^{
                    PacketTunnelProvider *provider = weakSelf;
                    if (!provider || atomic_load(&provider->_generation) != generation) return;
                    if (!MobileRunning() || !MobileIsOn()) {
                        NSString *message = MobileLastError();
                        NSError *failure = [NSError errorWithDomain:@"FirefoxVPN" code:2 userInfo:@{
                            NSLocalizedDescriptionKey: message.length ? message : @"The VPN core disconnected."
                        }];
                        [provider cancelTunnelWithError:failure];
                    }
                });
                dispatch_resume(self->_healthTimer);
                completionHandler(nil);
            });
        }];
    });
}

- (void)readIncomingPackets:(unsigned int)generation {
    [self.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *packets,
                                                        NSArray<NSNumber *> *protocols) {
        if (atomic_load(&self->_stopping) || atomic_load(&self->_generation) != generation) return;
        for (NSData *packet in packets) {
            NSError *error = nil;
            if (!MobileWritePacket(packet, &error)) {
                [self cancelTunnelWithError:error];
                return;
            }
        }
        [self readIncomingPackets:generation];
    }];
}

- (void)writeOutgoingPackets:(unsigned int)generation {
    dispatch_async(_outputQueue, ^{
        while (!atomic_load(&self->_stopping) && atomic_load(&self->_generation) == generation) {
            NSData *packet = MobileReadPacket();
            if (!packet.length || atomic_load(&self->_stopping) || atomic_load(&self->_generation) != generation) return;
            uint8_t version = ((const uint8_t *)packet.bytes)[0] >> 4;
            NSNumber *family = @(version == 6 ? AF_INET6 : AF_INET);
            [self.packetFlow writePackets:@[packet] withProtocols:@[family]];
        }
    });
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason
         completionHandler:(void (^)(void))completionHandler {
    atomic_fetch_add(&_generation, 1);
    atomic_store(&_stopping, true);
    dispatch_async(_coreQueue, ^{
        if (self->_healthTimer) {
            dispatch_source_cancel(self->_healthTimer);
            self->_healthTimer = nil;
        }
        MobileStop(); // Cancels the blocking MobileReadPacket call too.
        dispatch_async(self->_outputQueue, completionHandler);
    });
}
@end
