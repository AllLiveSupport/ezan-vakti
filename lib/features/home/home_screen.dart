import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/prayer_provider.dart';
import '../../shared/models/prayer_times_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _bgAnimController;
  DateTime _lastDate = DateTime.now();
  Timer? _dateCheckTimer;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    
    // Tarih değişimini kontrol etmek için timer
    _dateCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkDateChange();
    });
    
    // App lifecycle observer ekle
    WidgetsBinding.instance.addObserver(this);

    // Bildirim izni kontrol — splash'ta verilmemişse fallback olarak iste
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureNotificationPermission());
  }

  Future<void> _ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama foreground'a gelince tarihi kontrol et
    if (state == AppLifecycleState.resumed) {
      _checkDateChange();
    }
  }
  
  void _checkDateChange() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(_lastDate.year, _lastDate.month, _lastDate.day);
    
    if (currentDate != lastDate) {
      debugPrint('📅 Tarih değişimi tespit edildi: $_lastDate -> $currentDate');
      _lastDate = now;
      // Provider'ı yenile
      ref.invalidate(todayPrayerTimesProvider);
      ref.invalidate(countdownProvider);
      ref.invalidate(nextPrayerProvider);
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _dateCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerAsync = ref.watch(todayPrayerTimesProvider);
    final cityAsync = ref.watch(activeCityProvider);
    final countdown = ref.watch(countdownProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final hijriAsync = ref.watch(hijriDateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Hero Section ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroSection(
              bgAnimController: _bgAnimController,
              cityName: switch (cityAsync) {
                AsyncData(value: final v) => v?.name ?? 'Türkiye',
                _ => 'Türkiye',
              },
              countdown: countdown,
              nextPrayerName: nextPrayer?.name ?? '─',
              hijriDate: switch (hijriAsync) {
                AsyncData(value: final v) => v,
                _ => '...',
              },
              isDark: isDark,
            ),
          ),

          // ─── Prayer Times Grid ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: prayerAsync.when(
                data: (times) => times != null
                    ? _PrayerTimesGrid(times: times)
                    : const _PrayerTimesShimmer(),
                loading: () => const _PrayerTimesShimmer(),
                error: (e, _) => _ErrorCard(message: e.toString()),
              ),
            ),
          ),

          // ─── Quick Access Buttons ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const _QuickAccessRow(),
            ),
          ),

          // ─── Bottom padding ─────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final AnimationController bgAnimController;
  final String cityName;
  final Duration countdown;
  final String nextPrayerName;
  final String hijriDate;
  final bool isDark;

  const _HeroSection({
    required this.bgAnimController,
    required this.cityName,
    required this.countdown,
    required this.nextPrayerName,
    required this.hijriDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bgAnimController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(28, 52, 28, 36),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A4020),
                      const Color(0xFF0D2714),
                    ]
                  : [
                      AppTheme.primary,
                      AppTheme.primaryDim,
                    ],
              transform: GradientRotation(
                  bgAnimController.value * 0.3),
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.4 : 0.3),
                offset: const Offset(0, 12),
                blurRadius: 32,
                spreadRadius: -4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Konum satırı
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                cityName,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                hijriDate,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Sonraki Vakit Etiketi
          Text(
            'Sonraki Vakit',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 6),

          // Vakit İsmi
          Text(
            nextPrayerName,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),

          // Geri Sayım
          Text(
            countdown.hms,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w700,
              letterSpacing: -3.0,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),

          // Alt açıklama
          Text(
            'kaldı',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prayer Times Grid ─────────────────────────────────────────────────────────
class _PrayerTimesGrid extends ConsumerWidget {
  final PrayerTimesModel times;
  const _PrayerTimesGrid({required this.times});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrayer = ref.watch(currentPrayerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prayers = times.allPrayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUGÜNÜN VAKİTLERİ',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
        ),
        const SizedBox(height: 12),
        ...List.generate(prayers.length, (i) {
          final prayer = prayers[i];
          final isActive = currentPrayer?.index == i;
          final isNext = times.getNextPrayer(DateTime.now()).index == i;

          return _PrayerRow(
            name: prayer.name,
            time: times.formatTime(prayer.time),
            isActive: isActive,
            isNext: isNext,
            index: i,
            isDark: isDark,
          ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;
  final bool isNext;
  final int index;
  final bool isDark;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.isActive,
    required this.isNext,
    required this.index,
    required this.isDark,
  });

  static const List<IconData> _icons = [
    Icons.brightness_3_outlined,  // İmsak
    Icons.wb_twilight_rounded,    // Sabah (Fajr)
    Icons.wb_sunny_outlined,      // Güneş (Sunrise)
    Icons.light_mode_rounded,     // Öğle (Dhuhr)
    Icons.wb_cloudy_outlined,     // İkindi (Asr)
    Icons.nights_stay_outlined,   // Akşam (Maghrib)
    Icons.dark_mode_rounded,      // Yatsı (Isha)
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? AppTheme.activePrayerDecoration(isDark: isDark)
        : BoxDecoration(
            color: isNext
                ? (isDark
                    ? AppTheme.surfaceContainerDark
                    : AppTheme.surfaceContainerHigh)
                : (isDark
                    ? AppTheme.surfaceContainerDark.withValues(alpha: 0.5)
                    : AppTheme.surfaceContainerLow),
            borderRadius: BorderRadius.circular(20),
          );

    final textColor = isActive 
        ? Colors.white 
        : (isDark ? Colors.white : AppTheme.onSurface);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: bg,
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppTheme.primaryContainer.withValues(alpha: 
                      isDark ? 0.15 : 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _icons[index],
              size: 20,
              color: isActive ? Colors.white : AppTheme.primary,
            ),
          ),
          const SizedBox(width: 16),

          // Vakit ismi
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: isActive || isNext
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
            ),
          ),

          // Next badge
          if (isNext && !isActive)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Sonraki',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? const Color(0xFF4CAF50) : AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),

          const SizedBox(width: 8),

          // Saat
          Text(
            time,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Access Row ──────────────────────────────────────────────────────────
class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.explore_rounded, label: 'Kıble', route: '/qibla'),
      (icon: Icons.fingerprint_rounded, label: 'Tesbih', route: '/tasbih'),
      (icon: Icons.mosque_rounded, label: 'Camiler', route: '/mosques'),
      (icon: Icons.auto_stories_rounded, label: 'Dualar', route: '/duas'),
      (icon: Icons.schedule_rounded, label: 'Kerahat', route: '/kerahat'),
      (icon: Icons.calendar_month_rounded, label: 'Takvim', route: '/calendar'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HIZLI ERIŞIM',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => SizedBox(
              width: 76,
              child: _QuickAccessCard(
                icon: items[i].icon,
                label: items[i].label,
                onTap: () => Navigator.pushNamed(context, items[i].route),
              ).animate(delay: (i * 80).ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : AppTheme.surfaceContainerLow;
    final textColor = isDark ? Colors.white : AppTheme.onSurface;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: textColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading / Error States ────────────────────────────────────────────────────
class _PrayerTimesShimmer extends StatelessWidget {
  const _PrayerTimesShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vakitler yüklenemedi. İnternet bağlantını kontrol et.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// Duplicate extension removed — use PrayerDurationFormatting from prayer_provider.dart
