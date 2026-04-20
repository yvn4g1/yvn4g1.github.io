import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ────────────────────────────────────────────
// ドラムロール Picker ボトムシート
// 重量（0〜200kg、2.5刻み）または回数（1〜30）を選択
// ────────────────────────────────────────────

enum PickerMode { weight, reps }

Future<double?> showWeightPicker(
    BuildContext context, double initialValue) async {
  return showPickerSheet(
    context: context,
    mode: PickerMode.weight,
    initialDouble: initialValue,
  );
}

Future<int?> showRepsPicker(BuildContext context, int initialValue) async {
  final result = await showPickerSheet(
    context: context,
    mode: PickerMode.reps,
    initialInt: initialValue,
  );
  return result?.toInt();
}

Future<double?> showPickerSheet({
  required BuildContext context,
  required PickerMode mode,
  double? initialDouble,
  int? initialInt,
}) {
  return showModalBottomSheet<double>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PickerSheet(
      mode: mode,
      initialDouble: initialDouble ?? 60.0,
      initialInt: initialInt ?? 10,
    ),
  );
}

class _PickerSheet extends StatefulWidget {
  final PickerMode mode;
  final double initialDouble;
  final int initialInt;

  const _PickerSheet({
    required this.mode,
    required this.initialDouble,
    required this.initialInt,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  // 重量リスト: 0.0, 2.5, 5.0 ... 200.0
  static final List<double> _weightValues = List.generate(
    81,
    (i) => i * 2.5,
  );

  // 回数リスト: 1〜30
  static final List<int> _repValues = List.generate(30, (i) => i + 1);

  late FixedExtentScrollController _ctrl;
  late double _selectedWeight;
  late int _selectedReps;

  @override
  void initState() {
    super.initState();
    if (widget.mode == PickerMode.weight) {
      _selectedWeight = widget.initialDouble;
      final idx = _weightValues.indexWhere((v) => v == widget.initialDouble);
      _ctrl = FixedExtentScrollController(initialItem: idx < 0 ? 0 : idx);
    } else {
      _selectedReps = widget.initialInt;
      final idx = widget.initialInt - 1;
      _ctrl = FixedExtentScrollController(initialItem: idx < 0 ? 0 : idx);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _title =>
      widget.mode == PickerMode.weight ? '重量を選択' : '回数を選択';
  String get _unit => widget.mode == PickerMode.weight ? 'kg' : 'rep';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ナビバー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                Text(_title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                TextButton(
                  onPressed: _onDone,
                  child: const Text('完了',
                      style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ],
            ),
          ),

          // ドラムロール本体
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ハイライトバー
                Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.accent, width: 0.5),
                  ),
                ),

                // 上フェード
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 72,
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1C1C1C), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),

                // 下フェード
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 72,
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF1C1C1C), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),

                // ピッカー + 単位ラベル
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      child: CupertinoPicker(
                        scrollController: _ctrl,
                        itemExtent: 44,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (i) {
                          if (widget.mode == PickerMode.weight) {
                            _selectedWeight = _weightValues[i];
                          } else {
                            _selectedReps = _repValues[i];
                          }
                        },
                        children: widget.mode == PickerMode.weight
                            ? _weightValues
                                .map((v) => _PickerItem(
                                    v % 1 == 0
                                        ? v.toInt().toString()
                                        : v.toStringAsFixed(1)))
                                .toList()
                            : _repValues
                                .map((v) => _PickerItem(v.toString()))
                                .toList(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _unit,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _onDone() {
    if (widget.mode == PickerMode.weight) {
      Navigator.pop(context, _selectedWeight);
    } else {
      Navigator.pop(context, _selectedReps.toDouble());
    }
  }
}

// ────────────────────────────────────────────
// 各アイテムのテキスト
// ────────────────────────────────────────────
class _PickerItem extends StatelessWidget {
  final String text;
  const _PickerItem(this.text);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      );
}

// ────────────────────────────────────────────
// 時間Picker（timeOnly用）: 分(0〜30) × 秒(0,15,30,45)
// 戻り値は秒数（int）
// ────────────────────────────────────────────
Future<int?> showSecondsPicker(BuildContext context, int initialSeconds) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TimePickerSheet(initialSeconds: initialSeconds),
  );
}

class _TimePickerSheet extends StatefulWidget {
  final int initialSeconds;
  const _TimePickerSheet({required this.initialSeconds});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  static final List<int> _minutes = List.generate(31, (i) => i);
  static const List<int> _secs = [0, 15, 30, 45];

  late FixedExtentScrollController _minCtrl;
  late FixedExtentScrollController _secCtrl;
  late int _selectedMin;
  late int _selectedSec;

  @override
  void initState() {
    super.initState();
    _selectedMin = widget.initialSeconds ~/ 60;
    _selectedSec = (widget.initialSeconds % 60);
    // 最近い秒にスナップ
    final secIdx = _secs.indexWhere((s) => s >= _selectedSec);
    _selectedSec = _secs[secIdx < 0 ? _secs.length - 1 : secIdx];
    _minCtrl = FixedExtentScrollController(initialItem: _selectedMin);
    _secCtrl = FixedExtentScrollController(
        initialItem: _secs.indexOf(_selectedSec));
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル',
                      style: TextStyle(color: Color(0xFF999999))),
                ),
                const Text('時間を選択',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0F0F0))),
                TextButton(
                  onPressed: () => Navigator.pop(
                      context, _selectedMin * 60 + _selectedSec),
                  child: const Text('完了',
                      style: TextStyle(
                          color: Color(0xFFC8FF00),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0x1FC8FF00),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFC8FF00), width: 0.5),
                  ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0, height: 72,
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1C1C1C), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 72,
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF1C1C1C), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 分
                    SizedBox(
                      width: 100,
                      child: CupertinoPicker(
                        scrollController: _minCtrl,
                        itemExtent: 44,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (i) =>
                            _selectedMin = _minutes[i],
                        children: _minutes
                            .map((m) => Center(
                                  child: Text('$m',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF0F0F0))),
                                ))
                            .toList(),
                      ),
                    ),
                    const Text('分',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF999999))),
                    const SizedBox(width: 8),
                    // 秒
                    SizedBox(
                      width: 80,
                      child: CupertinoPicker(
                        scrollController: _secCtrl,
                        itemExtent: 44,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (i) =>
                            _selectedSec = _secs[i],
                        children: _secs
                            .map((s) => Center(
                                  child: Text(
                                      s.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF0F0F0))),
                                ))
                            .toList(),
                      ),
                    ),
                    const Text('秒',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF999999))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
