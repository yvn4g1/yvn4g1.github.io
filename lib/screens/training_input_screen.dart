import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/drum_picker.dart';

class TrainingInputScreen extends StatefulWidget {
  final TrainingSession session;
  final VoidCallback onSave;

  const TrainingInputScreen({
    super.key,
    required this.session,
    required this.onSave,
  });

  @override
  State<TrainingInputScreen> createState() => _TrainingInputScreenState();
}

class _TrainingInputScreenState extends State<TrainingInputScreen> {
  late TrainingSession _session;
  final _setLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    if (_session.exercises.isEmpty) {
      _session.exercises.add(ExerciseEntry(name: '新しい種目', part: 'chest'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ),
        leadingWidth: 80,
        title: const Text('今日の記録'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('保存',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ..._session.exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final ex = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                exercise: ex,
                letter: _setLetters[idx % 26],
                onUpdate: () => setState(() {}),
              ),
            );
          }),
          _AddExerciseButton(onTap: _addExercise),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _addExercise() {
    setState(() {
      _session.exercises.add(ExerciseEntry(name: '新しい種目', part: 'chest'));
    });
  }

  void _save() {
    widget.onSave();
    Navigator.pop(context);
  }
}

// ────────────────────────────────────────────
// 種目カード
// ────────────────────────────────────────────
class _ExerciseCard extends StatefulWidget {
  final ExerciseEntry exercise;
  final String letter;
  final VoidCallback onUpdate;

  const _ExerciseCard({
    required this.exercise,
    required this.letter,
    required this.onUpdate,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late TextEditingController _memoCtrl;

  @override
  void initState() {
    super.initState();
    _memoCtrl = TextEditingController(text: widget.exercise.memo);
  }

  @override
  void dispose() {
    _memoCtrl.dispose();
    super.dispose();
  }

  Color get _partColor => partColor(widget.exercise.part);
  String get _inputType => widget.exercise.inputType;

  // セットヘッダーのラベルを inputType に合わせて変える
  String get _col1Label {
    switch (_inputType) {
      case 'repsOnly': return '回数';
      case 'timeOnly': return '時間';
      default: return '重量';
    }
  }
  String get _col2Label => _inputType == 'weightAndReps' ? '回数' : '';

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('種目 ${widget.letter}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 2),
                      Text(ex.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                AccentBadge(_partLabel(ex.part)),
              ],
            ),
          ),

          Container(height: 0.5, color: AppTheme.border),

          // テーブルヘッダー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              _HeaderCell('Set', flex: 2),
              _HeaderCell(_col1Label, flex: 3),
              if (_inputType == 'weightAndReps') _HeaderCell(_col2Label, flex: 3),
              _HeaderCell('Copy', flex: 2),
              const SizedBox(width: 36),
            ]),
          ),

          // セットリスト
          ...ex.sets.asMap().entries.map((entry) {
            final si = entry.key;
            final set = entry.value;
            return _SetRow(
              setLabel: '${widget.letter}-${si + 1}',
              set: set,
              inputType: _inputType,
              isFirst: si == 0,
              isLast: si == ex.sets.length - 1,
              onTapPrimary: () => _openPrimaryPicker(si),
              onTapSecondary: _inputType == 'weightAndReps'
                  ? () => _openRepsPicker(si)
                  : null,
              onCopy: () => _copySet(si),
              onDelete: () => _deleteSet(si),
            );
          }),

          // セット追加ボタン
          InkWell(
            onTap: _addSet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppTheme.border, width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: _partColor, size: 16),
                  const SizedBox(width: 6),
                  Text('セットを追加',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _partColor)),
                ],
              ),
            ),
          ),

          // メモ
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _memoCtrl,
              onChanged: (v) => widget.exercise.memo = v,
              maxLines: 2,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              decoration: InputDecoration(
                hintText: 'メモ（フォーム・調子など）',
                hintStyle: const TextStyle(
                    color: AppTheme.textTertiary, fontSize: 13),
                filled: true,
                fillColor: AppTheme.surface2,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.border2, width: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // メインPicker（inputTypeに応じて切り替え）
  Future<void> _openPrimaryPicker(int si) async {
    switch (_inputType) {
      case 'weightAndReps':
        final result = await showWeightPicker(
            context, widget.exercise.sets[si].weight);
        if (result != null) {
          setState(() => widget.exercise.sets[si].weight = result);
        }
        break;
      case 'repsOnly':
        final result =
            await showRepsPicker(context, widget.exercise.sets[si].reps);
        if (result != null) {
          setState(() => widget.exercise.sets[si].reps = result);
        }
        break;
      case 'timeOnly':
        final result =
            await showSecondsPicker(context, widget.exercise.sets[si].seconds);
        if (result != null) {
          setState(() => widget.exercise.sets[si].seconds = result);
        }
        break;
    }
  }

  Future<void> _openRepsPicker(int si) async {
    final result =
        await showRepsPicker(context, widget.exercise.sets[si].reps);
    if (result != null) {
      setState(() => widget.exercise.sets[si].reps = result);
    }
  }

  void _copySet(int si) {
    if (si == 0) return;
    setState(() {
      final prev = widget.exercise.sets[si - 1];
      widget.exercise.sets[si] = widget.exercise.sets[si].copyWith(
        weight: prev.weight,
        reps: prev.reps,
        seconds: prev.seconds,
      );
    });
  }

  Future<void> _deleteSet(int si) async {
    if (widget.exercise.sets.length <= 1) return;
    final ok = await showDeleteConfirm(
        context, 'この操作は取り消せません。\n記録したデータが失われます。');
    if (ok) {
      setState(() => widget.exercise.sets.removeAt(si));
    }
  }

  void _addSet() {
    setState(() {
      final last = widget.exercise.sets.last;
      widget.exercise.sets.add(
        TrainingSet(
          weight: last.weight,
          reps: last.reps,
          seconds: last.seconds,
        ),
      );
    });
  }

  String _partLabel(String part) {
    const map = {
      'chest': '胸', 'back': '背中', 'legs': '脚',
      'arms': '腕', 'shoulders': '肩', 'core': '体幹',
    };
    return map[part] ?? part;
  }
}

