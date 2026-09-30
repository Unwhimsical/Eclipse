# iOS Port Notes / 移植说明

目标：把 `chenx-dust/flclash-patched` 的完整 iOS 实现，以最小改动移植到
当前 FlClash 上游代码基，App 名 Eclipse，bundle `com.eclipse.clash`，
并在 GitHub Actions（macOS runner）上产出**未签名 IPA**。

> 本目录按仓库相对路径组织。`lib/**`、`core/**`、`android/**`、
> `plugins/**`、`tool/**`、`setup.dart`、`pubspec.yaml`、`.gitignore`、
> `.github/**` 为**完整的新文件内容**，可直接覆盖到仓库对应路径。
> 覆盖前请先合入上游更新并解决冲突。

## 文件清单

| 路径 | 说明 |
|---|---|
| `ios/` | 完整 iOS 原生工程（Runner App / NECore Packet Tunnel 扩展 / Widget / Shared 静态库），已做身份适配 |
| `lib/common/system.dart` | 新增 `isIOS`、`isMobile`；iOS 版本号解析 |
| `lib/common/path.dart` | iOS 数据目录迁移到 App Group container（NECore 才能读到配置） |
| `lib/plugins/service.dart` | `start(SharedState state)`：把 SharedState JSON 传给原生层启动隧道；iOS 也创建 Service |
| `lib/core/lib.dart` | iOS 的 listener 由 NetworkExtension 管理；`coreLib` 在 Android/iOS 均启用 |
| `lib/manager/mobile_manager.dart` | 由 `android_manager.dart` 重命名；`updateExcludeFromRecents` 仅 Android |
| `lib/manager/manager.dart` | barrel 导出更新 |
| `lib/application.dart` | `AndroidManager` → `MobileManager` |
| `core/bride.h`、`core/bride.c` | build tag 支持 iOS；新增 retain object / system log 回调 |
| `core/bride_ios.go` | 新增：iOS C 回调桥接 |
| `core/lib.go` | build tag `(android || ios) && cgo`；`startTUN` 改为接收 JSON `TunOptions` |
| `core/lowmem.go` | 新增：`with_low_memory` tag 把 Go 内存限制在 32MB（给 NECore 扩展用） |
| `core/platform/ios.go` | 新增：iOS 平台实现（不要求 protect 回调，不关闭系统持有的 fd） |
| `core/platform/limit.go` | 新增 `RequiresProtectCallback` / `CloseRejectedTunDescriptor` |
| `core/tun/options.go` | 新增：`t.Options`（stack/address/dns/mtu/icmp/nat…） |
| `core/tun/tun_ios.go` | 新增：iOS TUN 实现（dup fd + sing-tun，`AutoRoute=false`） |
| `core/tun/tun_android.go` | 由 `tun.go` 重命名并适配新 `t.Options` 接口 |
| `android/core/.../Core.kt` | 新增 `TunOptions` data class；`startTun` 改传 JSON |
| `android/core/.../core.cpp` | JNI 签名适配（包名 `com.eclipse.clash`） |
| `android/service/.../VpnOptions.kt` | 新增 `mtu`（默认 9000）、`disableIcmpForwarding`、`endpointIndependentNat` |
| `android/service/.../VpnService.kt` | `Core.startTun` 改传 `Core.TunOptions(...)`；`setMtu(options.mtu)` |
| `plugins/setup/setup_hooks/` | 新增 `bin/build_ios.dart`、`lib/src/ios_build.dart`；`target.dart`/`go_builder.dart`/`build.dart` 支持 `ios/arm64`（含 lowmem 变体） |
| `setup.dart` | 新增 `ios --no-codesign` 打包流程（ad-hoc 签名 + entitlements + IPA） |
| `tool/geodata.dart` | `setup.dart` 依赖的 geo 数据下载 |
| `pubspec.yaml` | 新增 `path_provider_foundation`、`xml` |
| `.gitignore` | 新增 `ios/Flutter/GeneratedBundleConfig.xcconfig` 等 |
| `.github/workflows/ipa.yaml` | macOS 上 `flutter build ios --no-codesign` → `Eclipse-unsigned.ipa` |
| `ATTRIBUTION.md` | GPL 归属 |

## 与参考实现的关键差异（有意为之）

1. **最小化移植**：参考 fork 的 `lib/` 与上游独立演进，差异巨大。本移植只动了
   iOS 必需的最少 Dart 接线（system/path/service/lib/manager），**没有**搬运
   参考的 On-Demand UI、设置页重构、可移植模式等。
2. **字段名**：保留上游 `VpnOptions.dnsHijacking`（不改成参考的 `captureDns`），
   Swift 解码器同时兼容两种拼写，避免 Dart model + codegen + Android 三方联动。
3. **双 core 架构**（沿用参考设计）：
   - Runner App 链接完整 `libclash.a`（配置校验、订阅解析等本地调用）；
   - NECore 扩展链接 `libclash_lowmem.a`（32MB 内存限制，iOS 扩展内存配额紧张）。
   - `CoreMessageRouter` 按隧道状态把 Dart `invokeMethod` 路由到 App core 或扩展 core。
4. **数据目录**：iOS 上 `AppPath.dataDir` 指向 App Group container，
   使 Runner 与 NECore 读写同一份 Mihomo home。

## 构建（CI）

`.github/workflows/ipa.yaml`：macOS runner，Flutter 3.47.1 + Go 1.26.4，
`flutter pub get` → `flutter build ios --release --no-codesign` →
`ditto` 打包 `Payload/Runner.app` → 上传 `Eclipse-unsigned.ipa`。
Xcode 的 Run Script 阶段会自动调用 `build_ios.dart` 编译 Go 静态库，
无需手工先编 core。**不使用任何签名 secrets。**

## 签名与安装（用户侧）

- 未签名 IPA **不能直接安装**，需用自己的 Apple ID / 证书重签
  **App + NECore.appex + Widget.appex** 三个 bundle。
- 重签时必须开启 capabilities：**Network Extensions（Packet Tunnel）**、
  **App Groups**（`group.com.eclipse.clash`）。
- 免费 Apple ID 通常无法签发 Packet Tunnel 的 NetworkExtension entitlement，
  一般需要 Apple Developer Program（付费）账号。
- 签名用的 bundle ID / App Group 必须与 `ios/Flutter/*.xcconfig` 中的
  `APP_BUNDLE_ID = com.eclipse.clash` 一致，否则隧道无法启动。

## 已知限制 / 风险

- 无 Mac/Xcode 环境，**未做真机编译验证**；首次 CI 运行可能暴露问题
  （最可能的是 Go cgo 交叉编译 flags 或 Xcode 工程配置）。
- `setup.dart ios --no-codesign` 路径（ad-hoc codesign + entitlements 注入）
  已 stage 但 workflow 未采用；若直接 `--no-codesign` 产物在重签时有问题，
  可切换到 `dart setup.dart ios --no-codesign`。
- 参考 fork 的 `VpnOptions` 还有更多字段（recv/send msg、iOS 路由选项等），
  本移植只取了 TUN 必需的最小集合；如需调优再补。
