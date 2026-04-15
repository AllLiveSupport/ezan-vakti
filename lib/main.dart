// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/city_selection_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/qibla/qibla_screen.dart';
import 'features/map/mosque_map_screen.dart';
import 'features/dua/dua_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/tasbih/tasbih_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/profile/developer_profile_screen.dart';
import 'features/support/support_screen.dart';
import 'features/settings/alarm_settings_screen.dart';
import 'features/settings/notification_help_screen.dart';
import 'features/adhan/adhan_alarm_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/alarm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/services/reminder_service.dart';
import 'shared/providers/settings_provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/kerahat/kerahat_screen.dart';
import 'features/onboarding/country_selection_screen.dart';
import 'shared/providers/prayer_provider.dart';
import 'package:alarm/alarm.dart';

// Global navigation key for navigating from outside widgets (like Alarm ring stream)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale verilerini yükle (Takvim hatasını çözer)
  await initializeDateFormatting('tr_TR', null);

  // FMTC (Flutter Map Tile Caching) başlat - Offline harita için
  try {
    await FMTCObjectBoxBackend().initialise();
  } catch (e) {
    // Zaten initialise edilmiş olabilir
  }

  // Arkaplan servisleri - paralel başlatma (daha hızlı açılış)
  await Future.wait([
    AlarmService.init(),
    NotificationService.init(),
    WidgetService.initialize(),
    ReminderService.init(),
  ]);

  // Native Foreground Service KAPATILDI - sadece Flutter bildirimi kullanılıyor
  // await ForegroundService.start();

  // Status bar renklendirme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Dikey ekran kilidi
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // İlk açılış kontrolü
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch =
      prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;
  final hasCity =
      prefs.getString(AppConstants.keySelectedCityId) != null;

  // Alarm çaldığında veya tıklandığında ekranı göster
  // Guard: Aynı alarmın ekranı birden fazla kez açılmasını önler
  final Set<int> activeAlarmScreenIds = {};

  Alarm.ringing.listen((alarmSet) {
    for (final alarmSettings in alarmSet.alarms) {
      if (activeAlarmScreenIds.contains(alarmSettings.id)) continue;
      activeAlarmScreenIds.add(alarmSettings.id);
      debugPrint("🚨 ALARM EKRANI AÇILIYOR: ID=${alarmSettings.id}");
      if (navigatorKey.currentContext != null) {
        Navigator.pushNamed(
          navigatorKey.currentContext!,
          '/adhan-alarm',
          arguments: {
            'prayerName': alarmSettings.notificationSettings.title,
            'cityName': prefs.getString(AppConstants.keySelectedCityName) ?? 'Türkiye',
            'prayerTime': 'Şimdi',
            'alarmId': alarmSettings.id,
          },
        ).then((_) => activeAlarmScreenIds.remove(alarmSettings.id));
      }
    }
  });

  runApp(
    ProviderScope(
      child: EzanVaktiApp(
        showCitySelection: isFirstLaunch || !hasCity,
      ),
    ),
  );
}


class EzanVaktiApp extends ConsumerWidget {
  final bool showCitySelection;

  const EzanVaktiApp({super.key, required this.showCitySelection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final variant = settingsAsync.asData?.value.themeVariant ?? AppThemeVariant.system;

    // Vakit değiştiğinde Widget + Bildirim senkronize et
    ref.listen(currentPrayerProvider, (previous, next) {
      if (next != null && previous?.index != next.index) {
        final city = ref.read(activeCityProvider).value;
        final times = ref.read(todayPrayerTimesProvider).value;
        if (city != null && times != null) {
          debugPrint("🔄 SENKRONİZASYON TETİKLENDİ: ${next.name}");
          try { WidgetService.updateWidgetData(city, times); } catch (_) {}
          // Sabit bildirim — yedek tetikleme (prayer_provider başarısız olursa)
          final nextP = times.getNextPrayer(DateTime.now());
          NotificationService.updatePersistentNotification(
            title: '${city.name} — Sıradaki: ${nextP.name} (${times.formatTime(nextP.time)})',
            body: 'İmsak: ${times.formatTime(times.fajr)}  •  Güneş: ${times.formatTime(times.sunrise)}  •  Öğle: ${times.formatTime(times.dhuhr)}\nİkindi: ${times.formatTime(times.asr)}  •  Akşam: ${times.formatTime(times.maghrib)}  •  Yatsı: ${times.formatTime(times.isha)}',
          );
        }
      }
    });

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Global key eklendi

      // Tema — whiteGreen=lightTheme, pureDark=darkTheme (aynı stil)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: variant.themeMode,

      // Başlangıç sayfası
      initialRoute: '/splash',


      // Yönlendirme
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/city-selection': (_) => const CitySelectionScreen(),
        '/home': (_) => const MainNavigationShell(),
        '/qibla': (_) => const QiblaScreen(),
        '/country-selection': (_) => const CountrySelectionScreen(),
        '/mosques': (_) => const MosqueMapScreen(),
        '/duas': (_) => const DuaScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/tasbih': (_) => const TasbihScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const DeveloperProfileScreen(),
        '/support': (_) => const SupportScreen(),
        '/alarms': (_) => const AlarmSettingsScreen(),
        '/notification-help': (_) => const NotificationHelpScreen(),
        '/adhan-alarm': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          return AdhanAlarmScreen(
            prayerName: args?['prayerName'] ?? 'Ezan Vakti',
            cityName: args?['cityName'] ?? 'Türkiye',
            prayerTime: args?['prayerTime'] ?? '',
            alarmId: args?['alarmId'] ?? 0,
          );
        },
        '/kerahat': (_) => const KerahatScreen(),
        '/ramadan': (_) => const _PlaceholderScreen(title: 'Ramazan'),
      },
    );
  }
}

/// Ana navigasyon kabuğu (Bottom Navigation Bar)
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    QiblaScreen(),
    MosqueMapScreen(),
    DuaScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _EzanBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _EzanBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _EzanBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.surfaceDark : AppTheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        // Üstte çok hafif border — No-Line Rule'a aykırı değil çünkü çok soluk
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Ana Sayfa', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.explore_rounded, label: 'Kıble', index: 1, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.mosque_rounded, label: 'Camiler', index: 2, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.auto_stories_rounded, label: 'Dualar', index: 3, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.settings_rounded, label: 'Ayarlar', index: 4, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Henüz geliştirilmemiş ekranlar için geçici placeholder
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded,
                size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              '$title\nyakında burada!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
