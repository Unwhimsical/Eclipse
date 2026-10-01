import 'package:fl_clash/common/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class FeatureFlags {
  static const String frontProxyId = 'frontProxyId';
  static const String compatibilityMode = 'compatibilityMode';
  static const String delayTestMethod = 'delayTestMethod';
  static const String delayTestUrl = 'delayTestUrl';
  static const String udpForward = 'udpForward';
  static const String disableStun = 'disableStun';
  static const String proxySharing = 'proxySharing';

  static const String onDemandAlwaysOn = 'onDemandAlwaysOn';
  static const String onDemandDisconnectOnSleep = 'onDemandDisconnectOnSleep';
  static const String onDemandShowDisconnectInfo = 'onDemandShowDisconnectInfo';

  static Future<SharedPreferences> _store() async {
    final store = await preferences.sharedPreferencesCompleter.future;
    if (store == null) {
      throw StateError('SharedPreferences not initialized');
    }
    return store;
  }

  static Future<bool> getBool(String key, {bool fallback = false}) async {
    final store = await _store();
    return store.getBool(key) ?? fallback;
  }

  static Future<void> setBool(String key, bool value) async {
    final store = await _store();
    await store.setBool(key, value);
  }

  static Future<String?> getString(String key) async {
    final store = await _store();
    return store.getString(key);
  }

  static Future<void> setString(String key, String? value) async {
    final store = await _store();
    if (value == null) {
      await store.remove(key);
    } else {
      await store.setString(key, value);
    }
  }
}
