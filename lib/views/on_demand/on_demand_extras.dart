import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnDemandExtrasView extends ConsumerStatefulWidget {
  const OnDemandExtrasView({super.key});

  @override
  ConsumerState<OnDemandExtrasView> createState() => _OnDemandExtrasViewState();
}

class _OnDemandExtrasViewState extends ConsumerState<OnDemandExtrasView> {
  bool _loading = true;
  bool _alwaysOn = false;
  bool _disconnectOnSleep = false;
  bool _showDisconnectInfo = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      FeatureFlags.getBool(FeatureFlags.onDemandAlwaysOn),
      FeatureFlags.getBool(FeatureFlags.onDemandDisconnectOnSleep),
      FeatureFlags.getBool(
        FeatureFlags.onDemandShowDisconnectInfo,
        fallback: true,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _alwaysOn = results[0];
      _disconnectOnSleep = results[1];
      _showDisconnectInfo = results[2];
      _loading = false;
    });
  }

  Future<void> _set(String key, bool value) async {
    await FeatureFlags.setBool(key, value);
    if (!mounted) return;
    setState(() {
      switch (key) {
        case FeatureFlags.onDemandAlwaysOn:
          _alwaysOn = value;
        case FeatureFlags.onDemandDisconnectOnSleep:
          _disconnectOnSleep = value;
        case FeatureFlags.onDemandShowDisconnectInfo:
          _showDisconnectInfo = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.onDemandExtras,
      isLoading: _loading,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem(
                leading: const Icon(Icons.info_outline),
                title: Text(appLocalizations.onDemandExtrasDesc),
              ),
            ],
          ),
          const SizedBox(height: 16),
          generateSectionV2(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.onDemandAlwaysOn),
                subtitle: Text(appLocalizations.onDemandAlwaysOnDesc),
                value: _alwaysOn,
                onChanged: (v) => _set(FeatureFlags.onDemandAlwaysOn, v),
              ),
              ListItem.toggle(
                title: Text(appLocalizations.onDemandDisconnectOnSleep),
                subtitle: Text(appLocalizations.onDemandDisconnectOnSleepDesc),
                value: _disconnectOnSleep,
                onChanged: (v) =>
                    _set(FeatureFlags.onDemandDisconnectOnSleep, v),
              ),
              ListItem.toggle(
                title: Text(appLocalizations.onDemandShowDisconnectInfo),
                subtitle: Text(appLocalizations.onDemandShowDisconnectInfoDesc),
                value: _showDisconnectInfo,
                onChanged: (v) =>
                    _set(FeatureFlags.onDemandShowDisconnectInfo, v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
