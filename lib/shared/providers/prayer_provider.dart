// lib/shared/providers/prayer_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';
import '../models/city_model.dart';
import '../../core/network/prayer_times_service.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/widget_service.dart';
import '../../core/constants/app_constants.dart';
import 'settings_provider.dart';

// ─── Service Provider ───────────────────────────────────────────────────────
final prayerTimesServiceProvider = Provider<PrayerTimesService>((ref) {
  return PrayerTimesService();
});

// ─── Active City Provider ────────────────────────────────────────────────────
final activeCityProvider = FutureProvider<CityModel?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final cityId = prefs.getString(AppConstants.keySelectedCityId);
  if (cityId == null) return null;

  final countryCode = prefs.getString(AppConstants.keySelectedCountryCode) ?? 'TR';
  final method = prefs.getInt(AppConstants.keyCityMethod);

  return CityModel(
    id: cityId,
    name: prefs.getString(AppConstants.keySelectedCityName) ?? 'İstanbul',
    lat: prefs.getDouble(AppConstants.keyCityLat) ?? 41.0082,
    lon: prefs.getDouble(AppConstants.keyCityLon) ?? 28.9784,
    timezone: prefs.getString(AppConstants.keyCityTimezone) ?? 'Europe/Istanbul',
    countryCode: countryCode,
    method: method,
    diyanetId: countryCode == 'TR' ? 9541 : null,
    region: countryCode == 'TR' ? 'Marmara' : null,
  );
});

// ─── Today Prayer Times Provider ────────────────────────────────────────────
final todayPrayerTimesProvider = FutureProvider<PrayerTimesModel?>((ref) async {
  final cityAsync = ref.watch(activeCityProvider);
  // Riverpod 3.x: .value yerine .when veya AsyncData check
  final city = switch (cityAsync) {
    AsyncData(value: final v) => v,
    _ => null,
  };
  if (city == null) return null;

  final settingsAsync = ref.watch(settingsProvider);
  final settings = switch (settingsAsync) {
    AsyncData(value: final v) => v,
    _ => null,
  };
  if (settings == null) return null;

  final service = ref.read(prayerTimesServiceProvider);
  final times = await service.getTodayPrayerTimes(
    cityId: city.id,
    lat: city.lat,
    lon: city.lon,
    cityName: city.name,
    settings: settings,
    countryCode: city.countryCode,
    cityMethod: city.method,
  );

  // Alarmları arka planda kur ve widget/bildirim güncelle
  // Her biri bağımsız try-catch — biri patlarsa diğerleri çalışmaya devam eder
  Future.microtask(() async {
    try {
      await _scheduleAllAlarms(times, settings);
    } catch (e) {
      debugPrint('⚠️ Alarm kurulumu hatası: $e');
    }
    try {
      await WidgetService.updateWidgetData(city, times);
    } catch (e) {
      debugPrint('⚠️ Widget güncelleme hatası: $e');
    }
    try {
      await _updateStatusNotification(city, times);
    } catch (e) {
      debugPrint('⚠️ Bildirim güncelleme hatası: $e');
    }
  });

  return times;
});

Future<void> _updateStatusNotification(CityModel city, PrayerTimesModel times) async {
  final now = DateTime.now();
  final next = times.getNextPrayer(now);
  
  // Örn: İstanbul - Sıradaki: Akşam (18:45)
  final title = "${city.name} — Sıradaki: ${next.name} (${times.formatTime(next.time)})";
  
  // 2 satır: İmsak/Güneş/Öğle + İkindi/Akşam/Yatsı
  final body = "İmsak: ${times.formatTime(times.fajr)}  •  Güneş: ${times.formatTime(times.sunrise)}  •  Öğle: ${times.formatTime(times.dhuhr)}\nİkindi: ${times.formatTime(times.asr)}  •  Akşam: ${times.formatTime(times.maghrib)}  •  Yatsı: ${times.formatTime(times.isha)}";
  
  // Flutter bildirimi (uygulama açıkken)
  await NotificationService.updatePersistentNotification(
    title: title,
    body: body,
  );

  // Native foreground service için vakitleri SharedPreferences'a kaydet
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('notif_city', city.name);
  await prefs.setString('notif_fajr', times.formatTime(times.fajr));
  await prefs.setString('notif_sunrise', times.formatTime(times.sunrise));
  await prefs.setString('notif_dhuhr', times.formatTime(times.dhuhr));
  await prefs.setString('notif_asr', times.formatTime(times.asr));
  await prefs.setString('notif_maghrib', times.formatTime(times.maghrib));
  await prefs.setString('notif_isha', times.formatTime(times.isha));

  // Native foreground service başlat — uygulama kapatılsa bile bildirim kalır
  try {
    const channel = MethodChannel('com.alllivesupport.ezanvakti/service');
    await channel.invokeMethod('startForegroundService');
    debugPrint('✅ Native foreground service başlatıldı');
  } catch (e) {
    debugPrint('⚠️ Native service başlatılamadı: $e');
  }
}

