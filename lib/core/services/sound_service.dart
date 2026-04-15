import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Zikir ses servisi
/// 33, 99, 100 milestone'larında özel sesler çalar
class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;
  static bool _soundEnabled = true;

  /// Servisi başlat
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Ses seviyesini ayarla
    await _audioPlayer.setVolume(0.8);
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
  }

  /// Ses ayarını değiştir
  static Future<void> setEnabled(bool enabled) async {
    _soundEnabled = enabled;
  }

  /// Ses açık mı?
  static bool get isEnabled => _soundEnabled;

  /// Her tıklamada çalacak hafif tik sesi (correct.mp3 kullan)
  static Future<void> playClick() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'), volume: 0.8);
      debugPrint('🔊 Click sesi çalındı');
    } catch (e) {
      debugPrint('❌ Ses çalma hatası: $e');
    }
  }

  /// 33. zikir - Subhanallah tamamlandı
  static Future<void> playMilestone33() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('Ses çalma hatası: $e');
    }
  }

  /// 99. zikir - Alhamdulillah tamamlandı
  static Future<void> playMilestone99() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('Ses çalma hatası: $e');
    }
  }

  /// 100. zikir - Allahu Akbar tamamlandı
  static Future<void> playMilestone100() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('Ses çalma hatası: $e');
    }
  }

  /// Sayıya göre uygun sesi çal
  /// 33, 99, 100 ve normal tıklamalarda correct.mp3 çal
  static Future<void> playForCount(int count) async {
    debugPrint('🔔 playForCount çağrıldı: count=$count, enabled=$_soundEnabled');
    if (count == 33 || count == 99 || count == 100) {
      // Milestone'lar için correct.mp3 çal (yüksek volümlü)
      if (!_soundEnabled) return;
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'), volume: 1.0);
        debugPrint('🔊 Milestone sesi çalındı: $count');
      } catch (e) {
        debugPrint('❌ Ses çalma hatası: $e');
      }
    } else {
      await playClick();
    }
  }

  /// Servisi temizle
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
