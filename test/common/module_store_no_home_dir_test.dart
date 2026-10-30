import 'package:fl_clash/common/module_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test(
    'list returns empty instead of waiting on an unknown home directory',
    () async {
      expect(await moduleStore.list(), isEmpty);
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );
}
