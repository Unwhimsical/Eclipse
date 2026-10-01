import 'package:fl_clash/bootstrap.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attach returns early when already attached', () async {
    globalState.isAttach = true;
    addTearDown(() {
      globalState.isAttach = false;
    });

    await bootstrap.attach();

    expect(globalState.isAttach, isTrue);
  });

  test('Bootstrap is a singleton', () {
    expect(identical(Bootstrap(), bootstrap), isTrue);
  });
}