Future<void> _scheduleAllAlarms(PrayerTimesModel times, AppSettings settings) async {
  final now = DateTime.now();
  final prayers = [
    (id: 1, name: 'İmsak', time: times.fajr),
    (id: 2, name: 'Güneş', time: times.sunrise),
    (id: 3, name: 'Öğle', time: times.dhuhr),
    (id: 4, name: 'İkindi', time: times.asr),
    (id: 5, name: 'Akşam', time: times.maghrib),
    (id: 6, name: 'Yatsı', time: times.isha),
  ];

  for (int i = 0; i < prayers.length; i++) {
    final prayer = prayers[i];
    final isAdhanEnabled = settings.prayerAdhanEnabled[i];
    final isNotifEnabled = settings.prayerNotifEnabled[i];
    final offset = settings.prayerOffsets[i];

    // Vakit + Offset (Ezan vakti oynamasın, sadece alarm kurulsun)
    final targetTime = prayer.time.add(Duration(minutes: offset));

    if (targetTime.isAfter(now)) {
      if (isAdhanEnabled || isNotifEnabled) {
        await AlarmService.schedulePrayerAlarm(
          id: prayer.id,
          targetTime: targetTime,
          prayerName: prayer.name,
          playSound: isAdhanEnabled, // Ezan kapalıysa ses yok, sadece titreşimli bildirim
        );
      } else {
        await AlarmService.cancelAlarm(prayer.id);
      }
    }
  }
}

// ─── Countdown Provider ─────────────────────────────────────────────────────
class CountdownNotifier extends Notifier<Duration> {
  Timer? _timer;

  @override
  Duration build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return Duration.zero;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    final prayerAsync = ref.read(todayPrayerTimesProvider);
    final prayerTimes = switch (prayerAsync) {
      AsyncData(value: final v) => v,
      _ => null,
    };
    if (prayerTimes == null) {
      state = Duration.zero;
      return;
    }

    final now = DateTime.now();
    final next = prayerTimes.getNextPrayer(now);
    final remaining = next.time.difference(now);
    state = remaining.isNegative ? Duration.zero : remaining;
  }
}

final countdownProvider = NotifierProvider<CountdownNotifier, Duration>(
  CountdownNotifier.new,
);

// ─── Next Prayer Provider ────────────────────────────────────────────────────
final nextPrayerProvider = Provider<({String name, DateTime time, int index})?>(
  (ref) {
    final prayerAsync = ref.watch(todayPrayerTimesProvider);
    
    // Real-time güncelleme için saniyelik provider'ı izle
    // Sadece dakika değiştiğinde güncelle (performans için)
    ref.watch(_minuteProvider);

    final prayerTimes = switch (prayerAsync) {
      AsyncData(value: final v) => v,
      _ => null,
    };
    if (prayerTimes == null) return null;
    return prayerTimes.getNextPrayer(DateTime.now());
  },
);

// ─── Minute Provider (dakika değiştiğinde günceller, her saniye değil) ─────
class _MinuteNotifier extends Notifier<int> {
  Timer? _timer;
  int _lastMinute = -1;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _checkMinute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _checkMinute());
    return DateTime.now().minute;
  }

  void _checkMinute() {
    final now = DateTime.now();
    if (now.minute != _lastMinute) {
      _lastMinute = now.minute;
      state = now.minute;
    }
  }
}

final _minuteProvider = NotifierProvider<_MinuteNotifier, int>(_MinuteNotifier.new);

// ─── Current Prayer Provider ─────────────────────────────────────────────────
final currentPrayerProvider = Provider<({String name, int index})?>((ref) {
  final prayerAsync = ref.watch(todayPrayerTimesProvider);
  
  // Real-time güncelleme - dakika değiştiğinde tetiklenir (performans için)
  ref.watch(_minuteProvider);

  final prayerTimes = switch (prayerAsync) {
    AsyncData(value: final v) => v,
    _ => null,
  };
  if (prayerTimes == null) return null;
  return prayerTimes.getCurrentPrayer(DateTime.now());
});

// ─── Hijri Date Provider ─────────────────────────────────────────────────────
final hijriDateProvider = FutureProvider<String>((ref) async {
  final service = ref.read(prayerTimesServiceProvider);
  return service.getHijriDate(DateTime.now());
});

// ─── Duration Format Extension ────────────────────────────────────────────────
extension PrayerDurationFormatting on Duration {
  /// "02:45:12" formatı
  String get hms {
    final h = inHours.toString().padLeft(2, '0');
    final m = (inMinutes % 60).toString().padLeft(2, '0');
    final s = (inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// "2 sa 45 dk" kısa format
  String get shortFormat {
    if (inHours > 0) {
      return '$inHours sa ${inMinutes % 60} dk';
    }
    return '$inMinutes dk ${inSeconds % 60} sn';
  }
}
