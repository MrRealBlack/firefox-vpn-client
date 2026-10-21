import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firefox_vpn/core/models.dart';
import 'package:firefox_vpn/l10n/app_localizations.dart';
import 'package:firefox_vpn/ui/widgets.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));

  ProxyInfo proxy({String error = '', String code = '', String? at}) =>
      ProxyInfo.fromJson({
        'wake_error': error,
        'wake_error_code': code,
        'wake_failed_at': ?at,
      });

  ConnectionTest failedTest({
    String error = '',
    String code = '',
    String? at,
  }) => ConnectionTest.fromJson({
    'ok': false,
    'error': error,
    'error_code': code,
    'at': ?at,
  });

  test('the reason is named, not the internet', () {
    final quota = failureText(
      l,
      proxy(error: 'quota exceeded', code: Failure.quota),
      null,
    );
    expect(quota.text, l.failQuota);
    expect(quota.detail, 'quota exceeded');

    expect(
      failureText(l, null, failedTest(error: 'x', code: Failure.testSite)).text,
      l.failTestSite,
    );
    expect(
      failureText(
        l,
        null,
        failedTest(error: 'x', code: Failure.unreachable),
      ).text,
      l.failUnreachable,
    );
    expect(
      failureText(l, null, failedTest(error: 'odd', code: Failure.other)).text,
      l.failOther,
    );
  });

  test('no internet says so; an unknown code asks to check it', () {
    expect(
      failureText(
        l,
        null,
        failedTest(error: 'x', code: Failure.noNetwork),
      ).text,
      l.failNoInternet,
    );
    // The core's own words stay out of the text.
    final other = failureText(
      l,
      null,
      failedTest(
        error: 'Get "https://www.google.com/generate_204": odd',
        code: Failure.other,
      ),
    );
    expect(other.text, l.failOther);
    expect(other.detail, contains('generate_204'));
    expect(
      failureText(l, null, failedTest(error: 'x', code: 'new_kind')).text,
      l.connectRetrying,
    );
  });

  test('the newer of the wake failure and the test speaks', () {
    const early = '2026-10-19T10:00:00Z';
    const late = '2026-10-19T10:05:00Z';
    final wakeLater = failureText(
      l,
      proxy(error: 'w', code: Failure.signIn, at: late),
      failedTest(error: 't', code: Failure.unreachable, at: early),
    );
    expect(wakeLater.text, l.failSignIn);
    final testLater = failureText(
      l,
      proxy(error: 'w', code: Failure.signIn, at: early),
      failedTest(error: 't', code: Failure.unreachable, at: late),
    );
    expect(testLater.text, l.failUnreachable);
    expect(testLater.detail, 't');
  });
}
