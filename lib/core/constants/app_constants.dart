// lib/core/constants/app_constants.dart
class AppConstants {
  // Uygulama Bilgileri
  static const String appName = 'Ezan Vakti';
  static const String appTagline = 'Your Digital Sanctuary';
  static const String appVersion = '1.0.0';

  // Kabe Koordinatları (Mekke)
  static const double kaabeLat = 21.4225;
  static const double kaabeLon = 39.8262;

  // AlAdhan API
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  // Method 13 = Diyanet İşleri Başkanlığı (Turkey)
  static const int diyanetMethod = 13;
  // School 1 = Hanafi (Asr: shadow = 2x)
  static const int hanafiSchool = 1;
  static const int shafiSchool = 0;

  // Overpass API (Cami Bulucu)
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String overpassMirrorUrl =
      'https://overpass.kumi.systems/api/interpreter';
  static const double mosqueSearchRadiusMeters = 5000;

  // Quran API (Günlük Ayet - CDN tabanlı, sınırsız)
  static const String quranApiBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';

  // SharedPreferences Keys
  static const String keySelectedCityId = 'selected_city_id';
  static const String keySelectedCityName = 'selected_city_name';
  static const String keyCityLat = 'city_lat';
  static const String keyCityLon = 'city_lon';
  static const String keyCityTimezone = 'city_timezone';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keySelectedCountryCode = 'selected_country_code';
  static const String keySelectedCountryName = 'selected_country_name';
  static const String keyCityMethod = 'city_method';
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyMadhab = 'madhab';
  static const String keyThemeMode = 'theme_mode';
  static const String keyHijriOffset = 'hijri_offset';
  static const String keyLastHijriDate = 'last_hijri_date';

  // Prayer Names (Türkçe)
  static const List<String> prayerNamesTR = [
    'İmsak',
    'Güneş',
    'Öğle',
    'İkindi',
    'Akşam',
    'Yatsı',
  ];

  // Icon assets for each prayer
  static const List<String> prayerIcons = [
    'assets/icons/fajr.svg',
    'assets/icons/sunrise.svg',
    'assets/icons/dhuhr.svg',
    'assets/icons/asr.svg',
    'assets/icons/maghrib.svg',
    'assets/icons/isha.svg',
  ];

  // Prayer sound keys
  static const String soundKeyFajr = 'fajr_sound';
  static const String soundKeyDhuhr = 'dhuhr_sound';
  static const String soundKeyAsr = 'asr_sound';
  static const String soundKeyMaghrib = 'maghrib_sound';
  static const String soundKeyIsha = 'isha_sound';

  // Cache durations
  static const int prayerCacheDays = 30;
  static const int mosqueCacheHours = 168; // 7 gün
  static const int hijriCacheHours = 24;

  // Tasbih defaults
  static const int tasbihTarget = 33;
  static const int tasbihCycleTarget = 99;

  // Alarm notification channel
  static const String alarmChannelId = 'ezan_vakti_alarms';
  static const String alarmChannelName = 'Ezan Vakti Alarmları';
  static const String widgetChannelId = 'ezan_vakti_widget';
}
