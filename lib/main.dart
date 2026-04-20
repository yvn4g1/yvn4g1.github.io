import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';
import 'screens/calendar_screen.dart';
import 'screens/preset_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/training_input_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  runApp(const TrainingLogApp());
}

class TrainingLogApp extends StatelessWidget {
  const TrainingLogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'トレーニング・ログ・ミニマル',
        theme: AppTheme.darkTheme,
        home: const _RootPage(),
        debugShowCheckedModeBanner: false,
      );
}

class _RootPage extends StatefulWidget {
  const _RootPage();
  @override
  State<_RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<_RootPage> {
  int _currentIndex = 0;
  Map<String, TrainingSession> _sessions = {};
  List<PresetFolder> _folders = [];
  String _weightUnit = 'kg';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // トレーニング記録
    final rawSessions = prefs.getString('sessions');
    if (rawSessions != null) {
      final map = jsonDecode(rawSessions) as Map<String, dynamic>;
      _sessions = map.map((k, v) =>
          MapEntry(k, TrainingSession.fromJson(v as Map<String, dynamic>)));
    }

    // プリセット（保存済みがあればそれを、なければデフォルト）
    final rawFolders = prefs.getString('presetFolders');
    if (rawFolders != null) {
      final list = jsonDecode(rawFolders) as List<dynamic>;
      _folders = list
          .map((f) => PresetFolder.fromJson(f as Map<String, dynamic>))
          .toList();
    } else {
      _folders = defaultPresets();
    }

    // 設定
    _weightUnit = prefs.getString('weightUnit') ?? 'kg';

    setState(() => _loaded = true);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // 記録
    final sessionsMap = _sessions.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString('sessions', jsonEncode(sessionsMap));
    // プリセット
    final foldersList = _folders.map((f) => f.toJson()).toList();
    await prefs.setString('presetFolders', jsonEncode(foldersList));
    // 設定
    await prefs.setString('weightUnit', _weightUnit);
  }

  void _onSessionSaved(TrainingSession session) {
    setState(() => _sessions[session.dateKey] = session);
    _saveData();
  }

  void _onUnitChanged(String unit) {
    setState(() => _weightUnit = unit);
    _saveData();
  }

  void _onFoldersChanged(List<PresetFolder> folders) {
    setState(() => _folders = folders);
    _saveData();
  }

  void _onStartSession(List<ExerciseEntry> exercises) {
    final session = TrainingSession(date: DateTime.now(), exercises: exercises);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainingInputScreen(
          session: session,
          onSave: () => _onSessionSaved(session),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC8FF00)),
        ),
      );
    }

    final pages = [
      CalendarScreen(
        sessions: _sessions,
        onSessionSaved: _onSessionSaved,
        folders: _folders,
      ),
      PresetScreen(
        folders: _folders,
        onStartSession: _onStartSession,
        onFoldersChanged: _onFoldersChanged,
      ),
      const TimerScreen(),
      SettingsScreen(
        weightUnit: _weightUnit,
        onUnitChanged: _onUnitChanged,
      ),
    ];

    // PCレイアウト：600px以上のとき中央にスマホ枠を表示
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return _PcFrame(
              child: IndexedStack(index: _currentIndex, children: pages),
              bottomNav: _BottomNav(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: IndexedStack(index: _currentIndex, children: pages),
              ),
              _BottomNav(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────
// PCフレーム（中央にスマホ枠を表示）
// ────────────────────────────────────────────
class _PcFrame extends StatelessWidget {
  final Widget child;
  final Widget bottomNav;
  const _PcFrame({required this.child, required this.bottomNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080808),
      child: Center(
        child: Container(
          width: 390,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppTheme.border2, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(child: child),
              bottomNav,
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────
// ボトムナビゲーションバー
// ────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.calendar_month_outlined, label: 'カレンダー'),
      (icon: Icons.list_alt_outlined, label: 'プリセット'),
      (icon: Icons.timer_outlined, label: 'タイマー'),
      (icon: Icons.person_outline, label: '設定'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 22,
                          color: isActive ? AppTheme.accent : AppTheme.textTertiary),
                      const SizedBox(height: 4),
                      Text(item.label,
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.3,
                              color: isActive
                                  ? AppTheme.accent
                                  : AppTheme.textTertiary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
