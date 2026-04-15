import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/qibla_provider.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> with WidgetsBindingObserver {
  bool _lastFacing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compassAsync = ref.watch(compassStreamProvider);
    final qiblaBearing = ref.watch(qiblaBearingProvider);
    final distance = ref.watch(qiblaDistanceProvider);
    final isFacing = ref.watch(isFacingQiblaProvider);

    // Sadece bu sayfa aktifken ve kıble yönündeyken titreşim
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentRoute && isFacing && !_lastFacing) {
      HapticFeedback.mediumImpact();
      _lastFacing = true;
    } else if (!isFacing) {
      _lastFacing = false;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      appBar: AppBar(
        title: Text('Kıble Pusulası', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: compassAsync.when(
        data: (event) {
          final heading = event.heading ?? 0;
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // ── Ka'ba Info Card ──────────────────────────────────────
                _KaabaInfoCard(distance: distance, bearing: qiblaBearing, isFacing: isFacing),
                const SizedBox(height: 10),

                // ── Alignment Banner ─────────────────────────────────────
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 400),
                  crossFadeState: isFacing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.activeGreen,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'KIBLE YÖNÜNDESİNİZ',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 900.ms),
                  ),
                ),

                const Spacer(),

                // ── Main Compass ─────────────────────────────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: heading),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, val, _) {
                    return SizedBox(
                      width: 340,
                      height: 340,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow when facing
                          if (isFacing) const _AlignmentGlow(),

                          // Rotating compass plate
                          Transform.rotate(
                            angle: -val * (math.pi / 180),
                            child: _CompassDial(qiblaBearing: qiblaBearing, isFacing: isFacing),
                          ),

                          // Center Ka'ba emblem (static)
                          _CenterEmblem(isFacing: isFacing),

                          // Rotating qibla arrow
                          Transform.rotate(
                            angle: (-val + qiblaBearing) * (math.pi / 180),
                            child: CustomPaint(
                              size: const Size(340, 340),
                              painter: _QiblaArrowPainter(isFacing: isFacing),
                            ),
                          ),

                          // Fixed device indicator (always up)
                          const _DevicePointer(),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // ── Sensor Status ─────────────────────────────────────────
                _SensorStatusIndicator(accuracy: event.accuracy),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Sensör Hatası: $e')),
      ),
    );
  }
}

class _KaabaInfoCard extends StatelessWidget {
  final double distance;
  final double bearing;
  final bool isFacing;
  const _KaabaInfoCard({required this.distance, required this.bearing, required this.isFacing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isFacing ? AppTheme.activeGreen : AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.mosque_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kâbe — Mekke, Suudi Arabistan',
                    style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Yön: ${bearing.toStringAsFixed(1)}°  •  Mesafe: ${distance.toStringAsFixed(0)} km',
                    style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(isFacing ? Icons.verified_rounded : Icons.explore_outlined, color: color, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.15, end: 0);
  }
}

// ── Compass Dial ──────────────────────────────────────────────────────────────
class _CompassDial extends StatelessWidget {
  final double qiblaBearing;
  final bool isFacing;
  const _CompassDial({required this.qiblaBearing, required this.isFacing});

