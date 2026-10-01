import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/window.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/bootstrap.dart';
import 'package:fl_clash/common/system_dns.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/clipboard_watcher/clipboard_watcher.dart';
import 'package:fl_clash/views/theme/eclipse_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/pages.dart';

Widget buildManagerStack({
  required bool isDesktop,
  required Future<void> Function(List<ConnectivityResult> results)
  onConnectivityChanged,
  required Widget child,
}) {
  final platformApp = isDesktop
      ? WindowHeaderContainer(child: child)
      : VpnManager(child: child);
  final state = AppStateManager(
    child: CoreManager(
      child: ConnectivityManager(
        onConnectivityChanged: onConnectivityChanged,
        child: platformApp,
      ),
    ),
  );
  final platformState = isDesktop
      ? WindowManager(
          child: TrayManager(
            child: HotKeyManager(child: ProxyManager(child: state)),
          ),
        )
      : MobileManager(child: TileManager(child: state));
  return AppEnvManager(
    child: LocaleManager(
      child: StatusManager(child: ThemeManager(child: platformState)),
    ),
  );
}

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application>
    with WidgetsBindingObserver {
  Timer? _autoUpdateProfilesTaskTimer;
  bool _preHasVpn = false;
  DateTime? _lastAlwaysOnAttempt;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: commonSharedXPageTransitions,
      TargetPlatform.windows: commonSharedXPageTransitions,
      TargetPlatform.linux: commonSharedXPageTransitions,
      TargetPlatform.macOS: commonSharedXPageTransitions,
    },
  );

  ColorScheme _getAppColorScheme({required Brightness brightness}) {
    final scheme = ref.read(genColorSchemeProvider(brightness)).eclipse;
    return _isEclipseDefault(brightness) ? scheme.eclipsePrimary : scheme;
  }

  bool _isEclipseDefault(Brightness brightness) {
    final custom = ref.read(
      themeSettingProvider.select((state) => state.primaryColor),
    );
    if (custom != null) return custom == defaultPrimaryColor;
    final seeds = ref.read(dynamicColorProvider);
    final seed = brightness == Brightness.dark
        ? seeds.darkSeed
        : seeds.lightSeed;
    if (seed != null) return false;
    return seeds.accentColor == const Color(defaultPrimaryColor);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemNavigator.setFrameworkHandlesBack(true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (globalState.navigatorKey.currentContext != null) {
        await bootstrap.attach();
      } else {
        exit(0);
      }
      _autoUpdateProfilesTask();
      _initLink();
      unawaited(app?.initShortcuts());
    });
  }

  void _initLink() {
    linkManager.initAppLinksListen((url) async {
      unawaited(window?.show());
      final message = currentAppLocalizations.createProfileFromUrlTip(url);
      final parts = message.split(url);
      final res = await dialogs.showMessage(
        title: currentAppLocalizations.addProfile,
        message: TextSpan(
          children: [
            TextSpan(text: parts.first),
            TextSpan(
              text: url,
              style: TextStyle(
                color: context.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: context.colorScheme.primary,
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts.last),
          ],
        ),
      );
      if (res != true) return;
      unawaited(
        ref
            .read(profilesActionProvider.notifier)
            .addProfileFormURL(url, widgetRef: ref),
      );
    });
  }

  void _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      await ref.read(profilesActionProvider.notifier).autoUpdateProfiles();
      if (!mounted) {
        return;
      }
      _autoUpdateProfilesTask();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.paused || !mounted) return;
    unawaited(_disconnectOnSleep());
  }

  Future<void> _disconnectOnSleep() async {
    if (!await FeatureFlags.getBool(FeatureFlags.onDemandDisconnectOnSleep)) {
      return;
    }
    if (!ref.read(isStartProvider)) return;
    await ref.read(coreActionProvider.notifier).stopCore();
  }

  Future<void> _handleUnexpectedVpnDrop() async {
    final results = await Future.wait([
      FeatureFlags.getBool(
        FeatureFlags.onDemandShowDisconnectInfo,
        fallback: true,
      ),
      FeatureFlags.getBool(FeatureFlags.onDemandAlwaysOn),
    ]);
    final showInfo = results[0];
    final alwaysOn = results[1];
    if (showInfo && mounted) {
      dialogs.showNotifier(
        currentAppLocalizations.disconnected,
        level: MessageLevel.warning,
      );
    }
    if (!alwaysOn) return;
    final now = DateTime.now();
    if (_lastAlwaysOnAttempt != null &&
        now.difference(_lastAlwaysOnAttempt!) < const Duration(seconds: 30)) {
      return;
    }
    _lastAlwaysOnAttempt = now;
    await ref.read(coreActionProvider.notifier).startCore();
  }

  Future<void> _handleConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    commonPrint.log('connectivityChanged ${results.toString()}');
    unawaited(systemDnsCoordinator?.resync() ?? Future.value());
    unawaited(ref.read(systemActionProvider.notifier).updateLocalIp());
    ref.read(sceneModeProvider.notifier).onConnectivityChanged(results);
    final hasVpn = results.contains(ConnectivityResult.vpn);
    if (_preHasVpn == hasVpn) {
      ref.read(checkIpNumProvider.notifier).add();
    } else if (_preHasVpn && !hasVpn && ref.read(isStartProvider)) {
      unawaited(_handleUnexpectedVpnDrop());
    }
    _preHasVpn = hasVpn;
  }

  @override
  Widget build(context) {
    return Consumer(
      builder: (_, ref, child) {
        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final themeProps = ref.watch(themeSettingProvider);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: globalState.navigatorKey,
          onNavigationNotification: (_) => true,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) {
            // The bridge's legacy Theme swaps in its own default IconTheme color,
            // which material_ui IconButton.filled reads as custom and loses onPrimary.
            // ignore: deprecated_member_use
            return MaterialUiCompatibilityBridge(
              child: IconTheme(
                data: Theme.of(context).iconTheme,
                child: buildManagerStack(
                  isDesktop: system.isDesktop,
                  onConnectivityChanged: _handleConnectivityChanged,
                  child: child!,
                ),
              ),
            );
          },
          scrollBehavior: const BaseScrollBehavior(),
          title: appName,
          locale: getLocaleForString(locale),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          themeMode: themeProps.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(brightness: Brightness.light),
          ).withAppShapes.eclipse,
          darkTheme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(
              brightness: Brightness.dark,
            ).toPureBlack(themeProps.pureBlack),
          ).withAppShapes.eclipse,
          home: ClipboardLinkWatcher(
            onLinkDetected: (link) async {
              await ShadowrocketImport.importShareLinks(ref, text: link);
            },
            child: child!,
          ),
        );
      },
      child: const HomePage(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    linkManager.destroy();
    _autoUpdateProfilesTaskTimer?.cancel();
    super.dispose();
  }
}
