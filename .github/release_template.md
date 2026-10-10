<div align=center>

[![Release Downloads](https://img.shields.io/github/downloads/Unwhimsical/Eclipse/vVERSION/total?style=flat-square&logo=github)](https://img.shields.io/github/downloads/Unwhimsical/Eclipse/vVERSION/)

</div>

**Highlights:**

- 🖥️ Redesigned desktop UI (Windows / macOS): sidebar navigation, five dedicated pages, rich node cards
- 📱 iOS support with NetworkExtension-based VPN
- 🔓 MITM engine: TLS decryption, header/body rewrite, Map Local, JS scripting
- 📦 Shadowrocket-compatible: `.conf` configs, `.sgmodule` modules, share-link subscriptions

**Download based on your OS:**

<div align=left>
<table>
    <thead align=left>
        <tr>
            <th>OS</th>
            <th>Download</th>
        </tr>
    </thead>
    <tbody align=left>
        <tr>
        <td>Android</td>
            <td>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-android-arm64-v8a.apk"><img src="https://img.shields.io/badge/APK-ARMv8-168039.svg?logo=android"></a><br>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-android-armeabi-v7a.apk"><img src="https://img.shields.io/badge/APK-ARMv7-45bf55.svg?logo=android"></a><br>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-android-x86_64.apk"><img src="https://img.shields.io/badge/APK-x64-96ed89.svg?logo=android"></a>
            </td>
        </tr>
        <tr>
            <td>Windows</td>
            <td>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-windows-amd64-setup.exe"><img src="https://img.shields.io/badge/Setup-x64-2d7d9a.svg?logo=windows"></a><br>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-windows-amd64.zip"><img src="https://img.shields.io/badge/Portable-x64-67b7d1.svg?logo=windows"></a>
            </td>
        </tr>
        <tr>
            <td>macOS</td>
            <td>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-macos-arm64.dmg"><img src="https://img.shields.io/badge/DMG-Apple%20Silicon-%23000000.svg?logo=apple"></a><br>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-macos-amd64.dmg"><img src="https://img.shields.io/badge/DMG-Intel%20X64-%2300A9E0.svg?logo=apple"></a><br>
            </td>
        </tr>
        <tr>
            <td>Linux</td>
            <td>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-linux-amd64.AppImage"><img src="https://img.shields.io/badge/AppImage-x64-f84e29.svg?logo=linux"> </a><br>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-linux-amd64.deb"><img src="https://img.shields.io/badge/DebPackage-x64-FF9966.svg?logo=debian"> </a><br>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-linux-amd64.rpm"><img src="https://img.shields.io/badge/RpmPackage-x64-F1B42F.svg?logo=redhat"> </a>
            </td>
        </tr>
        <tr>
            <td>iOS</td>
            <td>
                <a href="https://github.com/Unwhimsical/Eclipse/releases/download/vVERSION/Eclipse-VERSION-ios-unsigned.ipa"><img src="https://img.shields.io/badge/IPA-Unsigned-%23000000.svg?logo=apple"></a><br>
                <sub>未签名包，需自行签名后安装（见下方说明）</sub>
            </td>
        </tr>
    </tbody>
</table>


</div>

**安装说明：**

- **Windows**：下载 `*-setup.exe` 安装版，或 `*.zip` 解压即用（绿色版）
- **macOS**：下载对应芯片的 `.dmg`（Apple Silicon 用 arm64，Intel 用 amd64），拖入应用程序文件夹
- **Android**：下载对应架构的 `.apk`（主流手机用 arm64-v8a），允许安装未知来源应用后安装
- **Linux**：`AppImage` 双击运行；`deb`/`rpm` 用包管理器安装；`zip` 解压即用
- **iOS**：下载 `*-ios-unsigned.ipa`（未签名），需用 Apple 开发者证书自行签名后通过 AltStore / Sideloadly / TrollStore 等工具安装

**MITM 证书风险提示：**

Eclipse 内置 CA 中心可生成 MITM 根证书用于 HTTPS 解密（如去广告）。安装根证书意味着授予应用解密你所有 HTTPS 流量的能力，请确保：
1. 只在你信任的设备上安装
2. 证书仅用于你明确需要的域名（模块中可配置）
3. 不再需要时及时删除证书

<div dir="ltr">

**List of all changes:** [ChangeLog](https://github.com/Unwhimsical/Eclipse/blob/main/CHANGELOG.md)

</div>