<div align="center">

[**🇮🇷 فارسی**](docs/readme/README_fa.md)

</div>
<br>

<p align="center"><img src="docs/images/logo.png" width="128" alt="Firefox VPN"></p>

<h1 align="center">Firefox VPN</h1>

<div align="center">

[![Downloads](https://img.shields.io/github/downloads/armanlife/firefox-vpn-client/total?style=flat-square&logo=github&label=Downloads)](https://github.com/armanlife/firefox-vpn-client/releases)
[![Last Version](https://img.shields.io/github/v/release/armanlife/firefox-vpn-client?style=flat-square&label=Version)](https://github.com/armanlife/firefox-vpn-client/releases/latest)
[![License](https://img.shields.io/github/license/armanlife/firefox-vpn-client?style=flat-square&label=License)](LICENSE)

</div>

## What is Firefox VPN?

**Firefox VPN** is a free, open-source VPN that works with a Firefox Account. It carries your internet traffic through Mozilla's servers, on **Fastly**'s infrastructure, over secure **HTTP/2 and HTTP/3** tunnels.

Every Firefox Account comes with **50 GB of free data a month**. Add several accounts, and when one runs out the next takes its place **automatically, without dropping the connection**; with three accounts, for example, that is 150 GB a month.

For **Android, Windows, macOS, and Linux**; no ads, no tracking, and no server but Mozilla's.

<p align="center"><a href="https://raw.githubusercontent.com/armanlife/firefox-vpn-client/main/docs/screenshots/main.webp" target="_blank"><img src="docs/screenshots/main.webp" width="720" alt="Firefox VPN"></a></p>

## 🚀 Main features

✈️ Cross-platform: Android, Windows, macOS, and Linux

⭐ Very easy to use, with a simple interface

🆓 Free: 50 GB a month for every Firefox Account

➕ Multi-account: when one account's data runs out, the next takes over automatically

🌐 Mozilla's official servers: choose a country with a ping test, or let the app pick the best server

⚡ Fast, stable connections over HTTP/2 and HTTP/3

🔀 Smart routing: local sites open directly, faster and without using data

🔌 Several connection modes (VPN and proxy)

🔒 Encrypted DNS (DNS over HTTPS)

🌍 15 languages, including English, Persian, Chinese, and Russian

🌙 Light and dark themes

🛡 Open source, secure, and community-driven

🔄 Automatic update checks

## 📸 Screenshots

<p align="center">
<img src="docs/screenshots/phone_01.webp" width="240" alt="Home">&nbsp;&nbsp;
<img src="docs/screenshots/phone_02.webp" width="240" alt="Servers">&nbsp;&nbsp;
<img src="docs/screenshots/phone_03.webp" width="240" alt="Settings">
</p>

## 📥 Download

<table>
<thead>
<tr><th>System</th><th>Download</th></tr>
</thead>
<tbody>
<tr><td>Android</td><td><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Android-universal.apk"><img src="https://img.shields.io/badge/APK-Universal-1a7f37?logo=android&logoColor=white" alt="APK Universal"></a><br><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Android-arm64-v8a.apk"><img src="https://img.shields.io/badge/APK-ARMv8-2da44e?logo=android&logoColor=white" alt="APK ARMv8"></a><br><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Android-armeabi-v7a.apk"><img src="https://img.shields.io/badge/APK-ARMv7-4ac26b?logo=android&logoColor=white" alt="APK ARMv7"></a><br><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Android-x86_64.apk"><img src="https://img.shields.io/badge/APK-x64-6fdd8b?logo=android&logoColor=white" alt="APK x64"></a></td></tr>
<tr><td>Windows</td><td><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Windows-Setup-x64.exe"><img src="https://img.shields.io/badge/Setup-x64-0550ae?logo=windows&logoColor=white" alt="Setup x64"></a><br><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Windows-x64.zip"><img src="https://img.shields.io/badge/Portable-x64-0969da" alt="Portable x64"></a></td></tr>
<tr><td>macOS</td><td><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-macOS.dmg"><img src="https://img.shields.io/badge/DMG-Universal-24292f?logo=apple&logoColor=white" alt="DMG Universal"></a></td></tr>
<tr><td rowspan="2">Linux</td><td><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Linux-amd64.tar.gz"><img src="https://img.shields.io/badge/App-amd64-e36209?logo=linux&logoColor=white" alt="App amd64"></a><br><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/Firefox-VPN-Linux-arm64.tar.gz"><img src="https://img.shields.io/badge/App-ARM64-e36209?logo=linux&logoColor=white" alt="App ARM64"></a></td></tr>
<tr><td><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/firefox-vpn-core-linux-amd64.tar.gz"><img src="https://img.shields.io/badge/Core-amd64-f0883e?logo=linux&logoColor=white" alt="Core amd64"></a><br><a href="https://github.com/armanlife/firefox-vpn-client/releases/latest/download/firefox-vpn-core-linux-arm64.tar.gz"><img src="https://img.shields.io/badge/Core-ARM64-f6a35e?logo=linux&logoColor=white" alt="Core ARM64"></a></td></tr>
</tbody>
</table>

**Which file should I download?**

- **Android:** if you are not sure, take **Universal**; it installs on every phone. **ARMv8** is for most of today's phones and is smaller.
- **Windows:** **Setup** is a normal installer; **Portable** needs no install and runs from any folder.
- **Linux:** **App** for a Linux desktop (with a graphical environment); **Core** for a server (without a graphical environment, with a web panel).

## 💻 Install and update on Linux and macOS

> Windows and Android users don't need this section: take the installer from the "Download" table above.

```bash
curl -fsSL https://raw.githubusercontent.com/armanlife/firefox-vpn-client/main/install.sh | bash
```

### 🌐 Web panel

The web panel is for **Linux servers without a graphical environment (CLI)**, where the app cannot run. On Windows, macOS, Android, and Linux desktops, use the app itself.

The panel is built into the core, opens in any browser, and does everything the app does: adding and managing accounts and the data left on each, choosing a server and testing real delay, the connection test and public IP, the live log, and every setting.

<p align="center"><img src="docs/screenshots/web.webp" width="720" alt="Web panel"></p>

- **Address:** `http://<server IP>:10820/app/`. On a server the panel is open to access from outside and has a username and password. Its local and public addresses are shown at the end of the install.
- **Proxy:** SOCKS5 and HTTP on port `10810`, with a username and password of its own, so you can share it with other devices on your network too.
- **If the address does not open:** open ports `10820` and `10810` in the server's firewall and in the hosting provider's panel.

### ⌨️ Server commands

`sudo firefox-vpn` on its own opens a numbered menu of all commands. Or type any command directly:

```bash
sudo firefox-vpn                       # a numbered menu of all commands
sudo firefox-vpn status                # the service, proxy, account, and data left
sudo firefox-vpn add-account           # sign in to a Firefox Account (also possible in the web panel)
sudo firefox-vpn list-accounts         # the accounts and their data used
sudo firefox-vpn logs                  # show the service's log
sudo firefox-vpn restart               # restart the service
sudo firefox-vpn set-dashboard-login   # set the web panel's username and password
```
