import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Anahtarlar
const _kCalcMethod = 'calc_method';
const _kMadhab = 'madhab';
const _kHighLatitudes = 'high_latitudes';
const _kAdhanSound = 'adhan_sound';
const _kThemeMode = 'theme_mode';
const _kPrayerAdhan = 'prayer_adhan_'; // prefix
const _kPrayerNotif = 'prayer_notif_'; // prefix
const _kPrayerOffset = 'prayer_offset_'; // prefix

// ─── Tema Varyantı ──────────────────────────────────────────────────
enum AppThemeVariant {
  system,      // Sistem Teması
  greenLight,  // Green Light (mint yeşil arka plan)
  greenDark,   // Green Dark (koyu yeşil)
  whiteGreen,  // Beyaz Yeşil (nötr beyaz + yeşil aksanlar)
  pureDark;    // Dark (kömür koyu, yeşil aksanlar)

  String toPrefsString() {
    switch (this) {
      case AppThemeVariant.greenLight: return 'greenLight';
      case AppThemeVariant.greenDark: return 'greenDark';
      case AppThemeVariant.whiteGreen: return 'whiteGreen';
      case AppThemeVariant.pureDark: return 'pureDark';
      case AppThemeVariant.system: return 'system';
    }
  }

  static AppThemeVariant fromPrefsString(String s) {
    switch (s) {
      case 'greenLight':
      case 'light': return AppThemeVariant.greenLight;  // geriye uyumluluk
      case 'greenDark':
      case 'dark': return AppThemeVariant.greenDark;    // geriye uyumluluk
      case 'whiteGreen': return AppThemeVariant.whiteGreen;
      case 'pureDark': return AppThemeVariant.pureDark;
      default: return AppThemeVariant.system;
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeVariant.system: return ThemeMode.system;
      case AppThemeVariant.greenLight:
      case AppThemeVariant.whiteGreen: return ThemeMode.light;
      case AppThemeVariant.greenDark:
      case AppThemeVariant.pureDark: return ThemeMode.dark;
    }
  }
}

// ─── Modeller ─────────────────────────────────────────────────────────────
class AppSettings {
  final String calculationMethod; 
  final String madhab; 
  final String highLatitudes; 
  final String adhanSound; 
  final AppThemeVariant themeVariant; 

  // Yeni: Her vakit için ayarlar (0: İmsak, 1: Güneş, 2: Öğle, 3: İkindi, 4: Akşam, 5: Yatsı)
  final List<bool> prayerAdhanEnabled;
  final List<bool> prayerNotifEnabled;
  final List<int> prayerOffsets; // Dakika cinsinden (negatif = önce)

  const AppSettings({
    this.calculationMethod = 'Turkey',
    this.madhab = 'Shafii',
    this.highLatitudes = 'None',
    this.adhanSound = 'mekke',
    this.themeVariant = AppThemeVariant.system,
    this.prayerAdhanEnabled = const [true, true, true, true, true, true],
    this.prayerNotifEnabled = const [true, true, true, true, true, true],
    this.prayerOffsets = const [0, 0, 0, 0, 0, 0],
  });

  AppSettings copyWith({
    String? calculationMethod,
    String? madhab,
    String? highLatitudes,
    String? adhanSound,
    AppThemeVariant? themeVariant,
    List<bool>? prayerAdhanEnabled,
    List<bool>? prayerNotifEnabled,
    List<int>? prayerOffsets,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      highLatitudes: highLatitudes ?? this.highLatitudes,
      adhanSound: adhanSound ?? this.adhanSound,
      themeVariant: themeVariant ?? this.themeVariant,
      prayerAdhanEnabled: prayerAdhanEnabled ?? this.prayerAdhanEnabled,
      prayerNotifEnabled: prayerNotifEnabled ?? this.prayerNotifEnabled,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    
    final tModeStr = _prefs.getString(_kThemeMode) ?? 'system';
    final tVariant = AppThemeVariant.fromPrefsString(tModeStr);

    final adhanList = List.generate(6, (i) => _prefs.getBool('$_kPrayerAdhan$i') ?? true);
    final notifList = List.generate(6, (i) => _prefs.getBool('$_kPrayerNotif$i') ?? true);
    final offsetList = List.generate(6, (i) => _prefs.getInt('$_kPrayerOffset$i') ?? 0);

    return AppSettings(
      calculationMethod: _prefs.getString(_kCalcMethod) ?? 'Turkey',
      madhab: _prefs.getString(_kMadhab) ?? 'Shafii',
      highLatitudes: _prefs.getString(_kHighLatitudes) ?? 'None',
      adhanSound: _prefs.getString(_kAdhanSound) ?? 'mekke',
      themeVariant: tVariant,
      prayerAdhanEnabled: adhanList,
      prayerNotifEnabled: notifList,
      prayerOffsets: offsetList,
    );
  }

  Future<void> updateCalculationMethod(String value) async {
    await _prefs.setString(_kCalcMethod, value);
    state = AsyncData(state.value!.copyWith(calculationMethod: value));
  }

  Future<void> updateMadhab(String value) async {
    await _prefs.setString(_kMadhab, value);
    state = AsyncData(state.value!.copyWith(madhab: value));
  }

  Future<void> updateHighLatitudes(String value) async {
    await _prefs.setString(_kHighLatitudes, value);
    state = AsyncData(state.value!.copyWith(highLatitudes: value));
  }

  Future<void> updateAdhanSound(String value) async {
    await _prefs.setString(_kAdhanSound, value);
    state = AsyncData(state.value!.copyWith(adhanSound: value));
  }

  Future<void> updateThemeVariant(AppThemeVariant variant) async {
    await _prefs.setString(_kThemeMode, variant.toPrefsString());
    state = AsyncData(state.value!.copyWith(themeVariant: variant));
  }

  Future<void> updatePrayerAdhan(int index, bool enabled) async {
    final newList = List<bool>.from(state.value!.prayerAdhanEnabled);
    newList[index] = enabled;
    await _prefs.setBool('$_kPrayerAdhan$index', enabled);
    state = AsyncData(state.value!.copyWith(prayerAdhanEnabled: newList));
  }

  Future<void> updatePrayerNotif(int index, bool enabled) async {
    final newList = List<bool>.from(state.value!.prayerNotifEnabled);
    newList[index] = enabled;
    await _prefs.setBool('$_kPrayerNotif$index', enabled);
    state = AsyncData(state.value!.copyWith(prayerNotifEnabled: newList));
  }

  Future<void> updatePrayerOffset(int index, int minutes) async {
    final newList = List<int>.from(state.value!.prayerOffsets);
    newList[index] = minutes;
    await _prefs.setInt('$_kPrayerOffset$index', minutes);
    state = AsyncData(state.value!.copyWith(prayerOffsets: newList));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
