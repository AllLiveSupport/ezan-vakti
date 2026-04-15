import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Bildirime tıklandı: ${response.payload}');
      },
    );

    // Android 13+ izin talebi splash screen'de yapılır (aktivite hazır olduğunda)

    // ─── Ezan Kanalı: res/raw/adhan.mp3 ile yerel ses ───────────────────────
    // Bu yöntem AudioPlayer gibi Flutter bileşeni gerektirmez.
    // OS doğrudan Android MediaPlayer ile sesi çalar — en güvenilir yöntem.
    const AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      'adhan_channel_id',
      'Ezan Bildirimleri',
      description: 'Ezan vaktinde tam ekran uyarı ve özel ezan sesi.',
      importance: Importance.max,
      playSound: true,
      // res/raw/adhan.mp3 — Flutter asset DEĞİL, Android native resource
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
      enableLights: true,
    );

    // ─── Sabit Bildirim Kanalı ────────────────────────────────────────────────
    // Importance.defaultImportance: Xiaomi/MIUI'de low kanallar bastırılıyor
    // playSound:false + enableVibration:false ile sessiz tutulur
    const AndroidNotificationChannel permanentChannel = AndroidNotificationChannel(
      'prayer_times_v2',
      'Namaz Vakitleri (Sabit)',
      description: 'Bildirim çubuğunda vakitleri gösteren sabit bildirim.',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    // ─── Zikir Hatırlatıcı Kanalı ─────────────────────────────────────────────
    final AndroidNotificationChannel zikrChannel = AndroidNotificationChannel(
      'zikr_reminder_channel',
      'Zikir Hatırlatıcıları',
      description: 'Zikir hatırlatıcıları için yüksek öncelikli bildirimler',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // ─── Namaz Vakti Hatırlatıcı Kanalı ───────────────────────────────────────
    final AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'prayer_reminder_channel',
      'Namaz Vakti Hatırlatıcıları',
      description: 'Namaz vakti hatırlatıcıları için yüksek öncelikli bildirimler',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(adhanChannel);
    await androidPlugin?.createNotificationChannel(permanentChannel);
    await androidPlugin?.createNotificationChannel(zikrChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);

    // Eski kanalı sil — importance güncellenemez, yeni kanal gerekli
    await androidPlugin?.deleteNotificationChannel(channelId: 'prayer_times_permanent');
  }

  /// Sabit bildirimi günceller (Tüm vakitleri gösterir)
  static Future<void> updatePersistentNotification({
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_times_v2',
      'Namaz Vakitleri (Sabit)',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
      ),
    );

    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    debugPrint('📢 Sabit bildirim güncelleniyor: $title');
    await _notificationsPlugin.show(
      id: 888,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  /// Ezan vakti bildirimi — Tam ekran intent + res/raw/adhan.mp3 sesi
  static Future<void> showAdhanNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelDetails =
        AndroidNotificationDetails(
      'adhan_channel_id',
      'Ezan Bildirimleri',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Ezan Vakti',
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      color: const Color(0xFF1AC2B2),
      // Kanalda tanımlı adhan sesi otomatik çalınır
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('adhan'),
      // Alarm gibi davran: cihaz sessiz modda bile çal
      channelAction: AndroidNotificationChannelAction.update,
    );

    final NotificationDetails platformChannelDetails =
        NotificationDetails(android: androidPlatformChannelDetails);

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelDetails,
      payload: payload,
    );
  }

  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
