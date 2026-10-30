part of '../action.dart';

const autoSelectInterval = Duration(seconds: 600);
const autoSelectToleranceMs = 0;

String? pickLowestDelayNode({
  required Map<String, int?> delays,
  required String current,
  required int toleranceMs,
}) {
  final currentDelay = delays[current];
  if (currentDelay == null || currentDelay <= 0) return null;
  String? best;
  var bestDelay = currentDelay;
  for (final entry in delays.entries) {
    final delay = entry.value;
    if (delay == null || delay <= 0) continue;
    if (delay < bestDelay - toleranceMs) {
      best = entry.key;
      bestDelay = delay;
    }
  }
  return best;
}

@Riverpod(keepAlive: true)
class SimpleModeAutoSelect extends _$SimpleModeAutoSelect {
  Timer? _timer;
  bool _ticking = false;

  @override
  void build() {
    if (!system.isDesktop) return;
    final enabled = ref.watch(
      appSettingProvider.select((state) => state.autoSelectLowestDelay),
    );
    final started = ref.watch(isStartProvider);
    ref.onDispose(_cancelTimer);
    if (enabled && started) {
      _armTimer();
    } else {
      _cancelTimer();
    }
  }

  void _armTimer() {
    _cancelTimer();
    // Deferred past build: a tick modifies other providers, which Riverpod
    // forbids while this provider is still initializing.
    Future.microtask(() => unawaited(tick()));
    _timer = Timer.periodic(autoSelectInterval, (_) => unawaited(tick()));
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> tick() async {
    if (_ticking) return;
    _ticking = true;
    try {
      final settings = ref.read(appSettingProvider);
      if (!settings.autoSelectLowestDelay) return;
      if (!ref.read(isStartProvider)) return;
      final groups = ref.read(currentGroupsStateProvider).value;
      if (groups.isEmpty) return;
      final scope = settings.autoSelectGroup;
      final Group target;
      final List<Proxy> candidates;
      if (scope == null) {
        final current = groups.firstWhereOrNull(
          (group) => (group.now ?? '').isNotEmpty,
        );
        if (current == null) return;
        target = current;
        final seen = <String>{};
        candidates = [
          for (final group in groups)
            for (final proxy in group.all)
              if (seen.add(proxy.name)) proxy,
        ];
      } else {
        final scoped = groups.firstWhereOrNull((group) => group.name == scope);
        if (scoped == null) return;
        target = scoped;
        candidates = target.all;
      }
      if (target.type != GroupType.Selector) return;
      final currentName = target.now ?? '';
      if (currentName.isEmpty || candidates.isEmpty) return;
      await ref.read(proxiesActionProvider.notifier).delayTest(candidates);
      final delays = <String, int?>{};
      for (final proxy in candidates) {
        delays[proxy.name] = ref.read(
          delayProvider(proxyName: proxy.name, testUrl: target.testUrl),
        );
      }
      final next = pickLowestDelayNode(
        delays: delays,
        current: currentName,
        toleranceMs: autoSelectToleranceMs,
      );
      if (next == null) return;
      await ref
          .read(proxiesActionProvider.notifier)
          .changeProxy(groupName: target.name, proxyName: next);
    } finally {
      _ticking = false;
    }
  }
}
