import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/prayer_provider.dart';
import '../../shared/providers/settings_provider.dart';

final monthlyTimesProvider = FutureProvider((ref) async {
  final cityAsync = ref.watch(activeCityProvider);
  final settingsAsync = ref.watch(settingsProvider);

  final city = cityAsync.asData?.value;
  final settings = settingsAsync.asData?.value;

  if (city == null || settings == null) return null;

  final now = DateTime.now();
  final service = ref.read(prayerTimesServiceProvider);

  return service.getMonthlyPrayerTimes(
    cityId: city.id,
    lat: city.lat,
    lon: city.lon,
    year: now.year,
    month: now.month,
    settings: settings,
  );
});

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlyTimesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Aylık Takvim',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.onSurface),
        ),
        backgroundColor: isDark ? AppTheme.surfaceDark.withValues(alpha: 0.95) : Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.onSurface),
      ),
      body: monthlyAsync.when(
        data: (times) {
          if (times == null || times.isEmpty) return const Center(child: Text('Veri bulunamadı.'));
          
          final now = DateTime.now();
          return ListView.builder(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + kToolbarHeight + 16, bottom: 40),
            itemCount: times.length,
            itemBuilder: (context, index) {
              final day = times[index];
              final isToday = day.date.year == now.year && day.date.month == now.month && day.date.day == now.day;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isToday 
                  ? (isDark ? AppTheme.primary.withValues(alpha: 0.25) : AppTheme.primary.withValues(alpha: 0.15))
                  : (isDark ? const Color(0xFF1E1E1E) : AppTheme.surfaceContainer.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToday ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
                    width: isToday ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(day.date),
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: isToday ? AppTheme.primary : (isDark ? Colors.white70 : AppTheme.onSurface),
                          ),
                        ),
                        const Spacer(),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('BUGÜN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TimeCol('İmsak', day.fajr),
                        _TimeCol('Güneş', day.sunrise),
                        _TimeCol('Öğle', day.dhuhr),
                        _TimeCol('İkindi', day.asr),
                        _TimeCol('Akşam', day.maghrib),
                        _TimeCol('Yatsı', day.isha),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(child: Text('Takvim yüklenirken hata oluştu.')),
      ),
    );
  }
}

class _TimeCol extends StatelessWidget {
  final String name;
  final DateTime time;

  const _TimeCol(this.name, this.time);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppTheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : AppTheme.onSurface),
        ),
      ],
    );
  }
}
