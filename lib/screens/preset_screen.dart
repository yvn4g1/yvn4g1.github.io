import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class PresetScreen extends StatefulWidget {
  final List<PresetFolder> folders;
  final ValueChanged<List<ExerciseEntry>> onStartSession;
  final ValueChanged<List<PresetFolder>> onFoldersChanged;

  const PresetScreen({
    super.key,
    required this.folders,
    required this.onStartSession,
    required this.onFoldersChanged,
  });

  @override
  State<PresetScreen> createState() => _PresetScreenState();
}

class _PresetScreenState extends State<PresetScreen> {
  int _activeTabIdx = 0;
  final List<PresetExercise> _todayMenu = [];
  bool _editMode = false;

  PresetFolder get _activeFolder => widget.folders[_activeTabIdx];
  Color get _activeColor => partColor(_activeFolder.part);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavBar(),
            _buildTabBar(),
            const SizedBox(height: 10),
            _buildTodayPanel(),
            Expanded(child: _buildExerciseList()),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
        child: Row(
          children: [
            const Text('プリセット',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _editMode = !_editMode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _editMode ? AppTheme.accentDim : AppTheme.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _editMode ? AppTheme.accent : AppTheme.border2,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _editMode ? '完了' : '編集',
                  style: TextStyle(
                    fontSize: 13,
                    color: _editMode ? AppTheme.accent : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildTabBar() => Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ...widget.folders.asMap().entries.map((e) {
                final i = e.key;
                final folder = e.value;
                final isActive = i == _activeTabIdx;
                final color = partColor(folder.part);
                return GestureDetector(
                  onTap: () => setState(() => _activeTabIdx = i),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 7, right: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      folder.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? color : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: _addFolder,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 6),
                  child: Icon(Icons.add, color: AppTheme.textTertiary, size: 20),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTodayPanel() => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  const Text('今日のメニュー',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                  const Spacer(),
                  AccentBadge('${_todayMenu.length}種目'),
                ],
              ),
            ),
            if (_todayMenu.isEmpty)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text('種目を選んで追加してください',
                    style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
              )
            else
              ..._todayMenu.asMap().entries.map((e) {
                final i = e.key;
                final ex = e.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i < _todayMenu.length - 1
                            ? AppTheme.border
                            : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: partColor(ex.part)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(ex.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      // inputTypeバッジ
                      _InputTypeBadge(ex.inputType),
                      const SizedBox(width: 6),
                      Text(String.fromCharCode(65 + i),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textTertiary)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _todayMenu.removeAt(i)),
                        child: const Icon(Icons.close,
                            size: 18, color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );

  Widget _buildExerciseList() {
    final exercises = _activeFolder.exercises;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      children: [
        SectionLabel('${_activeFolder.label}の種目'),
        ...(_editMode
            ? _buildEditableList(exercises)
            : exercises.map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ExerciseCard(
                    exercise: ex,
                    isSelected: _todayMenu.any((m) => m.id == ex.id),
                    activeColor: _activeColor,
                    onTap: () => _toggleExercise(ex),
                    onLongPress: () => _openEditDialog(ex),
                  ),
                )).toList()),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _addExercise,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border2, width: 0.5),
            ),
            child: const Text('+ 新しい種目を追加',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _buildEditableList(List<PresetExercise> exercises) {
    return exercises.asMap().entries.map((e) {
      final ex = e.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.drag_handle, color: AppTheme.textTertiary, size: 20),
              const SizedBox(width: 4),
              Container(
                width: 3, height: 36,
                decoration: BoxDecoration(
                  color: partColor(ex.part),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(ex.meta,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
              // 編集ボタン
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.textSecondary, size: 18),
                onPressed: () => _openEditDialog(ex),
              ),
              // 削除ボタン
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.danger, size: 18),
                onPressed: () {
                  setState(() => _activeFolder.exercises.remove(ex));
                  widget.onFoldersChanged(widget.folders);
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStartButton() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _todayMenu.isEmpty ? null : _startSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppTheme.surface3,
              disabledForegroundColor: AppTheme.textTertiary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('記録を開始する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      );

  // ── 種目編集ダイアログ ────────────────────
  Future<void> _openEditDialog(PresetExercise ex) async {
    final nameCtrl = TextEditingController(text: ex.name);
    final metaCtrl = TextEditingController(text: ex.meta);
    String inputType = ex.inputType;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: AppTheme.surface2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('種目を編集',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                // 種目名
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDeco('種目名'),
                ),
                const SizedBox(height: 10),
                // メタ情報
                TextField(
                  controller: metaCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDeco('種別（例: バーベル・コンパウンド）'),
                ),
                const SizedBox(height: 14),
                // 入力タイプ選択
                const Text('記録タイプ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                const SizedBox(height: 8),
                ...[
                  ('weightAndReps', '重量 + 回数', 'ベンチプレス・スクワット等'),
                  ('repsOnly', '回数のみ', '懸垂・ディップス等の自重'),
                  ('timeOnly', '時間のみ', 'プランク等'),
                ].map((opt) => GestureDetector(
                      onTap: () => setDlg(() => inputType = opt.$1),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: inputType == opt.$1
                              ? AppTheme.accentDim
                              : AppTheme.surface3,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: inputType == opt.$1
                                ? AppTheme.accent
                                : Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opt.$2,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: inputType == opt.$1
                                              ? AppTheme.accent
                                              : AppTheme.textPrimary)),
                                  Text(opt.$3,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textTertiary)),
                                ],
                              ),
                            ),
                            if (inputType == opt.$1)
                              const Icon(Icons.check_circle,
                                  color: AppTheme.accent, size: 16),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
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
                      onPressed: () {
                        setState(() {
                          ex.name = nameCtrl.text.trim().isEmpty
                              ? ex.name
                              : nameCtrl.text.trim();
                          ex.meta = metaCtrl.text.trim();
                          ex.inputType = inputType;
                          ex.unit1 = inputType == 'weightAndReps' ? 'kg' : '';
                          ex.unit2 = inputType == 'timeOnly' ? 'min' : 'rep';
                        });
                        widget.onFoldersChanged(widget.folders);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('保存',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
    nameCtrl.dispose();
    metaCtrl.dispose();
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
        filled: true,
        fillColor: AppTheme.surface3,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );

  void _toggleExercise(PresetExercise ex) {
    setState(() {
      final idx = _todayMenu.indexWhere((m) => m.id == ex.id);
      if (idx >= 0) {
        _todayMenu.removeAt(idx);
      } else {
        _todayMenu.add(ex);
      }
    });
  }

  void _startSession() {
    final entries = _todayMenu
        .map((pre) => ExerciseEntry(
              name: pre.name,
              part: pre.part,
              inputType: pre.inputType,
              unit1: pre.unit1,
              unit2: pre.unit2,
            ))
        .toList();
    widget.onStartSession(entries);
  }

  void _addFolder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('タブの追加は今後実装予定です'),
        backgroundColor: AppTheme.surface3,
      ),
    );
  }

  void _addExercise() {
    final newEx = PresetExercise(
      name: '新しい種目',
      part: _activeFolder.part,
      meta: '',
    );
    setState(() => _activeFolder.exercises.add(newEx));
    widget.onFoldersChanged(widget.folders);
    // 追加直後に編集ダイアログを開く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openEditDialog(newEx);
    });
  }
}

// ────────────────────────────────────────────
// inputType バッジ
// ────────────────────────────────────────────
class _InputTypeBadge extends StatelessWidget {
  final String inputType;
  const _InputTypeBadge(this.inputType);

  @override
  Widget build(BuildContext context) {
    String label;
    switch (inputType) {
      case 'repsOnly':
        label = '回数';
        break;
      case 'timeOnly':
        label = '時間';
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surface3,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
    );
  }
}

// ────────────────────────────────────────────
// 種目カード
// ────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final PresetExercise exercise;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : AppTheme.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3, height: 48,
                margin: const EdgeInsets.only(left: 14),
                decoration: BoxDecoration(
                  color: partColor(exercise.part),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Row(children: [
                        Text(exercise.meta,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 6),
                        _InputTypeBadge(exercise.inputType),
                      ]),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 14),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? activeColor : AppTheme.border2,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      );
}
