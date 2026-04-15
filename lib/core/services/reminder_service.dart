import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Namaz vakti öncesi bildirim servisi
class ReminderService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  static late SharedPreferences _prefs;
  
  static const String _kPrayerReminderMinutes = 'prayer_reminder_minutes';
  static const String _kReminderEnabled = 'reminder_enabled';

  /// Servisi başlat
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    debugPrint('Timezone ayarlandı: Europe/Istanbul');
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAMAZ VAKTİ ÖNCESİ HATIRLATICI (15dk, 30dk, 1saat)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Namaz vakti öncesi hatırlatma sürelerini kaydet
  static Future<void> setPrayerReminderMinutes(List<int> minutes) async {
    await _prefs.setStringList(
      _kPrayerReminderMinutes,
      minutes.map((m) => m.toString()).toList(),
    );
  }

  /// Namaz vakti öncesi hatırlatma sürelerini getir
  static List<int> getPrayerReminderMinutes() {
    final saved = _prefs.getStringList(_kPrayerReminderMinutes);
    if (saved == null) return [15, 30, 60]; // Varsayılan: 15dk, 30dk, 1saat
    return saved.map((s) => int.parse(s)).toList();
  }

  /// Namaz vakti öncesi bildirim planla
  static Future<void> schedulePrayerReminder({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    
    // Eğer vakit geçtiyse planlama
    if (reminderTime.isBefore(DateTime.now())) return;

    String title;
    String body;
    
    switch (minutesBefore) {
      case 15:
        title = '☪️ $prayerName Vakti Yaklaşıyor';
        body = '$prayerName vaktine 15 dakika kaldı. Hazırlanın.';
        break;
      case 30:
        title = '⏰ $prayerName Vaktine Yarım Saat';
        body = '$prayerName vaktine 30 dakika kaldı.';
        break;
      case 60:
        title = '🕌 $prayerName Vaktine 1 Saat';
        body = '$prayerName vaktine 1 saat kaldı. Planınızı yapın.';
        break;
      default:
        title = '📿 $prayerName Vakti Yaklaşıyor';
        body = '$prayerName vaktine $minutesBefore dakika kaldı.';
    }

    await _notifications.zonedSchedule(
      id: id + 10000 + minutesBefore,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminder_channel',
          'Namaz Vakti Hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.max,
          icon: 'ic_notification',
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('zikir'),
          category: AndroidNotificationCategory.reminder,
          ongoing: true,
          autoCancel: false,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'zikir.mp3',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Tüm namaz hatırlatıcılarını iptal et
  static Future<void> cancelAllPrayerReminders() async {
    // 10000-20000 arası ID'leri temizle (namaz hatırlatıcıları)
    for (int i = 10000; i < 20000; i++) {
      await _notifications.cancel(id: i);
    }
  }

  /// Hatırlatıcı aktif mi?
  static bool isReminderEnabled() {
    return _prefs.getBool(_kReminderEnabled) ?? true;
  }

  /// Hatırlatıcıyı aç/kapat
  static Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(_kReminderEnabled, enabled);
  }
}
