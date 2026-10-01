import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/views/subscriptions/subscriptions.dart';
import 'package:material_ui/material_ui.dart';

class ProxiesHubView extends StatefulWidget {
  const ProxiesHubView({super.key});

  @override
  State<ProxiesHubView> createState() => _ProxiesHubViewState();
}

class _ProxiesHubViewState extends State<ProxiesHubView>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: appLocalizations.proxies),
            Tab(text: appLocalizations.subscriptions),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [ProxiesView(), SubscriptionsView()],
          ),
        ),
      ],
    );
  }
}
