import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// One KPI cell: label, tabular-figure value, optional trend arrow.
class KpiData {
  const KpiData({required this.label, required this.value, this.trend});

  final String label;
  final String value;

  /// >0 up, <0 down, null hides the arrow (§2: no history → no arrow).
  final double? trend;
}

/// §2 data page KPI strip: four numbers in a row, 64px tall.
class KpiStrip extends StatelessWidget {
  const KpiStrip({super.key, required this.kpis});

  final List<KpiData> kpis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    final text3 = tokens?.text3 ?? theme.colorScheme.onSurfaceVariant;
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          for (var i = 0; i < kpis.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
            Expanded(
              child: _KpiCell(kpi: kpis[i], tokens: tokens, text3: text3),
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.kpi,
    required this.tokens,
    required this.text3,
  });

  final KpiData kpi;
  final DesktopThemeTokens? tokens;
  final Color text3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = kpi.trend;
    final trendColor = trend == null
        ? null
        : trend >= 0
        ? (tokens?.success ?? theme.colorScheme.primary)
        : (tokens?.danger ?? theme.colorScheme.error);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            kpi.label,
            style: theme.textTheme.labelSmall?.copyWith(color: text3),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  kpi.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: DesktopThemeTokens.kpiFontFeatures,
                    color: tokens?.text1 ?? theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null && trendColor != null)
                Icon(
                  trend >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: trendColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Baselines for KPI trend arrows (§2): up/down vs the cumulative total at
/// the same time yesterday, active connections vs 1h ago. The day-old
/// traffic sample persists in SharedPreferences so the arrow can appear
/// across restarts; missing history yields null → the arrow stays hidden.
class KpiBaselines {
  static const _storeKey = 'desktopKpi.dayAgoSample';

  final List<_Sample> _connectionSamples = [];
  _Sample? _dayAgoTraffic;

  DateTime? _lastSampleAt;
  bool _loaded = false;
  DateTime? _lastPersistedAt;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      final raw = prefs?.getString(_storeKey);
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      final at = DateTime.fromMillisecondsSinceEpoch(map['at'] as int);
      final age = DateTime.now().difference(at);
      if (age.inHours >= 20 && age.inHours <= 28) {
        _dayAgoTraffic = _Sample(at, map['up'] as num, map['down'] as num);
      }
    } catch (_) {
      // Corrupt baseline reads as no history.
    }
  }

  /// Keeps one rolling sample; once it is a day old it becomes the
  /// yesterday-same-time baseline for the up/down trend arrows.
  Future<void> recordTraffic(num up, num down) async {
    final now = DateTime.now();
    final base = _dayAgoTraffic;
    if (base == null || now.difference(base.at).inHours >= 25) {
      _dayAgoTraffic = _Sample(now, up, down);
    }
    if (_lastPersistedAt == null ||
        now.difference(_lastPersistedAt!).inMinutes >= 60) {
      _lastPersistedAt = now;
      try {
        final prefs = await preferences.sharedPreferencesCompleter.future;
        await prefs?.setString(
          _storeKey,
          json.encode({
            'at': now.millisecondsSinceEpoch,
            'up': up,
            'down': down,
          }),
        );
      } catch (_) {
        // Baseline persistence is best-effort.
      }
    }
  }

  double? upTrend(num up) {
    final base = _dayAgoTraffic;
    if (base == null) return null;
    final age = DateTime.now().difference(base.at);
    if (age.inHours < 23) return null;
    if (base.up == 0) return null;
    return (up - base.up) / base.up;
  }

  double? downTrend(num down) {
    final base = _dayAgoTraffic;
    if (base == null) return null;
    final age = DateTime.now().difference(base.at);
    if (age.inHours < 23) return null;
    if (base.down == 0) return null;
    return (down - base.down) / base.down;
  }

  /// Sampled at most every 30s; compares against the sample from ~1h ago.
  double? connectionTrend(int active) {
    final now = DateTime.now();
    if (_lastSampleAt == null ||
        now.difference(_lastSampleAt!).inSeconds >= 30) {
      _connectionSamples.add(_Sample(now, active, 0));
      _lastSampleAt = now;
      while (_connectionSamples.length > 125) {
        _connectionSamples.removeAt(0);
      }
    }
    final cutoff = now.subtract(const Duration(hours: 1));
    _Sample? base;
    for (final s in _connectionSamples) {
      if (!s.at.isAfter(cutoff)) {
        base = s;
      } else {
        break;
      }
    }
    if (base == null || base.up == 0) return null;
    return (active - base.up) / base.up;
  }
}

class _Sample {
  _Sample(this.at, this.up, this.down);

  final DateTime at;
  final num up;
  final num down;
}
