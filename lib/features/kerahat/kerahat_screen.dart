// lib/features/kerahat/kerahat_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/prayer_provider.dart';
import '../../shared/models/prayer_times_model.dart';

// ─── Kerahat Period Model ────────────────────────────────────────────────────
enum KerahatStatus { haram, makruh, mubah }

class KerahatPeriod {
  final String name;
  final String subtitle;
  final String description;
  final DateTime start;
  final DateTime end;
  final KerahatStatus status;
  final IconData icon;

  const KerahatPeriod({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.start,
    required this.end,
    required this.status,
    required this.icon,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  Duration get duration => end.difference(start);

  String get startFormatted =>
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  String get endFormatted =>
      '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
}

// ─── Provider ───────────────────────────────────────────────────────────────
final kerahatPeriodsProvider = FutureProvider<List<KerahatPeriod>>((ref) async {
  final timesAsync = ref.watch(todayPrayerTimesProvider);
  final times = timesAsync.asData?.value;
  if (times == null) return [];
  return _calculateKerahatPeriods(times);
});

List<KerahatPeriod> _calculateKerahatPeriods(PrayerTimesModel times) {
  final fajr = times.fajr;
  final sunrise = times.sunrise;
  final dhuhr = times.dhuhr;
  final asr = times.asr;
  final maghrib = times.maghrib;
  final isha = times.isha;

  // Calculated derived times
  final sunriseKerahatEnd = sunrise.add(const Duration(minutes: 45));
  final istiwaMakruhStart = dhuhr.subtract(const Duration(minutes: 15));
  final sunsetKerahatStart = maghrib.subtract(const Duration(minutes: 45));

  return [
    KerahatPeriod(
      name: 'İmsak → Güneş',
      subtitle: 'Her Türlü Namaz Kılınabilir',
      description: 'Sabah namazı ve diğer nafileler serbestçe kılınabilir.',
      start: fajr,
      end: sunrise.subtract(const Duration(minutes: 3)),
      status: KerahatStatus.mubah,
      icon: Icons.wb_twilight_rounded,
    ),
    KerahatPeriod(
      name: 'Güneş Doğuşu Kerahati',
      subtitle: 'Namaz Kılınamaz — Haram',
      description:
          'Güneş doğmakta iken namaz kılmak haramdır. Güneş bir mızrak boyu yükselene kadar (yaklaşık 45 dakika) namaz kılınamaz. Sabah namazının kazası da bu vakitte kılınamaz.',
      start: sunrise.subtract(const Duration(minutes: 3)),
      end: sunriseKerahatEnd,
      status: KerahatStatus.haram,
      icon: Icons.wb_sunny_rounded,
    ),
    KerahatPeriod(
      name: 'Kuşluk (Duhâ)',
      subtitle: 'Her Türlü Namaz Kılınabilir',
      description:
          'Güneş bir mızrak boyu yükseldikten sonra öğle vaktine kadar namaz kılınabilir. Kuşluk (Duhâ) namazı bu vakitte kılınır.',
      start: sunriseKerahatEnd,
      end: istiwaMakruhStart,
      status: KerahatStatus.mubah,
      icon: Icons.light_mode_rounded,
    ),
    KerahatPeriod(
      name: 'Öğle Kerahati (İstiwa)',
      subtitle: 'Nafile Namaz Mekruhtur',
      description:
          'Güneşin tam tepe noktasında olduğu istiwa vakti. Bu süre çok kısadır (yaklaşık 15 dakika). Farz ve vacip namazlar kılınabilir; nafile ve sünnet kılmak mekruhtur.',
      start: istiwaMakruhStart,
      end: dhuhr,
      status: KerahatStatus.makruh,
      icon: Icons.circle_rounded,
    ),
    KerahatPeriod(
      name: 'Öğle → İkindi',
      subtitle: 'Her Türlü Namaz Kılınabilir',
      description:
          'Öğle vaktinden ikindi vaktine kadar farz, vacip, sünnet ve nafile serbestçe kılınabilir.',
      start: dhuhr,
      end: asr,
      status: KerahatStatus.mubah,
      icon: Icons.wb_cloudy_rounded,
    ),
    KerahatPeriod(
      name: 'İkindi Kerahati',
      subtitle: 'Nafile Namaz Mekruhtur',
      description:
          'İkindi namazı kılındıktan sonra güneş batıncaya kadar nafile namaz kılmak mekruhtur. Yalnızca o günün kaza namazları ve farz namazlar kılınabilir. İkindi namazının sünneti terk edilerek sadece farzı kılınır.',
      start: asr,
      end: sunsetKerahatStart,
      status: KerahatStatus.makruh,
      icon: Icons.wb_cloudy_outlined,
    ),
    KerahatPeriod(
      name: 'Güneş Batışı Kerahati',
      subtitle: 'Namaz Kılınamaz — Haram',
      description:
          'Güneş batmakta iken namaz kılmak haramdır. Yalnızca o günün ikindi namazının farzı (henüz kılınmamışsa) bu vakitte kılınabilir. Diğer tüm namazlar haramdır.',
      start: sunsetKerahatStart,
      end: maghrib,
      status: KerahatStatus.haram,
      icon: Icons.nights_stay_rounded,
    ),
    KerahatPeriod(
      name: 'Akşam → Yatsı',
      subtitle: 'Her Türlü Namaz Kılınabilir',
      description: 'Akşam namazı ve diğer nafileler serbestçe kılınabilir.',
      start: maghrib,
      end: isha,
      status: KerahatStatus.mubah,
      icon: Icons.mode_night_rounded,
    ),
    KerahatPeriod(
      name: 'Yatsı Vakti',
      subtitle: 'Her Türlü Namaz Kılınabilir',
      description: 'Yatsı namazı ve teravih namazı bu vakitte kılınır.',
      start: isha,
      end: fajr.add(const Duration(days: 1)),
      status: KerahatStatus.mubah,
      icon: Icons.bedtime_rounded,
    ),
  ];
}

// ─── Main Screen ─────────────────────────────────────────────────────────────
class KerahatScreen extends ConsumerStatefulWidget {
  const KerahatScreen({super.key});

  @override
  ConsumerState<KerahatScreen> createState() => _KerahatScreenState();
}

class _KerahatScreenState extends ConsumerState<KerahatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final periodsAsync = ref.watch(kerahatPeriodsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Kerahat Vakitleri',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            centerTitle: true,
          ),
          periodsAsync.when(
            data: (periods) => SliverList(
              delegate: SliverChildListDelegate([
                _CurrentStatusBanner(periods: periods, pulse: _pulseController),
                const SizedBox(height: 16),
                _DayArcWidget(periods: periods),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'GÜNLÜK VAKİTLER',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 2.0,
                          color: AppTheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ...periods.asMap().entries.map(
                      (e) => _PeriodCard(
                        period: e.value,
                        index: e.key,
                        pulse: _pulseController,
                      ),
                    ),
                _FiqhInfoCard(),
                const SizedBox(height: 100),
              ]),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Veri yüklenemedi: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Current Status Banner ───────────────────────────────────────────────────
class _CurrentStatusBanner extends StatelessWidget {
  final List<KerahatPeriod> periods;
  final AnimationController pulse;
  const _CurrentStatusBanner({required this.periods, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final active = periods.where((p) => p.isActive).firstOrNull;
    if (active == null) return const SizedBox.shrink();

    final color = _statusColor(active.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: pulse,
      builder: (ctx, child) {
        final glow = pulse.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3 + glow * 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1 + glow * 0.15),
                blurRadius: 20 + glow * 10,
                spreadRadius: glow * 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusColor(active.status).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(active.icon, color: _statusColor(active.status), size: 28),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(active.status),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(active.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ŞU AN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  active.name,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _statusColor(active.status),
                  ),
                ),
                Text(
                  '${active.startFormatted} – ${active.endFormatted}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}

// ─── Day Arc Visualization ───────────────────────────────────────────────────
class _DayArcWidget extends StatelessWidget {
  final List<KerahatPeriod> periods;
  const _DayArcWidget({required this.periods});

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: CustomPaint(
          painter: _ArcPainter(periods: periods, isDark: isDark),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeOfDay.now().format(context),
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  'Şu Anki Saat',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final List<KerahatPeriod> periods;
  final bool isDark;
  _ArcPainter({required this.periods, required this.isDark});

  double _timeToAngle(DateTime time) {
    // Map 0:00-24:00 to -pi/2 to 3*pi/2 (start from top)
    final minutesSinceMidnight = time.hour * 60 + time.minute;
    return (minutesSinceMidnight / (24 * 60)) * 2 * math.pi - math.pi / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 20.0;

    // Draw background track
    final trackPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw each period arc
    for (final period in periods) {
      final startAngle = _timeToAngle(period.start);
      var endAngle = _timeToAngle(period.end);
      if (endAngle < startAngle) endAngle += 2 * math.pi;
      final sweepAngle = endAngle - startAngle;

      final paint = Paint()
        ..color = _statusColor(period.status).withValues(alpha: period.isActive ? 1.0 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = period.isActive ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Current time indicator (white dot)
    final now = DateTime.now();
    final nowAngle = _timeToAngle(now);
    final dotX = center.dx + radius * math.cos(nowAngle);
    final dotY = center.dy + radius * math.sin(nowAngle);

    // Shadow
    canvas.drawCircle(
      Offset(dotX, dotY),
      10,
      Paint()..color = Colors.black.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // White dot
    canvas.drawCircle(Offset(dotX, dotY), 10, Paint()..color = Colors.white);
    // Primary border
    canvas.drawCircle(
      Offset(dotX, dotY),
      10,
      Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Draw inner separator lines for ticks
    for (int h = 0; h < 24; h += 3) {
      final dt = DateTime(now.year, now.month, now.day, h, 0);
      final angle = _timeToAngle(dt);
      final innerR = radius - strokeWidth / 2 - 6;
      final outerR = radius + strokeWidth / 2 + 4;
      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle)),
        Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle)),
        Paint()
          ..color = isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.12)
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── Period Card ─────────────────────────────────────────────────────────────
class _PeriodCard extends StatefulWidget {
  final KerahatPeriod period;
  final int index;
  final AnimationController pulse;

  const _PeriodCard({required this.period, required this.index, required this.pulse});

  @override
  State<_PeriodCard> createState() => _PeriodCardState();
}

class _PeriodCardState extends State<_PeriodCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.period;
    final color = _statusColor(p.status);
    final isActive = p.isActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isActive) {
      _expanded = true;
    }

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedBuilder(
        animation: widget.pulse,
        builder: (ctx, child) => Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: isDark ? 0.15 : 0.07)
                : (isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? color.withValues(alpha: 0.4 + widget.pulse.value * 0.3)
                  : color.withValues(alpha: 0.15),
              width: isActive ? 2 : 1,
            ),
          ),
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(p.icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                  color: isActive ? color : null,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'AKTİF',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.subtitle,
                          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        p.startFormatted,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        p.endFormatted,
                        style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: Color(0x1A000000)),
                      const SizedBox(height: 10),
                      Text(
                        p.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatusChip(status: p.status),
                          const SizedBox(width: 8),
                          Text(
                            '${p.duration.inMinutes} dakika',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (widget.index * 60).ms).fadeIn().slideX(begin: 0.1, end: 0);
  }
}

class _StatusChip extends StatelessWidget {
  final KerahatStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _statusLabel(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _statusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fiqh Info Card ──────────────────────────────────────────────────────────
class _FiqhInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Genel Kural (Hanefi)',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            ('🔴 Haram Vakitler', 'Güneş doğarken ve batarken hiçbir namaz kılınamaz. Yalnızca o günün henüz kılınmamış ikindi farzı, batış kerahatinde kılınabilir.'),
            ('🟠 Mekruh Vakitler', 'İstiwa (öğle kerahati) ve ikindi vakitlerinde nafile ile sünnet namazlar mekruhtur. Farz ve vacip namazlar bu vakitlerde kılınabilir.'),
            ('🟢 Serbest Vakitler', 'Diğer vakitlerde farz, vacip, sünnet ve nafile tüm namazlar kılınabilir.'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: '${item.$1}: ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: item.$2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────
Color _statusColor(KerahatStatus status) {
  switch (status) {
    case KerahatStatus.haram:
      return const Color(0xFFDC2626);
    case KerahatStatus.makruh:
      return const Color(0xFFD97706);
    case KerahatStatus.mubah:
      return const Color(0xFF16A34A);
  }
}

String _statusLabel(KerahatStatus status) {
  switch (status) {
    case KerahatStatus.haram:
      return 'HARAM';
    case KerahatStatus.makruh:
      return 'MEKRUH';
    case KerahatStatus.mubah:
      return 'SERBEST';
  }
}
