import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/modules/modules.dart';
import 'package:fl_clash/views/rules/rules.dart';
import 'package:material_ui/material_ui.dart';

class RulesHubView extends StatefulWidget {
  const RulesHubView({super.key});

  @override
  State<RulesHubView> createState() => _RulesHubViewState();
}

class _RulesHubViewState extends State<RulesHubView>
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
            Tab(text: appLocalizations.rules),
            Tab(text: appLocalizations.modules),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [RulesView(), ModulesView()],
          ),
        ),
      ],
    );
  }
}
