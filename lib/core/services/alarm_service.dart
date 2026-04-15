import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmService {
  static Future<void> init() async {
    // alarm paketini başlat
    await Alarm.init();

    // Alarm paketinin arkaplan izinlerini vb. istemesini sağla (gerekirse)
    if (Alarm.android) {
       // Android'e özgü ek konfigürasyon yapılabilir.
    }
  }

  static Future<void> schedulePrayerAlarm({
    required int id,
    required DateTime targetTime,
    required String prayerName,
    bool playSound = true,
  }) async {
    if (targetTime.isBefore(DateTime.now())) return;

    debugPrint("🔔 ALARM KURULDU (alarm paketi): $prayerName -> $targetTime (ID: $id) [Ses: $playSound]");

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: targetTime,
      assetAudioPath: 'assets/sounds/adhan.mp3',
      loopAudio: playSound, // Ezan açıksa döngüde çalsın
      vibrate: true, // Her durumda titreşim
      volumeSettings: VolumeSettings.fade(
        volume: playSound ? 1.0 : 0.0, // Ezan kapalıysa ses yok
        fadeDuration: const Duration(seconds: 3),
        volumeEnforced: playSound, // Sadece ezan açıksa cihaz sesini zorla
      ),
      notificationSettings: NotificationSettings(
        title: '$prayerName Vakti 🕌',
        body: playSound ? 'Haydi Felaha, Haydi Namaza' : '$prayerName vakti girdi',
        stopButton: 'Durdur',
      ),
      warningNotificationOnKill: true,
      androidFullScreenIntent: playSound, // Sadece ezan açıksa tam ekran
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
    debugPrint("🔕 ALARM İPTAL: ID=$id");
  }
}

