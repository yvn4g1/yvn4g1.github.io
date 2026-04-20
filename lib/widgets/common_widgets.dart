import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ────────────────────────────────────────────
// 部位カラーを返すユーティリティ
// ────────────────────────────────────────────
Color partColor(String part) {
  switch (part) {
    case 'chest':
      return AppTheme.colorChest;
    case 'back':
      return AppTheme.colorBack;
    case 'legs':
      return AppTheme.colorLegs;
    case 'arms':
      return AppTheme.colorArms;
    case 'shoulders':
      return AppTheme.colorShoulders;
    default:
      return AppTheme.colorCore;
  }
}

// ────────────────────────────────────────────
// ライムグリーン アクセントバッジ
// ────────────────────────────────────────────
class AccentBadge extends StatelessWidget {
  final String text;
  const AccentBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentDim,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.accent,
            letterSpacing: 0.3,
          ),
        ),
      );
}

// ────────────────────────────────────────────
// セクションラベル（大文字・小さめ）
// ────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4, left: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      );
}

// ────────────────────────────────────────────
// 設定トグルスイッチ
// ────────────────────────────────────────────
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.black,
        activeTrackColor: AppTheme.accent,
        inactiveThumbColor: AppTheme.textTertiary,
        inactiveTrackColor: AppTheme.surface3,
      );
}

// ────────────────────────────────────────────
// 汎用カード
// ────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        padding: padding ?? EdgeInsets.zero,
        child: child,
      );
}

// ────────────────────────────────────────────
// 削除確認ダイアログ
// ────────────────────────────────────────────
Future<bool> showDeleteConfirm(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppTheme.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, size: 36, color: AppTheme.danger),
            const SizedBox(height: 12),
            const Text(
              'セットを削除しますか？',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('削除する',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
