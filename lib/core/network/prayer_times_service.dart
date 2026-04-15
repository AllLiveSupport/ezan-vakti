// lib/core/network/prayer_times_service.dart
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../shared/models/prayer_times_model.dart';
import '../../shared/providers/settings_provider.dart';
import '../constants/app_constants.dart';
import '../services/prayer_times_json_service.dart';

/// Namaz vakti servisi — Online (AlAdhan) + Offline (adhan) hibrit
class PrayerTimesService {
  final Dio _dio;
  final Connectivity _connectivity;

  PrayerTimesService({Dio? dio, Connectivity? connectivity})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.aladhanBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            )),
        _connectivity = connectivity ?? Connectivity();

  Future<PrayerTimesModel> getTodayPrayerTimes({
    required String cityId,
    required double lat,
    required double lon,
    required String cityName,
    required AppSettings settings,
    String? countryCode,
    int? cityMethod,
  }) async {
    final isOnline = await _isOnline();
    final offsets = settings.prayerOffsets;
    final isTurkey = (countryCode == 'TR') || cityId.startsWith('TR_');

    // Önce JSON assets'ten dene (Türkiye için hızlı offline veri)
    if (isTurkey) {
      try {
        debugPrint('🔍 JSON yükleniyor... Şehir: $cityName, Yıl: ${DateTime.now().year}');
        final jsonService = PrayerTimesJsonService();
        final today = await jsonService.getTodayPrayerTimes(cityName);
        if (today != null) {
          debugPrint('✅ JSON yüklendi! İmsak: ${today['imsak']}, Sabah: ${today['sabah']}');
          final now = DateTime.now();
          return PrayerTimesModel(
            cityId: cityId,
            date: DateTime(now.year, now.month, now.day),
            imsak: _parseTime(today['imsak']!, now),  // İmsak vakti
            fajr: _parseTime(today['sabah']!, now),   // Sabah vakti = Fajr
            sunrise: _parseTime(today['gunes']!, now),
            dhuhr: _parseTime(today['ogle']!, now),
            asr: _parseTime(today['ikindi']!, now),
            maghrib: _parseTime(today['aksam']!, now),
            isha: _parseTime(today['yatsi']!, now),
            hijriDate: '',
            calculationMethod: 'Diyanet İşleri (JSON)',
            fetchedAt: DateTime.now(),
          );
        } else {
          debugPrint('❌ JSON null döndü!');
        }
      } catch (e, stack) {
        debugPrint('❌ JSON hatası: $e');
        debugPrint(stack.toString());
        // JSON yoksa API/Offline hesaplamaya devam et
      }
    }

    if (isOnline) {
      try {
        return await _fetchFromAlAdhan(
          cityId: cityId,
          lat: lat,
          lon: lon,
          date: DateTime.now(),
          settings: settings,
          offsets: offsets,
          countryCode: countryCode,
          cityMethod: cityMethod,
        );
      } catch (_) {
        return _calculateOffline(
          cityId: cityId,
          lat: lat,
          lon: lon,
          date: DateTime.now(),
          settings: settings,
          offsets: offsets,
          cityMethod: cityMethod,
        );
      }
    } else {
      return _calculateOffline(
        cityId: cityId,
        lat: lat,
        lon: lon,
        date: DateTime.now(),
        settings: settings,
        offsets: offsets,
        cityMethod: cityMethod,
      );
    }
  }

  /// Belirli bir gün için AlAdhan API'den çek
  Future<PrayerTimesModel> _fetchFromAlAdhan({
    required String cityId,
    required double lat,
    required double lon,
    required DateTime date,
    required AppSettings settings,
    required List<int> offsets,
    String? countryCode,
    int? cityMethod,
  }) async {
    final isTurkey = (countryCode == 'TR') || (countryCode == null && settings.calculationMethod == 'Turkey');
    
    // Eğer Türkiye ise ve şehir ismi varsa (TR_ADA -> ADA), timingsByCity kullan.
    // Bu, Diyanet için şehir bazlı veritabanı ofsetlerini (Sunrise vs) otomatik getirir.
    final useCityName = isTurkey && cityId.startsWith('TR_');
    
    final path = useCityName 
        ? '/timingsByCity/${date.day}-${date.month}-${date.year}'
        : '/timings/${date.millisecondsSinceEpoch ~/ 1000}';

    final resolvedMethod = cityMethod ?? _aladhanMethodMap[settings.calculationMethod] ?? AppConstants.diyanetMethod;

    final queryParams = useCityName
        ? {
            'city': _getTurkishCityName(cityId),
            'country': 'Turkey',
            'method': 13,
            'tune': '1,0,0,0,0,2,0,1,0', // [Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, Midnight, Imsak, Sunset]
          }
        : {
            'latitude': lat,
            'longitude': lon,
            'method': resolvedMethod,
            'school': settings.madhab == 'Hanafi' ? AppConstants.hanafiSchool : AppConstants.shafiSchool,
          };

    final response = await _dio.get(path, queryParameters: queryParams);

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PrayerTimesModel.fromAlAdhanJson(
        cityId: cityId,
        json: data,
        calculationMethod: isTurkey ? 'Diyanet İşleri Başkanlığı' : settings.calculationMethod,
        offsets: offsets,
      );
    }
    throw Exception('AlAdhan API error: ${response.statusCode}');
  }

  String _getTurkishCityName(String cityId) {
    // TR_ADA -> Adana
    final map = {
      'TR_ADA': 'Adana', 'TR_ADI': 'Adiyaman', 'TR_AFY': 'Afyon', 'TR_AGR': 'Agri',
      'TR_AKS': 'Aksaray', 'TR_AMA': 'Amasya', 'TR_ANK': 'Ankara', 'TR_ANT': 'Antalya',
      'TR_ARD': 'Ardahan', 'TR_ART': 'Artvin', 'TR_AYD': 'Aydin', 'TR_BAL': 'Balikesir',
      'TR_BAR': 'Bartin', 'TR_BAT': 'Batman', 'TR_BAY': 'Bayburt', 'TR_BIL': 'Bilecik',
      'TR_BIN': 'Bingol', 'TR_BIT': 'Bitlis', 'TR_BOL': 'Bolu', 'TR_BRD': 'Burdur',
      'TR_BRS': 'Bursa', 'TR_CAN': 'Canakkale', 'TR_CKR': 'Cankiri', 'TR_CRM': 'Corum',
      'TR_DEN': 'Denizli', 'TR_DYB': 'Diyarbakir', 'TR_DUZ': 'Duzce', 'TR_EDR': 'Edirne',
      'TR_ELZ': 'Elazig', 'TR_ERC': 'Erzincan', 'TR_ERZ': 'Erzurum', 'TR_ESK': 'Eskisehir',
      'TR_GAZ': 'Gaziantep', 'TR_GIR': 'Giresun', 'TR_GMS': 'Gumushane', 'TR_HAK': 'Hakkari',
      'TR_HAT': 'Hatay', 'TR_IGD': 'Igdir', 'TR_ISP': 'Isparta', 'TR_IST': 'Istanbul',
      'TR_IZM': 'Izmir', 'TR_KAH': 'Kahramanmaras', 'TR_KRA': 'Karabuk', 'TR_KAR': 'Karaman',
      'TR_KRS': 'Kars', 'TR_KST': 'Kastamonu', 'TR_KAY': 'Kayseri', 'TR_KKL': 'Kirikkale',
      'TR_KLR': 'Kirklareli', 'TR_KSI': 'Kirsehir', 'TR_KLI': 'Kilis', 'TR_KOC': 'Kocaeli',
      'TR_KON': 'Konya', 'TR_KUT': 'Kütahya', 'TR_MAL': 'Malatya', 'TR_MAN': 'Manisa',
      'TR_MAR': 'Mardin', 'TR_MER': 'Mersin', 'TR_MUG': 'Mugla', 'TR_MUS': 'Mus',
      'TR_NEV': 'Nevsehir', 'TR_NIG': 'Nigde', 'TR_ORD': 'Ordu', 'TR_OSM': 'Osmaniye',
      'TR_RIZ': 'Rize', 'TR_SAK': 'Sakarya', 'TR_SAM': 'Samsun', 'TR_SII': 'Siirt',
      'TR_SAN': 'Sanliurfa', 'TR_SIR': 'Sirnak', 'TR_SIN': 'Sinop', 'TR_SIV': 'Sivas',
      'TR_TEK': 'Tekirdag', 'TR_TOK': 'Tokat', 'TR_TRZ': 'Trabzon', 'TR_TUN': 'Tunceli',
      'TR_USK': 'Usak', 'TR_VAN': 'Van', 'TR_YAL': 'Yalova', 'TR_YOZ': 'Yozgat', 'TR_ZON': 'Zonguldak'
    };
    return map[cityId] ?? 'Istanbul';
  }

  /// OFFLINE HESAPLAMA — adhan paketi
  PrayerTimesModel _calculateOffline({
    required String cityId,
    required double lat,
    required double lon,
    required DateTime date,
    required AppSettings settings,
    required List<int> offsets,
    int? cityMethod,
  }) {
    final coordinates = Coordinates(lat, lon);

    final params = cityMethod != null
        ? _getOfflineParamsForMethod(cityMethod)
        : _getOfflineParams(settings);
    params.madhab = settings.madhab == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;
    
    // adhan paketi: 3 positional parametre
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents(date.year, date.month, date.day),
      params,
    );

    return PrayerTimesModel.fromAdhanDart(
      cityId: cityId,
      date: date,
      imsak: prayerTimes.fajr.subtract(const Duration(minutes: 10)), // Approximate imsak
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      offsets: offsets,
    );
  }

  /// Belirli ay için tüm günleri hesapla (aylık takvim)
  Future<List<PrayerTimesModel>> getMonthlyPrayerTimes({
    required String cityId,
    required double lat,
    required double lon,
    required int year,
    required int month,
    required AppSettings settings,
  }) async {
    final isOnline = await _isOnline();
    final offsets = settings.prayerOffsets;

    if (isOnline) {
      try {
        return await _fetchMonthlyFromAlAdhan(
          cityId: cityId,
          lat: lat,
          lon: lon,
          year: year,
          month: month,
          settings: settings,
          offsets: offsets,
        );
      } catch (_) {}
    }

    // Offline: her gün için hesapla
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final date = DateTime(year, month, i + 1);
      return _calculateOffline(
        cityId: cityId, 
        lat: lat, 
        lon: lon, 
        date: date, 
        settings: settings,
        offsets: offsets,
      );
    });
  }

  Future<List<PrayerTimesModel>> _fetchMonthlyFromAlAdhan({
    required String cityId,
    required double lat,
    required double lon,
    required int year,
    required int month,
    required AppSettings settings,
    required List<int> offsets,
  }) async {
    final cityName = settings.calculationMethod == 'Turkey' ? cityId.split('_').last : null;
    final useCityName = settings.calculationMethod == 'Turkey' && cityName != null;

    final path = useCityName
        ? '/calendarByCity/$year/$month'
        : '/calendar/$year/$month';

    final queryParams = useCityName
        ? {
            'city': _getTurkishCityName(cityId),
            'country': 'Turkey',
            'method': 13,
          }
        : {
            'latitude': lat,
            'longitude': lon,
            'method': _aladhanMethodMap[settings.calculationMethod] ?? AppConstants.diyanetMethod,
            'school': settings.madhab == 'Hanafi' ? AppConstants.hanafiSchool : AppConstants.shafiSchool,
          };

    final response = await _dio.get(path, queryParameters: queryParams);

    if (response.statusCode == 200) {
      final dataList = response.data['data'] as List;
      return dataList
          .map((d) => PrayerTimesModel.fromAlAdhanJson(
                cityId: cityId,
                json: d as Map<String, dynamic>,
                calculationMethod: settings.calculationMethod == 'Turkey' 
                    ? 'Diyanet İşleri Başkanlığı' 
                    : settings.calculationMethod,
                offsets: offsets,
              ))
          .toList();
    }
    throw Exception('AlAdhan calendar API error');
  }

  /// Kıble yönünü hesapla (azimuth — Kuzey'den saat yönünde derece)
  ///
  /// Formül (Büyük Daire Yolu / Great Circle):
  ///   ΔLon = lon_kaabe - lon_kullanici  (radyan)
  ///   qibla = atan2(sin(ΔLon)×cos(lat_kaabe),
  ///                 cos(lat_kull)×sin(lat_kaabe) - sin(lat_kull)×cos(lat_kaabe)×cos(ΔLon))
  ///   → 0-360° normalize
  ///
  double calculateQiblaDirection(double userLat, double userLon) {
    final kaabeLat = AppConstants.kaabeLat * math.pi / 180;
    final kaabeLon = AppConstants.kaabeLon * math.pi / 180;
    final lat = userLat * math.pi / 180;
    final lon = userLon * math.pi / 180;

    final deltaLon = kaabeLon - lon;

    final y = math.sin(deltaLon) * math.cos(kaabeLat);
    final x = math.cos(lat) * math.sin(kaabeLat) -
        math.sin(lat) * math.cos(kaabeLat) * math.cos(deltaLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  /// Kabe'ye olan mesafe (Haversine formülü - km)
  double calculateDistanceToKaaba(double userLat, double userLon) {
    const earthRadius = 6371.0;
    final lat1 = userLat * math.pi / 180;
    final lon1 = userLon * math.pi / 180;
    final lat2 = AppConstants.kaabeLat * math.pi / 180;
    final lon2 = AppConstants.kaabeLon * math.pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Hicri tarihi hesapla (AlAdhan API üzerinden)
  Future<String> getHijriDate(DateTime gregorianDate) async {
    try {
      final response = await _dio.get(
        '/gToH/${gregorianDate.day}-${gregorianDate.month}-${gregorianDate.year}',
      );
      if (response.statusCode == 200) {
        final hijri = response.data['data']['hijri'] as Map<String, dynamic>;
        final month = hijri['month'] as Map<String, dynamic>;
        return '${hijri['day']} ${month['en']} ${hijri['year']} H';
      }
    } catch (_) {}
    return '';
  }

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  CalculationParameters _getOfflineParams(AppSettings settings) {
    CalculationParameters base;
    switch (settings.calculationMethod) {
      case 'MWL':
        base = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'ISNA':
        base = CalculationMethod.north_america.getParameters();
        break;
      case 'Egypt':
        base = CalculationMethod.egyptian.getParameters();
        break;
      case 'Makkah':
        base = CalculationMethod.umm_al_qura.getParameters();
        break;
      default: // Turkey (Diyanet)
        base = CalculationMethod.karachi.getParameters();
        base.fajrAngle = 18.0;
        base.ishaAngle = 17.0;
        break;
    }
    switch (settings.highLatitudes) {
      case 'NightMiddle':
        base.highLatitudeRule = HighLatitudeRule.middle_of_the_night;
        break;
      case 'AngleBased':
        base.highLatitudeRule = HighLatitudeRule.seventh_of_the_night; // fallback for angle_based
        break;
      case 'OneSeventh':
        base.highLatitudeRule = HighLatitudeRule.seventh_of_the_night;
        break;
    }
    return base;
  }

  /// Map AlAdhan method ID to adhan CalculationParameters for offline fallback
  CalculationParameters _getOfflineParamsForMethod(int methodId) {
    switch (methodId) {
      case 1: // University of Islamic Sciences, Karachi
      case 13: // Turkey / Diyanet
        final p = CalculationMethod.karachi.getParameters();
        p.fajrAngle = 18.0;
        p.ishaAngle = 17.0;
        return p;
      case 2: // ISNA
        return CalculationMethod.north_america.getParameters();
      case 3: // MWL
        return CalculationMethod.muslim_world_league.getParameters();
      case 4: // Umm Al-Qura / Makkah
        return CalculationMethod.umm_al_qura.getParameters();
      case 5: // Egyptian
        return CalculationMethod.egyptian.getParameters();
      case 7: // Iran / IGUT
        final p = CalculationMethod.karachi.getParameters();
        p.fajrAngle = 17.7;
        p.ishaAngle = 14.0;
        return p;
      case 8: // Gulf / Kuwait
        return CalculationMethod.umm_al_qura.getParameters();
      case 9: // Kuwait
        final p = CalculationMethod.muslim_world_league.getParameters();
        p.fajrAngle = 18.0;
        p.ishaAngle = 17.5;
        return p;
      case 10: // Qatar
        return CalculationMethod.umm_al_qura.getParameters();
      case 11: // Singapore
      case 17: // Malaysia JAKIM
        final p = CalculationMethod.karachi.getParameters();
        p.fajrAngle = 20.0;
        p.ishaAngle = 18.0;
        return p;
      case 12: // Union des Organisations Islamiques de France
        final p = CalculationMethod.muslim_world_league.getParameters();
        p.fajrAngle = 12.0;
        p.ishaAngle = 12.0;
        return p;
      case 14: // Russia
        return CalculationMethod.muslim_world_league.getParameters();
      case 15: // UIOF (UK & Ireland)
        final p = CalculationMethod.muslim_world_league.getParameters();
        p.fajrAngle = 12.0;
        p.ishaAngle = 12.0;
        return p;
      case 16: // UAE / Dubai
        final p = CalculationMethod.umm_al_qura.getParameters();
        p.fajrAngle = 18.2;
        return p;
      case 18: // Tunisia
        return CalculationMethod.egyptian.getParameters();
      case 19: // Algeria
        return CalculationMethod.muslim_world_league.getParameters();
      case 20: // Indonesia (KEMENAG)
        final p = CalculationMethod.karachi.getParameters();
        p.fajrAngle = 20.0;
        p.ishaAngle = 18.0;
        return p;
      case 21: // Morocco
        final p = CalculationMethod.muslim_world_league.getParameters();
        p.fajrAngle = 18.0;
        return p;
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  static const _aladhanMethodMap = {
    'Turkey': 13,
    'MWL': 3,
    'ISNA': 2,
    'Egypt': 5,
    'Makkah': 4,
    'Karachi': 1,
    'Tehran': 7,
    'Gulf': 8,
    'Kuwait': 9,
    'Qatar': 10,
    'Singapore': 11,
    'France': 12,
    'Russia': 14,
    'JAKIM': 17,
    'Morocco': 21,
    'Indonesia': 20,
  };

  /// "HH:mm" formatındaki zamanı DateTime'a çevir
  DateTime _parseTime(String timeStr, DateTime baseDate) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}
