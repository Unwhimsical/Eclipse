import Flutter
import Foundation
import NetworkExtension

/// Answers the `wifi_ssid` method channel used by Dart's `WifiSsidManager`,
/// so scene mode can read the current Wi-Fi SSID on iOS.
///
/// iOS 14+: `CNCopyCurrentNetworkInfo` returns nothing unless this app
/// configured the network itself, so the supported path is the async-only
/// `NEHotspotNetwork.fetchCurrent`, gated by the
/// `com.apple.developer.networking.wifi-info` entitlement (already in
/// `Runner.entitlements`). No runtime permission prompt is involved.
///
/// Platform limits, stated honestly: iOS only reveals the SSID while the
/// app is in the foreground, so scene switching on iOS is foreground-only;
/// background/real-time switching is not promised. iOS 27 behavior still
/// needs real-device verification.
final class WifiSsidChannel: NSObject {
  private enum Method {
    static let getSsid = "getSsid"
    static let checkPermission = "checkPermission"
    static let requestPermission = "requestPermission"
  }

  /// Values must match `WifiSsidPermission.index` in Dart.
  private enum Permission: Int {
    case granted = 0
    case denied = 1
    case permanentlyDenied = 2
  }

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "wifi_ssid",
      binaryMessenger: messenger
    )
    let instance = WifiSsidChannel()
    // Registered directly on the engine messenger from the app delegate,
    // so no FlutterPluginRegistrar conformance is needed.
    channel.setMethodCallHandler(instance.handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case Method.getSsid:
      getSsid(result: result)
    case Method.checkPermission, Method.requestPermission:
      result(Permission.granted.rawValue)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getSsid(result: @escaping FlutterResult) {
    NEHotspotNetwork.fetchCurrent { network in
      DispatchQueue.main.async {
        result(network?.ssid)
      }
    }
  }
}
