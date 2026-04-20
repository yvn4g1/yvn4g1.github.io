import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  // プリセット一覧 (秒)
  static const _presets = [
    (label: '60秒', sec: 60),
    (label: '90秒', sec: 90),
    (label: '2分', sec: 120),
    (label: '3分', sec: 180),
    (label: '5分', sec: 300),
  ];

  int _activePreset = 1; // 90秒をデフォルト
  int _totalSec = 90;
  int _remainSec = 90;
  bool _running = false;
  Timer? _timer;
  int _currentSet = 0;
  static const _totalSets = 4;

  // リングアニメーション
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _ringAnim = _ringCtrl;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringCtrl.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remainSec ~/ 60;
    final s = _remainSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _phaseLabel {
    if (!_running && _remainSec == _totalSec) return '準備完了';
    if (_running) return 'カウント中';
    if (_remainSec == 0) return '完了！';
    return '一時停止';
  }

  double get _progress =>
      _totalSec > 0 ? _remainSec / _totalSec : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            _buildPresetRow(),
            const SizedBox(height: 10),
            _buildRing(),
            const SizedBox(height: 16),
            _buildSetPips(),
            const SizedBox(height: 20),
            _buildControls(),
            const SizedBox(height: 16),
            _buildAdjustRow(),
          ],
        ),
      ),
    );
  }

  // ── ナビバー ─────────────────────────────
  Widget _buildNavBar() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Row(
          children: [
            const Text('タイマー',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
            const Spacer(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border2, width: 0.5),
              ),
              child: const Icon(Icons.history,
                  color: AppTheme.textSecondary, size: 18),
            ),
          ],
        ),
      );

  // ── プリセット行 ──────────────────────────
  Widget _buildPresetRow() => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _presets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final isActive = i == _activePreset;
            return GestureDetector(
              onTap: () => _selectPreset(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accentDim : AppTheme.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppTheme.accent : AppTheme.border2,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _presets[i].label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isActive ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      );

  // ── リング ───────────────────────────────
  Widget _buildRing() => SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // リングペイント
            CustomPaint(
              size: const Size(220, 220),
              painter: _RingPainter(progress: _progress),
            ),
            // 中央テキスト
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeLabel,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text('INTERVAL',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  _phaseLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ── セット進捗ドット ──────────────────────
  Widget _buildSetPips() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSets, (i) {
          final isDone = i < _currentSet;
          final isCurrent = i == _currentSet;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone || isCurrent
                  ? AppTheme.accent
                  : AppTheme.surface3,
              border: isCurrent
                  ? Border.all(
                      color: AppTheme.accent.withOpacity(0.35), width: 2.5)
                  : null,
            ),
          );
        }),
      );

  // ── コントロール ─────────────────────────
  Widget _buildControls() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // リセット
          _CtrlButton(
            icon: Icons.replay_rounded,
            onTap: _reset,
          ),
          const SizedBox(width: 14),
          // 再生 / 一時停止（大）
          GestureDetector(
            onTap: _toggleTimer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent,
              ),
              child: Icon(
                _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // スキップ
          _CtrlButton(
            icon: Icons.skip_next_rounded,
            onTap: _skip,
          ),
        ],
      );

  // ── 時間調整ボタン ────────────────────────
  Widget _buildAdjustRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _AdjBtn(label: '－15秒', onTap: () => _adjust(-15)),
            const SizedBox(width: 8),
            _AdjBtn(label: '－30秒', onTap: () => _adjust(-30)),
            const SizedBox(width: 8),
            _AdjBtn(label: '＋30秒', onTap: () => _adjust(30)),
            const SizedBox(width: 8),
            _AdjBtn(label: '＋1分', onTap: () => _adjust(60)),
          ],
        ),
      );

  // ── ロジック ─────────────────────────────
  void _selectPreset(int i) {
    _timer?.cancel();
    setState(() {
      _activePreset = i;
      _totalSec = _presets[i].sec;
      _remainSec = _totalSec;
      _running = false;
    });
  }

  void _toggleTimer() {
    if (_remainSec == 0) {
      setState(() => _remainSec = _totalSec);
    }
    setState(() => _running = !_running);
    if (_running) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _remainSec--;
          if (_remainSec <= 0) {
            _remainSec = 0;
            _running = false;
            _timer?.cancel();
            if (_currentSet < _totalSets - 1) _currentSet++;
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainSec = _totalSec;
    });
  }

  void _skip() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainSec = 0;
      if (_currentSet < _totalSets - 1) _currentSet++;
    });
  }

  void _adjust(int delta) {
    setState(() {
      _remainSec = (_remainSec + delta).clamp(0, 3600);
      if (!_running) _totalSec = _remainSec;
    });
  }
}

// ────────────────────────────────────────────
// リングペインター
// ────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    // 背景トラック
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0x10FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // プログレス
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = AppTheme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ────────────────────────────────────────────
// サブウィジェット
// ────────────────────────────────────────────
class _CtrlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface2,
            border: Border.all(color: AppTheme.border2, width: 0.5),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 22),
        ),
      );
}

class _AdjBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AdjBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
}
