# Attribution / 归属说明

Eclipse 中的 iOS 移植内容基于以下两个开源项目，依据
GNU General Public License v3.0 (GPL-3.0) 保持开源：

1. **chen08209/FlClash** — https://github.com/chen08209/FlClash
   - 原始项目：Flutter + Mihomo 内核的多平台代理客户端。
   - 本移植中的 `lib/`、`core/`、`android/` 大部分代码、构建脚本与整体架构
     均源自该项目。

2. **chenx-dust/flclash-patched**（FlClash-Patched）— https://github.com/chenx-dust/FlClash-Patched
   - 社区 fork，为 FlClash 补上了完整的 iOS 支持。
   - 本目录中的 `ios/`（Runner / NECore / Widget / Shared 原生实现）、
     `plugins/setup/setup_hooks` 的 iOS 构建链、`core/` 的 iOS 平台文件
     （`bride_ios.go`、`platform/ios.go`、`tun/tun_ios.go`、`tun/options.go`、
     `lowmem.go`）、`tool/geodata.dart`、`setup.dart` 的 iOS 打包逻辑，
     以及 Go `startTUN` 的 JSON `TunOptions` ABI，均移植自该项目。

身份适配（本移植所做的修改）：

- App 显示名：FlClash → **Eclipse**
- Bundle ID：`com.follow.clash` → **`com.eclipse.clash`**
- 扩展：`com.eclipse.clash.NECore`、`com.eclipse.clash.Widget`
- App Group：`group.com.eclipse.clash`
- Android JNI / Kotlin 包名：`com.follow.clash` → `com.eclipse.clash`
- `VpnOptions.captureDns` 回退为上游字段名 `dnsHijacking`
  （Swift 解码器兼容两种拼写，见 `ios/NECore/PacketTunnelSharedStateStore.swift`）

License: GPL-3.0 — 保留上游版权与许可证声明，衍生分发必须同样开源。
