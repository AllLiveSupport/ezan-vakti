import 'package:flutter/services.dart';

/// Zikirmatik titreşim servisi
/// Her 33, 99 ve 100'de farklı haptic feedback patternleri
/// Not: Flutter'ın yerleşik HapticFeedback API'si kullanılır
/// (Paket bağımlılığı olmadan, tüm cihazlarda çalışır)
class VibrationService {
  static bool _isInitialized = false;

  /// Servisi başlat
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Sayıya göre uygun haptic feedback çalıştır
  /// - 33: Hafif tik
  /// - 99: Çift tik
  /// - 100: Uzun kutlama patterni
  static Future<void> vibrateOnCount(int count) async {
    if (count == 33) {
      await _vibrate33();
    } else if (count == 99) {
      await _vibrate99();
    } else if (count == 100) {
      await _vibrate100();
    }
  }

  /// 33. zikir: Hafif tek tik (Subhanallah tamamlandı)
  static Future<void> _vibrate33() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// 99. zikir: İkili tik (Alhamdulillah tamamlandı)
  static Future<void> _vibrate99() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
  }

  /// 100. zikir: Uzun kutlama (Allahu Akbar tamamlandı)
  static Future<void> _vibrate100() async {
    // 3x heavy impact
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    // Final success feedback
    HapticFeedback.mediumImpact();
  }

  /// Manuel test için titreşim
  static Future<void> testVibration() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }

  /// Cihazda titreşim var mı? (Her zaman true - haptic feedback vardır)
  static bool get hasVibrator => true;
}
