import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/providers/tasbih_provider.dart';
import '../../shared/providers/prayer_provider.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _isPressed = false);
    });
    ref.read(tasbihProvider.notifier).increment();
  }

  void _showEditZikrDialog(String currentName, int currentTarget) {
    final nameController = TextEditingController(text: currentName);
    final targetController = TextEditingController(text: currentTarget.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDFFDA);
    final textColor = isDark ? Colors.white : const Color(0xFF237329);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Zikri Düzenle', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Zikir Adı',
                labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor.withValues(alpha: 0.3))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Hedef Sayı',
                labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor.withValues(alpha: 0.3))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newTarget = int.tryParse(targetController.text) ?? currentTarget;
              if (newName.isNotEmpty) {
                ref.read(tasbihProvider.notifier).updateZikr(newName, newTarget);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF237329),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showZikrHistory(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDFFDA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final statsAsync = ref.watch(weeklyTasbihStatsProvider);
          
          return statsAsync.when(
            data: (stats) => _ZikrHistorySheet(stats: stats),
            loading: () => const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 200,
              child: Center(child: Text('Hata: $e')),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasbihAsync = ref.watch(tasbihProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final cityAsync = ref.watch(activeCityProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFFDA);
    final textColor = isDark ? Colors.white : const Color(0xFF237329);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Zikirmatik', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: textColor)),
        backgroundColor: bgColor.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Ses toggle
          tasbihAsync.when(
            data: (state) => IconButton(
              icon: Icon(
                state.soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: state.soundEnabled ? textColor : Colors.grey,
              ),
              tooltip: state.soundEnabled ? 'Ses Açık' : 'Ses Kapalı',
              onPressed: () => ref.read(tasbihProvider.notifier).toggleSound(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, e) => const SizedBox.shrink(),
          ),
          // Geçmiş butonu
          IconButton(
            icon: Icon(Icons.history_rounded, color: textColor),
            tooltip: 'Zikir Geçmişi',
            onPressed: () => _showZikrHistory(context),
          ),
          IconButton(
            icon: Icon(Icons.edit_note_rounded, color: textColor),
            onPressed: () {
              tasbihAsync.whenData((s) => _showEditZikrDialog(s.zikrName, s.target));
            },
          ),
        ],
      ),
      body: tasbihAsync.when(
        data: (state) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Spiritual Journey Header
              Text(
                'Manevi Yolculuk',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF237329),
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              
              Text(
                'Huzura Bir Adım Daha',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 60),

              // Hero Counter Area — tüm alan tıklanabilir
              RepaintBoundary(
                child: GestureDetector(
                  onTap: _handleTap,
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Glow — AnimationBuilder (flutter_animate yerine)
                          IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (_, child) => Transform.scale(
                                scale: 1.0 + _glowController.value * 0.1,
                                child: Container(
                                  width: 320,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF237329).withValues(alpha: 0.04),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Main Counter
                          AnimatedScale(
                            scale: _isPressed ? 0.94 : 1.0,
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOut,
                            child: Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF237329), Color(0xFF145119)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF237329).withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1), width: 4),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${state.count}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 84,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -4,
                                    ),
                                  ),
                                  Text(
                                    state.zikrName,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Progress Ring
                          IgnorePointer(
                            child: SizedBox(
                              width: 280,
                              height: 280,
                              child: CircularProgressIndicator(
                                value: state.count / state.target,
                                strokeWidth: 4,
                                color: Colors.white.withValues(alpha: 0.4),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),

                          // Tap Hint — Positioned MUST be direct child of Stack
                          Positioned(
                            bottom: 28,
                            child: IgnorePointer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.touch_app_rounded,
                                      color: Colors.white.withValues(alpha: 0.5),
                                      size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    'TIKLA VE BAŞLA',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withValues(alpha: 0.5),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ).animate(onPlay: (c) => c.repeat())
                               .fadeIn(duration: 1.seconds)
                               .then()
                               .fadeOut(duration: 1.seconds),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tamamlanma sayıları (33, 99, 100)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CompletionBadge(
                    count: state.completed33,
                    label: '33',
                    color: const Color(0xFF237329),
                  ),
                  const SizedBox(width: 12),
                  _CompletionBadge(
                    count: state.completed99,
                    label: '99',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _CompletionBadge(
                    count: state.completed100,
                    label: '100',
                    color: Colors.purple,
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // Reset Action
              TextButton.icon(
                onPressed: () => ref.read(tasbihProvider.notifier).resetCount(),
                icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFF237329)),
                label: Text(
                  'SAYACI SIFIRLA',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF237329),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color(0xFF237329).withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 32),

              // Bento Grid Info Card
              _BentoInfoGrid(
                state: state,
                nextPrayerName: nextPrayer?.name ?? '-',
                nextPrayerTime: nextPrayer != null ? ref.read(todayPrayerTimesProvider).value?.formatTime(nextPrayer.time) ?? '-' : '-',
                cityName: cityAsync.value?.name ?? '...',
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF237329)),
              SizedBox(height: 16),
              Text('Zikirmatik yükleniyor...', style: TextStyle(color: Color(0xFF237329))),
            ],
          ),
        ),
        error: (e, stack) {
          debugPrint('Zikirmatik Hatası: $e\n$stack');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Bağlantı Hatası', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Veriler yüklenirken bir sorun oluştu. Lütfen uygulamayı yeniden başlatın.', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.refresh(tasbihProvider),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BentoInfoGrid extends StatelessWidget {
  final TasbihState state;
  final String nextPrayerName;
  final String nextPrayerTime;
  final String cityName;

  const _BentoInfoGrid({
    required this.state,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white60 : Colors.black45;
    final bodyTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Column(
      children: [
        // Daily Progress (Full Width)
        _BentoTile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GÜNLÜK İLERLEME', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('Zikir Tamamlama', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF9DF197)),
                    child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF237329)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: state.count / state.target,
                  minHeight: 8,
                  backgroundColor: Colors.black.withValues(alpha: 0.05),
                  color: const Color(0xFF237329),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hedefe ulaşmak için ${state.target - state.count} zikir kaldı',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: bodyTextColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Next Prayer
            Expanded(
              child: _BentoTile(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time_filled_rounded, color: Color(0xFF237329)),
                    const SizedBox(height: 16),
                    Text('SIRADAKİ', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 1.5)),
                    Text(nextPrayerName, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                    Text(nextPrayerTime, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF237329))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Location
            Expanded(
              child: _BentoTile(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF875A43)),
                    const SizedBox(height: 16),
                    Text('KONUM', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: subTextColor, letterSpacing: 1.5)),
                    Text(cityName, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                    Text('Türkiye', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: bodyTextColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoTile extends StatelessWidget {
  final Widget child;
  const _BentoTile({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F4E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: child,
    );
  }
}

/// Zikir Geçmişi Bottom Sheet
class _ZikrHistorySheet extends StatelessWidget {
  final List<TasbihStats> stats;

  const _ZikrHistorySheet({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF237329);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final totalZikr = stats.fold(0, (sum, s) => sum + s.totalCount);
    final totalCycles = stats.fold(0, (sum, s) => sum + s.totalCycles);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zikir Geçmişi',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bugünkü Zikir Özeti',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Özet kartlar
          Row(
            children: [
              Expanded(
                child: _HistoryCard(
                  title: 'Toplam Zikir',
                  value: '$totalZikr',
                  icon: Icons.countertops,
                  color: const Color(0xFF237329),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HistoryCard(
                  title: 'Tamamlanan',
                  value: '$totalCycles',
                  icon: Icons.check_circle,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bugünkü zikir detayı (sadece bugün) — stats.last = bugün
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Bugünkü Zikir',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _DailyStatRow(stat: stats.last),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HistoryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatRow extends StatelessWidget {
  final TasbihStats stat;

  const _DailyStatRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF237329).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  stat.dayName,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF237329),
                  ),
                ),
                Text(
                  stat.formattedDate.split(' ')[0],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF237329),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stat.totalCount} zikir',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (stat.totalCycles > 0)
                  Text(
                    '${stat.totalCycles} tur tamamlandı',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          if (stat.totalCount > 0)
            const Icon(Icons.check_circle, color: Color(0xFF237329), size: 20),
        ],
      ),
    );
  }
}

/// 33, 99, 100 tamamlanma sayısı rozeti
class _CompletionBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CompletionBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$label kez',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
