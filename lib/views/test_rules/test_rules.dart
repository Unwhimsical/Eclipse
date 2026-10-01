import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rule_matcher.dart';

class TestRulesView extends ConsumerStatefulWidget {
  const TestRulesView({super.key});

  @override
  ConsumerState<TestRulesView> createState() => _TestRulesViewState();
}

class _TestRulesViewState extends ConsumerState<TestRulesView> {
  final _inputController = TextEditingController();
  final _portController = TextEditingController(text: '443');

  List<String>? _rules;
  bool _loadingRules = true;
  String _network = 'TCP';
  RuleMatchVerdict? _verdict;
  bool _tested = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) {
      if (mounted) setState(() => _loadingRules = false);
      return;
    }
    try {
      final config = await ref.read(coreHandlerProvider).getConfig(profile.id);
      final rules = config['rules'];
      if (!mounted) return;
      setState(() {
        _rules = rules is List ? List<String>.from(rules) : const [];
        _loadingRules = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRules = false);
    }
  }

  void _handleTest() {
    final appLocalizations = context.appLocalizations;
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _error = appLocalizations.testRulesEmptyInput;
        _tested = false;
      });
      return;
    }
    final port = int.tryParse(_portController.text.trim()) ?? 443;
    final target = TestTarget.parse(input, port, _network);
    if (target == null) {
      setState(() {
        _error = appLocalizations.testRulesEmptyInput;
        _tested = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _tested = true;
      _verdict = findFirstMatch(_rules ?? const [], target);
    });
  }

  Widget _buildResult(AppLocalizations appLocalizations) {
    if (!_tested) return const SizedBox.shrink();
    final verdict = _verdict;
    final rules = _rules ?? const [];
    if (verdict == null) {
      return ListItem(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(appLocalizations.testRulesNoMatch),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListItem(
          leading: Icon(
            verdict.certain ? Icons.gps_fixed : Icons.help_outline,
            color: verdict.certain ? Colors.green : Colors.orange,
          ),
          title: Text(appLocalizations.testRulesMatchedRule),
          subtitle: Text(
            verdict.rawRule,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        ListItem(
          title: Text(
            appLocalizations.testRulesRuleOrder(
              '${verdict.index + 1}',
              '${rules.length}',
            ),
          ),
          subtitle: verdict.target == null
              ? null
              : Text('${appLocalizations.statConnPolicy}: ${verdict.target}'),
        ),
        if (!verdict.certain)
          ListItem(
            leading: const Icon(Icons.info_outline, color: Colors.orange),
            title: Text(appLocalizations.testRulesUnsupportedRule),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final rules = _rules;
    return CommonScaffold(
      title: appLocalizations.testRules,
      isLoading: _loadingRules,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (rules == null && !_loadingRules)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ListItem(
                leading: const Icon(Icons.warning_amber_outlined),
                title: Text(appLocalizations.testRulesNoProfile),
              ),
            ),
          generateSectionV2(
            title: appLocalizations.testRules,
            items: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: appLocalizations.testRulesInputLabel,
                        hintText: appLocalizations.testRulesInputHint,
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _handleTest(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _portController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: appLocalizations.testRulesPortLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'TCP', label: Text('TCP')),
                            ButtonSegment(value: 'UDP', label: Text('UDP')),
                          ],
                          selected: {_network},
                          onSelectionChanged: (selection) {
                            setState(() => _network = selection.first);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const ValueKey('testRulesTestButton'),
                      onPressed: _handleTest,
                      child: Text(appLocalizations.testRulesTest),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_tested)
            generateSectionV2(
              title: appLocalizations.testRulesEffectiveRules(
                '${rules?.length ?? 0}',
              ),
              items: [_buildResult(appLocalizations)],
            ),
        ],
      ),
    );
  }
}
