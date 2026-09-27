import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CA center: generate the MITM root CA in-app and guide the user through
/// installing and trusting it, on Android and iOS.
class CaView extends ConsumerStatefulWidget {
  const CaView({super.key});

  @override
  ConsumerState<CaView> createState() => _CaViewState();
}

class _CaViewState extends ConsumerState<CaView> {
  bool _loading = true;
  bool _generating = false;
  bool _exists = false;
  CaMeta? _meta;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final exists = await caStore.exists;
    final meta = exists ? await caStore.readMeta() : null;
    if (!mounted) return;
    setState(() {
      _exists = exists;
      _meta = meta;
      _loading = false;
    });
  }

  Future<void> _handleGenerate() async {
    final confirmed = await dialogs.showMessage(
      title: currentAppLocalizations.tip,
      message: const TextSpan(text: '生成新的 MITM 根证书？旧证书将失效，已安装的旧证书需要重新安装。'),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _generating = true);
    try {
      final core = ref.read(coreHandlerProvider);
      final result = await core.generateCA();
      final cert = result['cert'] ?? '';
      final key = result['key'] ?? '';
      if (cert.isEmpty || key.isEmpty) {
        throw Exception('empty CA');
      }
      await caStore.save(cert: cert, key: key);
      if (!mounted) return;
      dialogs.showNotifier('根证书已生成', level: MessageLevel.success);
    } catch (_) {
      if (!mounted) return;
      dialogs.showNotifier('生成失败', level: MessageLevel.error);
    } finally {
      if (mounted) setState(() => _generating = false);
      await _refresh();
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await dialogs.showMessage(
      title: currentAppLocalizations.tip,
      message: const TextSpan(text: '删除根证书？'),
    );
    if (confirmed != true) return;
    await caStore.delete();
    await _refresh();
  }

  Future<void> _handleCopy() async {
    final cert = await caStore.readCert();
    if (cert == null) return;
    await Clipboard.setData(ClipboardData(text: cert));
    if (!mounted) return;
    dialogs.showNotifier('证书已复制', level: MessageLevel.success);
  }

  Future<void> _handleExport() async {
    final cert = await caStore.readCert();
    if (cert == null) return;
    final uri = await picker.saveFile(
      'PigCat-CA.crt',
      Uint8List.fromList(cert.codeUnits),
    );
    if (uri != null && mounted) {
      dialogs.showNotifier('已导出证书', level: MessageLevel.success);
    }
  }

  List<String> _installSteps() {
    if (system.isAndroid) {
      return [
        '点击下方「导出证书」，保存 PigCat-CA.crt',
        '打开系统设置 → 安全 → 加密与凭据 → 安装证书 → CA 证书',
        '选择刚导出的证书并确认安装',
        'Android 7+ 应用默认不信任用户证书，解密仅对目标应用生效需配合 VPN 抓包',
      ];
    }
    if (system.isIOS) {
      return [
        '点击下方「导出证书」，通过隔空投送/文件发送到 iPhone',
        '在 iPhone 上打开证书文件，按提示安装描述文件',
        '前往 设置 → 通用 → 关于本机 → 证书信任设置',
        '开启 PigCat MITM CA 的完全信任',
      ];
    }
    return ['当前平台暂无安装引导，可导出证书后手动安装。'];
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'CA 中心',
      isLoading: _loading,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildGuideCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final meta = _meta;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _exists ? Icons.verified : Icons.warning_amber,
                  color: _exists ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _exists ? '根证书已就绪' : '尚未生成根证书',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (meta != null) ...[
              const SizedBox(height: 8),
              Text('创建时间：${meta.createdAt.toString().split('.').first}'),
              Text('有效期至：${meta.expiresAt.toString().split(' ').first}'),
              Text(
                'SHA-256：${meta.sha256.substring(0, 16)}…',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: _generating ? null : _handleGenerate,
                  child: Text(
                    _generating ? '生成中…' : (_exists ? '重新生成' : '生成根证书'),
                  ),
                ),
                if (_exists)
                  OutlinedButton(
                    onPressed: _handleCopy,
                    child: const Text('复制证书'),
                  ),
                if (_exists)
                  OutlinedButton(
                    onPressed: _handleExport,
                    child: const Text('导出证书'),
                  ),
                if (_exists)
                  TextButton(onPressed: _handleDelete, child: const Text('删除')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard() {
    final steps = _installSteps();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '安装与信任引导',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. '),
                    Expanded(child: Text(steps[i])),
                  ],
                ),
              ),
            const Divider(),
            const Text(
              'MITM 解密需要配合模块中的 [MITM] 主机名与重写/脚本规则使用。'
              '解密流量仅在受信任的证书安装后生效。',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