// ────────────────────────────────────────────
// テーブルヘッダーセル
// ────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textTertiary,
                letterSpacing: 0.8)),
      );
}

// ────────────────────────────────────────────
// 1セット行（inputTypeに応じて列を切り替え）
// ────────────────────────────────────────────
class _SetRow extends StatefulWidget {
  final String setLabel;
  final TrainingSet set;
  final String inputType;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTapPrimary;
  final VoidCallback? onTapSecondary;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _SetRow({
    required this.setLabel,
    required this.set,
    required this.inputType,
    required this.isFirst,
    required this.isLast,
    required this.onTapPrimary,
    this.onTapSecondary,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  bool _copied = false;

  String get _primaryLabel {
    switch (widget.inputType) {
      case 'repsOnly':
        return widget.set.reps.toString();
      case 'timeOnly':
        final m = widget.set.seconds ~/ 60;
        final s = widget.set.seconds % 60;
        return '$m:${s.toString().padLeft(2, '0')}';
      default:
        final w = widget.set.weight;
        return w % 1 == 0 ? w.toInt().toString() : w.toStringAsFixed(1);
    }
  }

  String get _primaryUnit {
    switch (widget.inputType) {
      case 'repsOnly': return 'rep';
      case 'timeOnly': return 'min';
      default: return 'kg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isLast
            ? AppTheme.accent.withOpacity(0.04)
            : Colors.transparent,
        border:
            Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // セット番号
          Expanded(
            flex: 2,
            child: Text(widget.setLabel,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w600)),
          ),

          // メイン値（重量 or 回数 or 時間）
          Expanded(
            flex: 3,
            child: _ValueTap(
              value: _primaryLabel,
              unit: _primaryUnit,
              onTap: widget.onTapPrimary,
            ),
          ),

          // 回数列（weightAndRepsのみ）
          if (widget.inputType == 'weightAndReps') ...[
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: _ValueTap(
                value: widget.set.reps.toString(),
                unit: 'rep',
                onTap: widget.onTapSecondary ?? () {},
              ),
            ),
          ] else
            const Expanded(flex: 3, child: SizedBox()),

          const SizedBox(width: 4),

          // コピーボタン
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: widget.isFirst
                  ? null
                  : () {
                      widget.onCopy();
                      setState(() => _copied = true);
                      Future.delayed(
                          const Duration(milliseconds: 1200),
                          () => setState(() => _copied = false));
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _copied ? AppTheme.accentDim : Colors.transparent,
                  border: Border.all(
                    color: _copied ? AppTheme.accent : AppTheme.border2,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _copied ? '✓' : '↑',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isFirst
                        ? AppTheme.textTertiary.withOpacity(0.3)
                        : (_copied
                            ? AppTheme.accent
                            : AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 削除ボタン
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: widget.onDelete,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close,
                  size: 18, color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────
// 数値タップセル
// ────────────────────────────────────────────
class _ValueTap extends StatelessWidget {
  final String value;
  final String unit;
  final VoidCallback onTap;

  const _ValueTap(
      {required this.value, required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textTertiary)),
            ],
          ),
        ),
      );
}

// ────────────────────────────────────────────
// 種目追加ボタン
// ────────────────────────────────────────────
class _AddExerciseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddExerciseButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border2, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: AppTheme.textSecondary, size: 18),
              SizedBox(width: 8),
              Text('種目を追加 / プリセットから選ぶ',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
}
