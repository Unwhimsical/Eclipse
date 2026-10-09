import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('describeActivator', () {
    test('joins modifiers and the key label', () {
      expect(
        describeActivator(
          const SingleActivator(LogicalKeyboardKey.keyK, control: true),
        ),
        anyOf('Ctrl+K', '⌘+K'),
      );
      expect(
        describeActivator(const SingleActivator(LogicalKeyboardKey.slash)),
        '/',
      );
    });
  });

  group('platformActivator', () {
    test('keeps the activator usable on every host', () {
      const activator = SingleActivator(
        LogicalKeyboardKey.comma,
        control: true,
      );
      final mapped = platformActivator(activator);
      expect(mapped.trigger, LogicalKeyboardKey.comma);
      expect(
        mapped.control || mapped.meta,
        isTrue,
        reason: 'Ctrl on Windows/Linux, Cmd on macOS',
      );
    });
  });

  group('DesktopShortcutStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults come from the definitions', () async {
      final store = DesktopShortcutStore();
      await store.ensureLoaded();
      final binding = store.bindingFor(
        desktopShortcutDefs.firstWhere(
          (d) => d.id == DesktopShortcutId.commandPalette,
        ),
      );
      expect(binding, isNotNull);
      expect(binding!.trigger, LogicalKeyboardKey.keyK);
    });

    test('fixed shortcuts have no binding', () async {
      final store = DesktopShortcutStore();
      await store.ensureLoaded();
      final binding = store.bindingFor(
        desktopShortcutDefs.firstWhere(
          (d) => d.id == DesktopShortcutId.switchPage,
        ),
      );
      expect(binding, isNull);
    });

    test('setBinding persists and replaceBinding clears conflicts', () async {
      final store = DesktopShortcutStore();
      await store.ensureLoaded();
      const newBinding = SingleActivator(
        LogicalKeyboardKey.keyJ,
        control: true,
      );
      await store.replaceBinding(DesktopShortcutId.commandPalette, newBinding);
      expect(
        store
            .bindingFor(
              desktopShortcutDefs.firstWhere(
                (d) => d.id == DesktopShortcutId.commandPalette,
              ),
            )
            ?.trigger,
        LogicalKeyboardKey.keyJ,
      );

      // A second shortcut taking the same keys steals them.
      await store.replaceBinding(DesktopShortcutId.delayTest, newBinding);
      final paletteDef = desktopShortcutDefs.firstWhere(
        (d) => d.id == DesktopShortcutId.commandPalette,
      );
      expect(store.bindingFor(paletteDef)?.trigger, LogicalKeyboardKey.keyK);

      await store.resetAll();
      expect(store.bindingFor(paletteDef)?.trigger, LogicalKeyboardKey.keyK);
    });

    test('corrupt persisted data reads as defaults', () async {
      SharedPreferences.setMockInitialValues({
        'desktopShortcuts.v1': 'not-json',
      });
      final store = DesktopShortcutStore();
      await store.ensureLoaded();
      final binding = store.bindingFor(desktopShortcutDefs.first);
      expect(binding, isNotNull);
    });
  });

  group('ValueHolder', () {
    test('holds and updates a value', () {
      final provider = valueHolder(0);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(provider), 0);
      container.read(provider.notifier).value = 3;
      expect(container.read(provider), 3);
      // Same value does not notify.
      var notified = false;
      container.listen(provider, (_, _) => notified = true);
      container.read(provider.notifier).value = 3;
      expect(notified, isFalse);
    });
  });
}
