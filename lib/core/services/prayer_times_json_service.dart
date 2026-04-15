import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PrayerTimesJsonService {
  static final PrayerTimesJsonService _instance = PrayerTimesJsonService._internal();
  factory PrayerTimesJsonService() => _instance;
  PrayerTimesJsonService._internal();

  final Map<String, dynamic> _cache = {};

  /// Belirtilen yıl ve şehir için namaz vakitlerini yükle
  Future<Map<String, dynamic>?> loadCityPrayerTimes(int year, String cityName) async {
    final cacheKey = '${year}_$cityName';
    
    // Cache'de varsa döndür
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      // Dosya adını oluştur - normalize edilmiş şehir adı
      // Örnek: Adana -> Adana_2026.json, İstanbul -> Istanbul_2026.json
      final normalizedCity = _normalizeCityName(cityName);
      final fileName = '${normalizedCity}_$year.json';
      final path = 'assets/data/prayer_times/$year/$fileName';
      
      debugPrint('📂 JSON dosyası aranıyor: $path');
      debugPrint('🔤 Normalize edilmiş şehir: $normalizedCity (orijinal: $cityName)');
      
      // JSON'u yükle
      final jsonString = await rootBundle.loadString(path);
      final data = json.decode(jsonString);
      
      debugPrint('✅ JSON yüklendi: ${data['city']} - ${data['year']}');
      
      // Cache'e ekle
      _cache[cacheKey] = data;
      return data;
    } catch (e) {
      debugPrint('❌ JSON yüklenirken HATA: $e');
      debugPrint('   Şehir: $cityName, Yıl: $year');
      return null;
    }
  }

  /// Belirli bir tarih için namaz vakitlerini getir
  Future<Map<String, String>?> getPrayerTimesForDate(
    int year, 
    String cityName, 
    String date // format: "DD.MM.YYYY"
  ) async {
    final cityData = await loadCityPrayerTimes(year, cityName);
    if (cityData == null) return null;

    final prayers = cityData['data'] as Map<String, dynamic>?;
    if (prayers == null) return null;

    // Tarih formatını kontrol et
    final dayData = prayers[date] as Map<String, dynamic>?;
    if (dayData == null) return null;

    return {
      'imsak': dayData['imsak'] ?? '',
      'sabah': dayData['sabah'] ?? '',
      'gunes': dayData['gunes'] ?? '',
      'ogle': dayData['ogle'] ?? '',
      'ikindi': dayData['ikindi'] ?? '',
      'aksam': dayData['aksam'] ?? '',
      'yatsi': dayData['yatsi'] ?? '',
    };
  }

  /// Bugünün namaz vakitlerini getir
  Future<Map<String, String>?> getTodayPrayerTimes(String cityName) async {
    final now = DateTime.now();
    // JSON formatı: "06-04-2026" (tire ile)
    final dateStr = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    debugPrint('📅 Tarih formatı: $dateStr');
    return getPrayerTimesForDate(now.year, cityName, dateStr);
  }

  /// Tüm yılları kontrol et ve mevcut olanı döndür
  Future<Map<String, dynamic>?> loadCityWithFallback(String cityName) async {
    final currentYear = DateTime.now().year;
    final years = [currentYear, currentYear + 1, currentYear + 2];

    for (final year in years) {
      final data = await loadCityPrayerTimes(year, cityName);
      if (data != null) return data;
    }
    return null;
  }

  /// Cache'i temizle
  void clearCache() {
    _cache.clear();
  }

  /// Şehir adını normalize et (dosya adı için)
  String _normalizeCityName(String name) {
    return name
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 's')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'g')
        .replaceAll('Ü', 'U')
        .replaceAll('ü', 'u')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'o')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'c')
        .replaceAll(' ', '_');
  }
}
