import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final String weightUnit; // 'kg' or 'lb'
  final ValueChanged<String> onUnitChanged;

  const SettingsScreen({
    super.key,
    required this.weightUnit,
    required this.onUnitChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = true;
  bool _sound = true;
  int _defaultIntervalSec = 90;

  String get _intervalLabel {
    final m = _defaultIntervalSec ~/ 60;
    final s = _defaultIntervalSec % 60;
    if (s == 0) return '$m分';
    return '$m分$s秒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ナビバー
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  const Text('設定',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  const Spacer(),
                  Text('ver 1.0.0',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textTertiary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  // ── 単位・表示 ─────────────────
                  const SectionLabel('単位・表示'),
                  _SettingsGroup(children: [
                    _SettingRow(
                      title: '重量単位',
                      subtitle: '記録・表示に使う単位',
                      trailing: _UnitSwitch(
                        current: widget.weightUnit,
                        onChanged: widget.onUnitChanged,
                      ),
                    ),
                    _SettingRow(
                      title: '週の開始曜日',
                      subtitle: 'カレンダーの最初の列',
                      trailing: const Row(children: [
                        Text('日曜日',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            color: AppTheme.textTertiary, size: 18),
                      ]),
                    ),
                  ]),

                  // ── タイマー ───────────────────
                  const SectionLabel('タイマー'),
                  _SettingsGroup(children: [
                    _SettingRow(
                      title: 'デフォルトインターバル',
                      subtitle: 'インターバルタイマーの初期値',
                      onTap: _pickInterval,
                      trailing: Row(children: [
                        Text(_intervalLabel,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            color: AppTheme.textTertiary, size: 18),
                      ]),
                    ),
                    _SettingRow(
                      title: 'バイブレーション',
                      subtitle: '終了時に振動で知らせる',
                      onTap: () =>
                          setState(() => _vibration = !_vibration),
                      trailing: AppSwitch(
                        value: _vibration,
                        onChanged: (v) => setState(() => _vibration = v),
                      ),
                    ),
                    _SettingRow(
                      title: '終了音',
                      subtitle: 'タイマー完了時のサウンド',
                      onTap: () => setState(() => _sound = !_sound),
                      trailing: AppSwitch(
                        value: _sound,
                        onChanged: (v) => setState(() => _sound = v),
                      ),
                    ),
                  ]),

                  // ── データ ─────────────────────
                  const SectionLabel('データ'),
                  _SettingsGroup(children: [
                    _SettingRow(
                      title: 'データをエクスポート',
                      subtitle: 'JSON形式で全記録を書き出す',
                      onTap: _exportData,
                      trailing: const Icon(
                          Icons.download_outlined,
                          color: AppTheme.textTertiary, size: 18),
                    ),
                    _SettingRow(
                      title: '全データを削除',
                      subtitle: 'この操作は取り消せません',
                      onTap: _deleteAll,
                      titleColor: AppTheme.danger,
                      trailing: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.danger, size: 18),
                    ),
                  ]),

                  // ── アプリについて ────────────
                  const SectionLabel('アプリについて'),
                  _SettingsGroup(children: [
                    const _SettingRow(
                      title: 'トレーニング・ログ・ミニマル',
                      titleColor: AppTheme.textSecondary,
                      trailing: Text('v1.0.0',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary)),
                    ),
                    _SettingRow(
                      title: 'プライバシーポリシー',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppTheme.textTertiary, size: 18),
                    ),
                  ]),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickInterval() async {
    // 簡易ダイアログでインターバル秒数を選択
    final options = [60, 90, 120, 180, 300];
    final labels = ['60秒', '90秒', '2分', '3分', '5分'];
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('インターバル時間',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ),
            ...List.generate(options.length, (i) => ListTile(
              title: Text(labels[i],
                  style: const TextStyle(color: AppTheme.textPrimary)),
              trailing: _defaultIntervalSec == options[i]
                  ? const Icon(Icons.check, color: AppTheme.accent, size: 18)
                  : null,
              onTap: () => Navigator.pop(ctx, options[i]),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _defaultIntervalSec = picked);
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('エクスポート機能はフェーズ2で実装予定です'),
          backgroundColor: AppTheme.surface3),
    );
  }

  void _deleteAll() async {
    final ok = await showDeleteConfirm(context, '全ての記録が削除されます。\nこの操作は取り消せません。');
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('全データを削除しました'),
            backgroundColor: AppTheme.danger),
      );
    }
  }
}

// ────────────────────────────────────────────
// 設定グループ（角丸カード）
// ────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          children: children.asMap().entries.map((e) {
            final isLast = e.key == children.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast)
                  Container(height: 0.5, color: AppTheme.border),
              ],
            );
          }).toList(),
        ),
      );
}

// ────────────────────────────────────────────
// 設定行
// ────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingRow({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: titleColor ?? AppTheme.textPrimary)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
}

// ────────────────────────────────────────────
// kg / lb 切り替えスイッチ
// ────────────────────────────────────────────
class _UnitSwitch extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _UnitSwitch({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border2, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['kg', 'lb'].map((u) {
            final isOn = current == u;
            return GestureDetector(
              onTap: () => onChanged(u),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: isOn ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(u,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isOn ? Colors.black : AppTheme.textSecondary)),
              ),
            );
          }).toList(),
        ),
      );
}
