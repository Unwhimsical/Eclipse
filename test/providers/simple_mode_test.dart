import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandler extends Mock implements CoreHandlerInterface {}

ProviderContainer _container(
  _MockCoreHandler core, {
  String? scope,
  GroupType targetType = GroupType.Selector,
}) {
  final groups = [
    Group(
      type: targetType,
      name: 'PROXY',
      now: 'Node A',
      all: const [
        Proxy(name: 'Node A', type: 'ss'),
        Proxy(name: 'Node B', type: 'ss'),
      ],
    ),
  ];
  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      isStartProvider.overrideWithValue(true),
      profilesProvider.overrideWith(() => TestProfiles(const [])),
      currentProfileIdProvider.overrideWithBuild((_, _) => null),
      currentGroupsStateProvider.overrideWithValue(GroupsState(value: groups)),
    ],
  );
  addTearDown(container.dispose);
  container.listen(appSettingProvider, (_, _) {});
  container.listen(delayDataSourceProvider, (_, _) {});
  container
      .read(appSettingProvider.notifier)
      .update(
        (state) =>
            state.copyWith(autoSelectLowestDelay: true, autoSelectGroup: scope),
      );
  return container;
}

void _stubDelays(_MockCoreHandler core, Map<String, int> delays) {
  when(() => core.asyncTestDelay(any(), any())).thenAnswer((invocation) async {
    final name = invocation.positionalArguments[1] as String;
    return Delay(
      name: name,
      url: invocation.positionalArguments[0] as String,
      value: delays[name],
    );
  });
  when(() => core.changeProxy(any())).thenAnswer((_) async => '');
  when(() => core.closeConnections()).thenAnswer((_) async => true);
  when(() => core.resetConnections()).thenAnswer((_) async => true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCoreHandler core;

  setUpAll(() {
    registerFallbackValue(
      const ChangeProxyParams(groupName: 'G', proxyName: 'P'),
    );
    core = _MockCoreHandler();
  });

  setUp(() => reset(core));

  group('pickLowestDelayNode', () {
    test('switches to a strictly lower delay', () {
      expect(
        pickLowestDelayNode(
          delays: {'Node A': 100, 'Node B': 50},
          current: 'Node A',
          toleranceMs: 0,
        ),
        'Node B',
      );
    });

    test('stays on equal delay with zero tolerance', () {
      expect(
        pickLowestDelayNode(
          delays: {'Node A': 50, 'Node B': 50},
          current: 'Node A',
          toleranceMs: 0,
        ),
        isNull,
      );
    });

    test('respects a nonzero tolerance', () {
      expect(
        pickLowestDelayNode(
          delays: {'Node A': 100, 'Node B': 95},
          current: 'Node A',
          toleranceMs: 10,
        ),
        isNull,
      );
      expect(
        pickLowestDelayNode(
          delays: {'Node A': 100, 'Node B': 85},
          current: 'Node A',
          toleranceMs: 10,
        ),
        'Node B',
      );
    });

    test('ignores timeouts, untested nodes and itself', () {
      expect(
        pickLowestDelayNode(
          delays: {'Node A': 100, 'Node B': 0, 'Node C': null},
          current: 'Node A',
          toleranceMs: 0,
        ),
        isNull,
      );
    });

    test('never switches away from an unmeasured current node', () {
      expect(
        pickLowestDelayNode(
          delays: {'Node A': null, 'Node B': 50},
          current: 'Node A',
          toleranceMs: 0,
        ),
        isNull,
      );
    });
  });

  group('app setting defaults', () {
    test('simple mode and auto-select are off by default', () {
      const settings = AppSettingProps();
      expect(settings.simpleMode, isFalse);
      expect(settings.autoSelectLowestDelay, isFalse);
      expect(settings.autoSelectGroup, isNull);
    });
  });

  group('SimpleModeAutoSelect.tick', () {
    test('switches to the lowest-delay node', () async {
      _stubDelays(core, {'Node A': 100, 'Node B': 50});
      final container = _container(core);
      container.read(simpleModeAutoSelectProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final captured =
          verify(() => core.changeProxy(captureAny())).captured.single
              as ChangeProxyParams;
      expect(captured.groupName, 'PROXY');
      expect(captured.proxyName, 'Node B');
    });

    test('does not switch when nothing is lower', () async {
      _stubDelays(core, {'Node A': 50, 'Node B': 80});
      final container = _container(core);
      container.read(simpleModeAutoSelectProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      verifyNever(() => core.changeProxy(any()));
    });

    test(
      'skips url-test groups, which the core already auto-selects',
      () async {
        _stubDelays(core, {'Node A': 100, 'Node B': 50});
        final container = _container(core, targetType: GroupType.URLTest);
        container.read(simpleModeAutoSelectProvider);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        verifyNever(() => core.asyncTestDelay(any(), any()));
        verifyNever(() => core.changeProxy(any()));
      },
    );

    test('scoped group narrows the candidate range', () async {
      _stubDelays(core, {'Node A': 100, 'Node B': 50});
      final container = _container(core, scope: 'PROXY');
      container.read(simpleModeAutoSelectProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final captured =
          verify(() => core.changeProxy(captureAny())).captured.single
              as ChangeProxyParams;
      expect(captured.groupName, 'PROXY');
      expect(captured.proxyName, 'Node B');
    });
  });
}
