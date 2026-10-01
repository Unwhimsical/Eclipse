part of '../action.dart';

@Riverpod(keepAlive: true)
class CoreAction extends _$CoreAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  int _requestedRestartRevision = 0;
  Future<bool>? _restartOperation;

  @override
  void build() {}

  Future<void> initCore() async {
    final isInit = await _core.isInit;

    final version = ref.read(versionProvider);
    if (!isInit) {
      final res = await _core.init(version);
      commonPrint.log('init result: $res');
    } else {
      await ref.read(proxiesActionProvider.notifier).updateGroups();
    }
  }

  Future<void> startCore() async {
    ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    try {
      final result = await startLifecycle();
      await _applyLifecycleResult(result);
    } catch (error) {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      dialogs.showNotifier(error.toString(), level: MessageLevel.error);
    }
  }

  @protected
  Future<CoreLifecycleResult> startLifecycle() {
    return _core.start();
  }

  @protected
  Future<CoreLifecycleResult> restartLifecycle() {
    return _core.restart();
  }

  // Nothing in lib/ calls CoreController.stop(); only close() (app exit)
  // supersedes a start/restart. statusFirst lets onCrash catch a crash
  // during initCore itself (it early-returns unless status is connected).
  Future<bool> _applyLifecycleResult(
    CoreLifecycleResult result, {
    bool statusFirst = false,
  }) async {
    if (result.outcome == CoreLifecycleOutcome.superseded) {
      return false;
    }
    if (statusFirst) {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await initCore();
    } else {
      await initCore();
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    }
    // Start MITM proxy if modules need it (fire-and-forget).
    // Resolve the controller synchronously inside the guard: without a
    // Flutter binding (unit tests) the read throws here instead of
    // escaping from the async gap.
    try {
      unawaited(syncMitm());
    } catch (_) {}
    return true;
  }

  /// Sync the MITM proxy with enabled modules and the current profile's
  /// rewrites and MITM hostnames.
  Future<void> syncMitm() async {
    try {
      final manager = MitmManager(_core);
      final profile = ref.read(currentProfileProvider);
      await manager.syncAndStart(
        profileUrlRewrites: profile?.urlRewrites ?? [],
        profileHeaderRewrites: profile?.headerRewrites ?? [],
        profileMitmHostnames: (profile?.mitmEnabled ?? false)
            ? (profile?.mitmHostnames ?? [])
            : [],
        profileMapLocal: profile?.mapLocal ?? [],
        profileBodyRewrites: profile?.bodyRewrites ?? [],
      );
    } catch (_) {}
  }

  Future<void> closeConnection(String id) async {
    await _core.closeConnection(id);
  }

  Future<void> closeConnections() async {
    await _core.closeConnections();
  }

  Future<void> requestGc() async {
    await _core.requestGc();
  }

  Future<void> crash() async {
    await _core.crash();
  }

  Future<bool> restartCore() {
    _requestedRestartRevision++;
    final activeOperation = _restartOperation;
    if (activeOperation != null) {
      return activeOperation;
    }

    final operation = _runRestartWorker();
    _restartOperation = operation;
    return operation;
  }

  Future<void> stopCore() async {
    try {
      await _core.stop();
    } finally {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    }
  }

  Future<bool> _runRestartWorker() async {
    try {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      final result = await restartLifecycle();
      if (!await _applyLifecycleResult(result, statusFirst: true)) {
        return false;
      }

      var appliedRevision = 0;
      var applied = true;
      while (appliedRevision < _requestedRestartRevision) {
        final revision = _requestedRestartRevision;
        if (ref.read(isStartProvider)) {
          applied = await ref
              .read(setupActionProvider.notifier)
              .setRunning(true, initialize: true);
        } else {
          applied = await ref
              .read(setupActionProvider.notifier)
              .applyProfile(force: true);
        }
        appliedRevision = revision;
      }
      return applied;
    } catch (_) {
      ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      rethrow;
    } finally {
      _restartOperation = null;
    }
  }
}
