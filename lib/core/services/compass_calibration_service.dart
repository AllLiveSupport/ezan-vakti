import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Pusula kalibrasyon servisi
/// Hassasiyet ayarı ve sensör kalibrasyonu yönetir
/// Not: Bu servis pusula heading verisi almaz, sadece kalibrasyon parametreleri yönetir
class CompassCalibrationService {
  static late SharedPreferences _prefs;
  static StreamSubscription<AccelerometerEvent>? _accelSubscription;
  
  // Kalibrasyon durumu
  static bool _isCalibrating = false;
  static double _calibrationOffset = 0.0;
  
  /// Kalibrasyon durumunu kontrol et
  static bool get isCalibrating => _isCalibrating;
  static double _sensitivity = 1.0;
  static double _smoothedHeading = 0.0;
  
  // Callback'ler
  static Function(double accuracy)? onAccuracyChanged;
  static Function(bool isCalibrated)? onCalibrationComplete;

  // Hassasiyet seviyeleri
  static const Map<String, double> sensitivityLevels = {
    'low': 0.5,      // Düşük hassasiyet (daha az titreşim)
    'medium': 1.0,   // Orta hassasiyet (varsayılan)
    'high': 2.0,     // Yüksek hassasiyet (hızlı tepki)
  };

  /// Servisi başlat
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _calibrationOffset = _prefs.getDouble('compass_calibration_offset') ?? 0.0;
    _sensitivity = _prefs.getDouble('compass_sensitivity') ?? 1.0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KALİBRASYON
  // ═══════════════════════════════════════════════════════════════════════════

  /// Kalibrasyon başlat
  static Future<void> startCalibration() async {
    _isCalibrating = true;
    
    // 8 şekil çizimini algıla (kullanıcı 8 şeklinde telefonu hareket ettirsin)
    _accelSubscription?.cancel();
    _accelSubscription = accelerometerEventStream().listen((event) {
      // 8 şekil hareketi algılama (basit versiyon)
      _detectFigure8(event);
    });
  }

  /// Kalibrasyonu tamamla
  static Future<void> completeCalibration() async {
    _isCalibrating = false;
    
    // Dinleyicileri temizle
    await _accelSubscription?.cancel();
    _accelSubscription = null;
    
    onCalibrationComplete?.call(true);
  }

  /// Kalibrasyonu iptal et
  static Future<void> cancelCalibration() async {
    _isCalibrating = false;
    
    await _accelSubscription?.cancel();
    _accelSubscription = null;
    
    onCalibrationComplete?.call(false);
  }

  /// Kalibrasyon offset'ini kaydet
  static Future<void> setCalibrationOffset(double offset) async {
    _calibrationOffset = offset;
    await _prefs.setDouble('compass_calibration_offset', offset);
  }

  /// Kalibrasyon offset'ini uygula
  static double applyCalibration(double heading) {
    double calibrated = heading + _calibrationOffset;
    
    // 0-360 aralığına normalize et
    while (calibrated < 0) {
      calibrated += 360;
    }
    while (calibrated >= 360) {
      calibrated -= 360;
    }
    
    return calibrated;
  }

  /// Kalibrasyon durumunu sıfırla
  static Future<void> resetCalibration() async {
    _calibrationOffset = 0.0;
    await _prefs.setDouble('compass_calibration_offset', 0.0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HASSASİYET AYARI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Hassasiyet seviyesini ayarla
  static Future<void> setSensitivity(String level) async {
    if (sensitivityLevels.containsKey(level)) {
      _sensitivity = sensitivityLevels[level]!;
      await _prefs.setDouble('compass_sensitivity', _sensitivity);
    }
  }

  /// Özel hassasiyet değeri ayarla (0.1 - 3.0)
  static Future<void> setCustomSensitivity(double value) async {
    _sensitivity = value.clamp(0.1, 3.0);
    await _prefs.setDouble('compass_sensitivity', _sensitivity);
  }

  /// Mevcut hassasiyeti getir
  static double get sensitivity => _sensitivity;
  static String get sensitivityLevel {
    if (_sensitivity <= 0.6) return 'low';
    if (_sensitivity >= 1.5) return 'high';
    return 'medium';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMOOTHING ( titreşim azaltma )
  // ═══════════════════════════════════════════════════════════════════════════

  /// Heading değerini yumuşat (low-pass filter)
  static double smoothHeading(double newHeading) {
    // Hassasiyete göre smoothing faktörü
    final alpha = 0.1 * _sensitivity;
    
    // Açı farkını hesapla (en kısa yol)
    double diff = newHeading - _smoothedHeading;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    
    // Yumuşatma uygula
    _smoothedHeading = (_smoothedHeading + alpha * diff) % 360;
    if (_smoothedHeading < 0) _smoothedHeading += 360;
    
    return _smoothedHeading;
  }

  /// Smoothing'i sıfırla
  static void resetSmoothing() {
    _smoothedHeading = 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOĞRULUK KONTROLÜ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sensör doğruluk değerlendirmesi
  static double calculateAccuracy(List<double> samples) {
    if (samples.length < 2) return 0;
    
    // Standart sapma hesapla
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final variance = samples.map((h) {
      double diff = h - mean;
      while (diff > 180) {
        diff -= 360;
      }
      while (diff < -180) {
        diff += 360;
      }
      return diff * diff;
    }).reduce((a, b) => a + b) / samples.length;
    
    final stdDev = math.sqrt(variance);
    
    // 0-100 arası doğruluk skoru (düşük stdDev = yüksek doğruluk)
    return math.max(0, 100 - stdDev * 2);
  }

  /// 8 şekil hareketi algılama (basit)
  static void _detectFigure8(AccelerometerEvent event) {
    // Basit implementasyon: Zamanla değişen ivme hareketlerini algıla
    // Gerçek implementasyonda daha karmaşık algoritmalar kullanılabilir
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TITREŞİM GERİ BİLDİRİM
  // ═══════════════════════════════════════════════════════════════════════════

  /// Kalibrasyon başarılı titreşimi
  static void calibrationSuccessFeedback() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Kalibrasyon hatası titreşimi
  static void calibrationErrorFeedback() {
    HapticFeedback.vibrate();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KAYNAK TEMİZLİĞİ
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> dispose() async {
    _isCalibrating = false;
    await _accelSubscription?.cancel();
    _accelSubscription = null;
  }
}

/// Kalibrasyon durumu modeli
class CalibrationState {
  final bool isCalibrating;
  final double progress;
  final double accuracy;
  final String? message;

  const CalibrationState({
    this.isCalibrating = false,
    this.progress = 0,
    this.accuracy = 0,
    this.message,
  });
}
