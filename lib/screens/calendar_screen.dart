import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'training_input_screen.dart';
import 'preset_screen.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, TrainingSession> sessions;
  final ValueChanged<TrainingSession> onSessionSaved;
  final List<PresetFolder> folders;

  const CalendarScreen({
    super.key,
    required this.sessions,
    required this.onSessionSaved,
    required this.folders,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _showPresetPanel = false;

  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  TrainingSession? get _selectedSession =>
      widget.sessions[_dateKey(_selectedDay)];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: isWide
            ? _buildWideLayout()
            : _buildNarrowLayout(),
      ),
    );
  }

  // ── PC幅：左にカレンダー、右にプリセットパネル ──
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(child: _buildMainColumn()),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: _showPresetPanel ? 340 : 0,
          child: _showPresetPanel
              ? Container(
                  decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: AppTheme.border, width: 0.5)),
                  ),
                  child: _PresetSidePanel(
                    folders: widget.folders,
                    onClose: () => setState(() => _showPresetPanel = false),
                    onStartWithExercises: _startSessionWithExercises,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── スマホ幅：縦積み ──
  Widget _buildNarrowLayout() => _buildMainColumn();

  Widget _buildMainColumn() {
    return Column(
      children: [
        _buildHeader(),
        _buildStreakBanner(),
        _buildCalendar(),
        const SizedBox(height: 8),
        _buildFabRow(),
        const SizedBox(height: 8),
        Expanded(child: _buildDayDetail()),
      ],
    );
  }

  // ── ヘッダー ──────────────────────────────
  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                DateFormat('M月', 'ja').format(_focusedMonth),
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5),
              ),
              Text(_focusedMonth.year.toString(),
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
            ]),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border2, width: 0.5),
              ),
              child: Row(children: [
                _NavArrow(
                  icon: Icons.chevron_left,
                  onTap: () => setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1);
                  }),
                ),
                _NavArrow(
                  icon: Icons.chevron_right,
                  onTap: () => setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1);
                  }),
                ),
              ]),
            ),
          ],
        ),
      );

  // ── ストリークバナー ──────────────────────
  Widget _buildStreakBanner() {
    final streak = _calcStreak();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.accent.withOpacity(0.2), width: 0.5),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('STREAK',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5)),
          Row(children: [
            Text(streak.toString(),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent)),
            const SizedBox(width: 4),
            const Text('days',
                style:
                    TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ]),
        const Spacer(),
        Row(
          children: List.generate(7, (i) {
            final day = DateTime.now().subtract(Duration(days: 6 - i));
            final has = widget.sessions.containsKey(_dateKey(day));
            return Container(
              margin: const EdgeInsets.only(left: 4),
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: has ? AppTheme.accent : AppTheme.surface3,
              ),
            );
          }),
        ),
      ]),
    );
  }

  // ── カレンダーグリッド ────────────────────
  Widget _buildCalendar() {
    const dowLabels = ['日', '月', '火', '水', '木', '金', '土'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(
          children: dowLabels
              .map((d) => Expanded(
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                            letterSpacing: 0.5)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 0.9,
          ),
          itemCount: 42,
          itemBuilder: (context, index) => _buildDayCell(index),
        ),
      ]),
    );
  }

  Widget _buildDayCell(int index) {
    final firstDow =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final daysInPrev =
        DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;

    late DateTime cellDate;
    bool isOtherMonth = false;

    if (index < firstDow) {
      cellDate = DateTime(_focusedMonth.year, _focusedMonth.month - 1,
          daysInPrev - firstDow + index + 1);
      isOtherMonth = true;
    } else if (index < firstDow + daysInMonth) {
      cellDate = DateTime(
          _focusedMonth.year, _focusedMonth.month, index - firstDow + 1);
    } else {
      cellDate = DateTime(_focusedMonth.year, _focusedMonth.month + 1,
          index - firstDow - daysInMonth + 1);
      isOtherMonth = true;
    }

    final key = _dateKey(cellDate);
    final isToday = key == _dateKey(DateTime.now());
    final isSelected = key == _dateKey(_selectedDay);
    final session = widget.sessions[key];
    final parts =
        session?.exercises.map((e) => e.part).toSet().toList() ?? [];

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = cellDate),
      // 長押しでその日の記録を直接編集
      onLongPress: () => _openOrEditSession(cellDate),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday ? AppTheme.accent : Colors.transparent,
            ),
            child: Center(
              child: Text(
                cellDate.day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  color: isToday
                      ? Colors.black
                      : isOtherMonth
                          ? AppTheme.textTertiary
                          : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: parts.take(3).map((p) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: partColor(p)),
                )).toList(),
          ),
        ]),
      ),
    );
  }

  // ── FABエリア ────────────────────────────
  Widget _buildFabRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // プリセットパネルトグル（PC幅のみ表示）
            if (MediaQuery.of(context).size.width >= 600)
              GestureDetector(
                onTap: () =>
                    setState(() => _showPresetPanel = !_showPresetPanel),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _showPresetPanel
                        ? AppTheme.accentDim
                        : AppTheme.surface2,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _showPresetPanel
                          ? AppTheme.accent
                          : AppTheme.border2,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(Icons.list_alt_outlined,
                      color: _showPresetPanel
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      size: 22),
                ),
              ),
            // 記録追加FAB
            GestureDetector(
              onTap: () => _openOrEditSession(_selectedDay),
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTheme.accent),
                child: const Icon(Icons.add, color: Colors.black, size: 26),
              ),
            ),
          ],
        ),
      );

  // ── 選択日詳細パネル ──────────────────────
  Widget _buildDayDetail() {
    final session = _selectedSession;
    final dow = ['日', '月', '火', '水', '木', '金', '土'];
    final label =
        '${_selectedDay.month}月${_selectedDay.day}日（${dow[_selectedDay.weekday % 7]}）';
    final isToday = _dateKey(_selectedDay) == _dateKey(DateTime.now());

    return GestureDetector(
      // パネルタップで編集画面へ
      onTap: session != null ? () => _openOrEditSession(_selectedDay) : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // パネルヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppTheme.border, width: 0.5)),
              ),
              child: Row(children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (isToday) const AccentBadge('本日'),
                if (session != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_outlined,
                      size: 14, color: AppTheme.textTertiary),
                ],
              ]),
            ),
            // コンテンツ
            if (session == null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const Text('記録なし',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textTertiary)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openOrEditSession(_selectedDay),
                    child: const Text('＋ タップして記録を追加',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.accent)),
                  ),
                ]),
              )
            else
              ...session.exercises
                  .map((ex) => _ExerciseSummaryRow(exercise: ex)),
          ],
        ),
      ),
    );
  }

  // ── セッション開く / 編集 ─────────────────
  void _openOrEditSession(DateTime day) {
    final key = _dateKey(day);
    final session =
        widget.sessions[key] ?? TrainingSession(date: day);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainingInputScreen(
          session: session,
          onSave: () {
            widget.onSessionSaved(session);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _startSessionWithExercises(List<ExerciseEntry> exercises) {
    final session = TrainingSession(
        date: _selectedDay, exercises: exercises);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainingInputScreen(
          session: session,
          onSave: () {
            widget.onSessionSaved(session);
            setState(() {});
          },
        ),
      ),
    );
  }

  int _calcStreak() {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      if (widget.sessions.containsKey(_dateKey(day))) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}

// ────────────────────────────────────────────
// 種目サマリー行
// ────────────────────────────────────────────
class _ExerciseSummaryRow extends StatelessWidget {
  final ExerciseEntry exercise;
  const _ExerciseSummaryRow({required this.exercise});

  String get _summary {
    switch (exercise.inputType) {
      case 'repsOnly':
        final total =
            exercise.sets.fold(0, (s, e) => s + e.reps);
        return '合計 ${total}rep';
      case 'timeOnly':
        final total =
            exercise.sets.fold(0, (s, e) => s + e.seconds);
        final m = total ~/ 60;
        final sec = total % 60;
        return '合計 $m:${sec.toString().padLeft(2, '0')}';
      default:
        final vol = exercise.sets
            .fold(0.0, (s, e) => s + e.weight * e.reps);
        return '${vol.toInt()}kg';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: Row(children: [
          Container(
            width: 3, height: 32,
            decoration: BoxDecoration(
              color: partColor(exercise.part),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${exercise.sets.length}セット',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ]),
          ),
          Text(_summary,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              color: AppTheme.textTertiary, size: 18),
        ]),
      );
}

// ────────────────────────────────────────────
// PCサイドパネル（プリセット選択）
// ────────────────────────────────────────────
class _PresetSidePanel extends StatefulWidget {
  final List<PresetFolder> folders;
  final VoidCallback onClose;
  final ValueChanged<List<ExerciseEntry>> onStartWithExercises;

  const _PresetSidePanel({
    required this.folders,
    required this.onClose,
    required this.onStartWithExercises,
  });

  @override
  State<_PresetSidePanel> createState() => _PresetSidePanelState();
}

class _PresetSidePanelState extends State<_PresetSidePanel> {
  int _tabIdx = 0;
  final List<PresetExercise> _selected = [];

  PresetFolder get _folder => widget.folders[_tabIdx];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(children: [
              const Text('プリセット',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close,
                    color: AppTheme.textSecondary, size: 20),
              ),
            ]),
          ),

          // タブ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: widget.folders.asMap().entries.map((e) {
                final isActive = e.key == _tabIdx;
                final color = partColor(e.value.part);
                return GestureDetector(
                  onTap: () => setState(() => _tabIdx = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.accentDim : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? color : AppTheme.border2,
                        width: 0.5,
                      ),
                    ),
                    child: Text(e.value.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? color : AppTheme.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // 種目リスト
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: _folder.exercises.map((ex) {
                final isSel = _selected.any((s) => s.id == ex.id);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSel) {
                      _selected.removeWhere((s) => s.id == ex.id);
                    } else {
                      _selected.add(ex);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppTheme.accentDim
                          : AppTheme.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel
                            ? partColor(ex.part)
                            : AppTheme.border,
                        width: 0.5,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 3, height: 32,
                        decoration: BoxDecoration(
                          color: partColor(ex.part),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(ex.meta,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary)),
                            ]),
                      ),
                      if (isSel)
                        const Icon(Icons.check_circle,
                            color: AppTheme.accent, size: 16),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),

          // 開始ボタン
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        final entries = _selected
                            .map((ex) => ExerciseEntry(
                                  name: ex.name,
                                  part: ex.part,
                                  inputType: ex.inputType,
                                  unit1: ex.unit1,
                                  unit2: ex.unit2,
                                ))
                            .toList();
                        widget.onStartWithExercises(entries);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppTheme.surface3,
                  disabledForegroundColor: AppTheme.textTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _selected.isEmpty
                      ? '種目を選択してください'
                      : '${_selected.length}種目で記録開始',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ────────────────────────────────────────────
// 月ナビ矢印
// ────────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 32, height: 32,
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
      );
}