  static const _cardinals = [
    (0.0,   'K',  true),
    (45.0,  'KD', false),
    (90.0,  'D',  true),
    (135.0, 'GD', false),
    (180.0, 'G',  true),
    (225.0, 'GB', false),
    (270.0, 'B',  true),
    (315.0, 'KB', false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isFacing ? AppTheme.activeGreen : AppTheme.primary;

    return Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? const Color(0xFF111E11)
            : const Color(0xFFF4F7E0),
        border: Border.all(color: baseColor.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: isFacing ? 0.2 : 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CompassTickPainter(
          isDark: isDark,
          primaryColor: baseColor,
        ),
        child: Stack(
          children: [
            // Direction labels
            for (final (deg, label, isCardinal) in _cardinals)
              Transform.rotate(
                angle: deg * math.pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Transform.rotate(
                      angle: -deg * math.pi / 180,
                      child: Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: isCardinal ? 15 : 10,
                          fontWeight: FontWeight.w900,
                          color: label == 'K'
                              ? const Color(0xFFE53935)
                              : isCardinal
                                  ? baseColor
                                  : (isDark ? AppTheme.onSurfaceVariantDark : AppTheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Compass Tick CustomPainter ─────────────────────────────────────────────────
class _CompassTickPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;

  const _CompassTickPainter({
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180 - math.pi / 2;
      final isMain = i % 90 == 0;
      final isMid = i % 45 == 0 && !isMain;
      final is10 = i % 10 == 0 && !isMid && !isMain;

      final outerR = radius - 4;
      final innerR = isMain
          ? radius - 22
          : isMid
              ? radius - 18
              : is10
                  ? radius - 14
                  : radius - 11;

      tickPaint
        ..color = isMain
            ? primaryColor.withValues(alpha: 0.9)
            : isMid
                ? primaryColor.withValues(alpha: 0.5)
                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15)
        ..strokeWidth = isMain ? 2.5 : isMid ? 1.5 : 1.0;

      final outer = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final inner = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      canvas.drawLine(outer, inner, tickPaint);
    }

    // Degree numbers every 30°
    for (int i = 0; i < 360; i += 30) {
      if (i % 90 == 0) continue; // skip cardinals, they have labels
      final angle = i * math.pi / 180 - math.pi / 2;
      final labelR = radius - 32.0;
      final pos = Offset(
        center.dx + labelR * math.cos(angle),
        center.dy + labelR * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '$i°',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CompassTickPainter old) =>
      old.isDark != isDark || old.primaryColor != primaryColor;
}

// ── Qibla Arrow (CustomPainter) ───────────────────────────────────────────────
class _QiblaArrowPainter extends CustomPainter {
  final bool isFacing;
  const _QiblaArrowPainter({required this.isFacing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final color = isFacing ? AppTheme.activeGreen : AppTheme.primary;
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Arrow tip (pointing up = toward qibla)
    final tipY = center.dy - radius + 28;
    final arrowTip = Path()
      ..moveTo(center.dx, tipY)
      ..lineTo(center.dx - 10, tipY + 22)
      ..lineTo(center.dx - 3, tipY + 18)
      ..lineTo(center.dx - 3, center.dy - 28)
      ..lineTo(center.dx + 3, center.dy - 28)
      ..lineTo(center.dx + 3, tipY + 18)
      ..lineTo(center.dx + 10, tipY + 22)
      ..close();
    canvas.drawPath(arrowTip, paint);
    canvas.drawPath(arrowTip, strokePaint);

    // Arrow tail (pointing down = opposite of qibla)
    final tailY = center.dy + radius - 28;
    final tailPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final arrowTail = Path()
      ..moveTo(center.dx, tailY)
      ..lineTo(center.dx + 8, tailY - 18)
      ..lineTo(center.dx + 2, tailY - 14)
      ..lineTo(center.dx + 2, center.dy + 28)
      ..lineTo(center.dx - 2, center.dy + 28)
      ..lineTo(center.dx - 2, tailY - 14)
      ..lineTo(center.dx - 8, tailY - 18)
      ..close();
    canvas.drawPath(arrowTail, tailPaint);

    // Circle at the tip with Ka'ba label
    canvas.drawCircle(
      Offset(center.dx, tipY + 4),
      6,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(center.dx, tipY + 4),
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_QiblaArrowPainter old) => old.isFacing != isFacing;
}

// ── Center Emblem ─────────────────────────────────────────────────────────────
class _CenterEmblem extends StatelessWidget {
  final bool isFacing;
  const _CenterEmblem({required this.isFacing});

  @override
  Widget build(BuildContext context) {
    final color = isFacing ? AppTheme.activeGreen : AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppTheme.surfaceContainerHighDark : AppTheme.surfaceContainerHigh,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.mosque_rounded, color: color, size: 26),
    );
  }
}

// ── Device Pointer ────────────────────────────────────────────────────────────
class _DevicePointer extends StatelessWidget {
  const _DevicePointer();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomPaint(
        size: const Size(24, 32),
        painter: _TrianglePointerPainter(),
      ),
    );
  }
}

class _TrianglePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.7)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_TrianglePointerPainter _) => false;
}

// ── Alignment Glow ────────────────────────────────────────────────────────────
class _AlignmentGlow extends StatelessWidget {
  const _AlignmentGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.activeGreen.withValues(alpha: 0.25),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .custom(
       duration: 1200.ms,
       builder: (_, v, child) => Opacity(opacity: 0.5 + v * 0.5, child: child),
     );
  }
}

class _SensorStatusIndicator extends StatelessWidget {
  final double? accuracy;
  const _SensorStatusIndicator({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final highAcc = (accuracy ?? 100) < 30; // Eşik: 30 derece (daha toleranslı)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: (highAcc ? AppTheme.activeGreen : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            highAcc ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 14,
            color: highAcc ? AppTheme.activeGreen : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            highAcc ? 'SENSÖR DOĞRULUĞU: YÜKSEK' : 'KALİBRASYON GEREKLİ',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: highAcc ? AppTheme.activeGreen : Colors.orange,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
