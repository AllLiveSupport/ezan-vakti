import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../core/services/vibration_service.dart';
import '../../core/services/sound_service.dart';
import '../../core/database/app_database.dart';

const _kTasbihCount = 'tasbih_count';
const _kTasbihTotal = 'tasbih_total';
const _kTasbihTarget = 'tasbih_target';
const _kTasbihName = 'tasbih_name';
const _kVibrationEnabled = 'vibration_enabled';
const _kSoundEnabled = 'sound_enabled';

class TasbihState {
  final int count;
  final int totalCount;
  final int target;
  final String zikrName;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final int completed33;
  final int completed99;
  final int completed100;

  const TasbihState({
    this.count = 0,
    this.totalCount = 0,
    this.target = 33,
    this.zikrName = 'SubhanAllah',
    this.vibrationEnabled = true,
    this.soundEnabled = true,
    this.completed33 = 0,
    this.completed99 = 0,
    this.completed100 = 0,
  });

  TasbihState copyWith({
    int? count,
    int? totalCount,
    int? target,
    String? zikrName,
    bool? vibrationEnabled,
    bool? soundEnabled,
    int? completed33,
    int? completed99,
    int? completed100,
  }) {
    return TasbihState(
      count: count ?? this.count,
      totalCount: totalCount ?? this.totalCount,
      target: target ?? this.target,
      zikrName: zikrName ?? this.zikrName,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      completed33: completed33 ?? this.completed33,
      completed99: completed99 ?? this.completed99,
      completed100: completed100 ?? this.completed100,
    );
  }
}

class TasbihNotifier extends AsyncNotifier<TasbihState> {
  late SharedPreferences _prefs;
  late AppDatabase _db;

  @override
  Future<TasbihState> build() async {
    _prefs = await SharedPreferences.getInstance();
    _db = AppDatabase();
    
    // Initialize services
    await VibrationService.init();
    await SoundService.init();
    
    final soundEnabled = _prefs.getBool(_kSoundEnabled) ?? true;
    await SoundService.setEnabled(soundEnabled);
    
    return TasbihState(
      count: _prefs.getInt(_kTasbihCount) ?? 0,
      totalCount: _prefs.getInt(_kTasbihTotal) ?? 0,
      target: _prefs.getInt(_kTasbihTarget) ?? 33,
      zikrName: _prefs.getString(_kTasbihName) ?? 'SubhanAllah',
      vibrationEnabled: _prefs.getBool(_kVibrationEnabled) ?? true,
      soundEnabled: soundEnabled,
      completed33: _prefs.getInt('completed_33') ?? 0,
      completed99: _prefs.getInt('completed_99') ?? 0,
      completed100: _prefs.getInt('completed_100') ?? 0,
    );
  }

  Future<void> increment() async {
    final current = state.value!;
    int newCount = current.count + 1;
    int newTotal = current.totalCount + 1;

    bool targetReached = false;
    if (newCount > current.target) {
      // Overflow = sadece reset, tamamlama önceki turda (==target) zaten sayıldı
      newCount = 1;
    } else if (newCount == current.target) {
      targetReached = true;
    }

    await _prefs.setInt(_kTasbihCount, newCount);
    await _prefs.setInt(_kTasbihTotal, newTotal);

    state = AsyncData(current.copyWith(count: newCount, totalCount: newTotal));

    // Tamamlanma sayaçlarını güncelle — sadece hedef sayısına eşit olduğunda
    int completed33 = current.completed33;
    int completed99 = current.completed99;
    int completed100 = current.completed100;

    if (targetReached) {
      if (current.target == 33) completed33++;
      if (current.target == 99) completed99++;
      if (current.target == 100) completed100++;

      await _prefs.setInt('completed_33', completed33);
      await _prefs.setInt('completed_99', completed99);
      await _prefs.setInt('completed_100', completed100);

      state = AsyncData(current.copyWith(
        count: newCount,
        totalCount: newTotal,
        completed33: completed33,
        completed99: completed99,
        completed100: completed100,
      ));

      // Ses sadece hedef sayısına ulaşıldığında
      if (current.soundEnabled) {
        await SoundService.playForCount(current.target);
      }
    }
    
    // Titreşim her tıklamada (eğer açıksa) - hafif hissedilecek miktarda
    if (current.vibrationEnabled) {
      await HapticFeedback.lightImpact();
    }

    // Zikir geçmişi kaydet (her zikirde arttır, hedefte tamamla)
    await _saveZikrHistory(newCount, targetReached);
  }

  /// Zikir geçmişini database'e kaydet - her zikirde sadece +1 ekle
  Future<void> _saveZikrHistory(int count, bool completed) async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Günlük istatistikleri güncelle
      final todayData = await _db.getTodayTasbih(date);
      final zikrName = state.value?.zikrName ?? 'SubhanAllah';
      
      int subhanallah = todayData?.subhanallah ?? 0;
      int alhamdulillah = todayData?.alhamdulillah ?? 0;
      int allahuakbar = todayData?.allahuakbar ?? 0;
      int cycles = todayData?.totalCycles ?? 0;

      // Her zikirde sadece +1 ekle - basit ve güvenilir
      if (zikrName.toLowerCase().contains('subhan')) {
        subhanallah += 1;
      } else if (zikrName.toLowerCase().contains('hamd') || zikrName.toLowerCase().contains('elhamd')) {
        alhamdulillah += 1;
      } else if (zikrName.toLowerCase().contains('akbar') || zikrName.toLowerCase().contains('ekber')) {
        allahuakbar += 1;
      } else {
        // Bilinmeyen zikir ismi - varsayılan olarak Subhanallah say
        subhanallah += 1;
      }

      // Hedef tamamlandıysa tur sayısını artır
      if (completed) cycles += 1;

      await _db.upsertTasbih(TasbihSessionsTableCompanion(
        date: drift.Value(date),
        subhanallah: drift.Value(subhanallah),
        alhamdulillah: drift.Value(alhamdulillah),
        allahuakbar: drift.Value(allahuakbar),
        totalCycles: drift.Value(cycles),
      ));
    } catch (e) {
      debugPrint('Zikir geçmişi kaydetme hatası: $e');
    }
  }

  Future<void> resetCount() async {
    await _prefs.setInt(_kTasbihCount, 0);
    state = AsyncData(state.value!.copyWith(count: 0));
  }

  Future<void> updateZikr(String name, int target) async {
    await _prefs.setString(_kTasbihName, name);
    await _prefs.setInt(_kTasbihTarget, target);
    state = AsyncData(state.value!.copyWith(zikrName: name, target: target, count: 0));
  }

  /// Titreşim ayarını değiştir
  Future<void> toggleVibration() async {
    final current = state.value!;
    final newValue = !current.vibrationEnabled;
    await _prefs.setBool(_kVibrationEnabled, newValue);
    state = AsyncData(current.copyWith(vibrationEnabled: newValue));
  }

  /// Ses ayarını değiştir
  Future<void> toggleSound() async {
    final current = state.value!;
    final newValue = !current.soundEnabled;
    await _prefs.setBool(_kSoundEnabled, newValue);
    await SoundService.setEnabled(newValue);
    state = AsyncData(current.copyWith(soundEnabled: newValue));
  }

  /// Günlük zikir istatistiklerini getir
  Future<TasbihStats> getDailyStats(String date) async {
    final data = await _db.getTodayTasbih(date);
    return TasbihStats(
      date: date,
      subhanallah: data?.subhanallah ?? 0,
      alhamdulillah: data?.alhamdulillah ?? 0,
      allahuakbar: data?.allahuakbar ?? 0,
      totalCycles: data?.totalCycles ?? 0,
      totalCount: (data?.subhanallah ?? 0) + (data?.alhamdulillah ?? 0) + (data?.allahuakbar ?? 0),
    );
  }

  /// Haftalık zikir istatistiklerini getir
  Future<List<TasbihStats>> getWeeklyStats() async {
    final List<TasbihStats> stats = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = DateFormat('yyyy-MM-dd').format(
        now.subtract(Duration(days: i)),
      );
      final dailyStats = await getDailyStats(date);
      stats.add(dailyStats);
    }
    return stats;
  }
}

/// Zikir istatistik modeli
class TasbihStats {
  final String date;
  final int subhanallah;
  final int alhamdulillah;
  final int allahuakbar;
  final int totalCycles;
  final int totalCount;

  const TasbihStats({
    required this.date,
    this.subhanallah = 0,
    this.alhamdulillah = 0,
    this.allahuakbar = 0,
    this.totalCycles = 0,
    this.totalCount = 0,
  });

  String get formattedDate {
    final dt = DateTime.parse(date);
    return DateFormat('d MMMM', 'tr_TR').format(dt);
  }

  String get dayName {
    final dt = DateTime.parse(date);
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return weekdays[dt.weekday - 1];
  }
}

final tasbihProvider = AsyncNotifierProvider<TasbihNotifier, TasbihState>(TasbihNotifier.new);

/// Zikir istatistikleri provider'ı
final tasbihStatsProvider = FutureProvider.family<TasbihStats, String>((ref, date) async {
  final notifier = ref.read(tasbihProvider.notifier);
  return await notifier.getDailyStats(date);
});

/// Haftalık zikir istatistikleri provider'ı
final weeklyTasbihStatsProvider = FutureProvider<List<TasbihStats>>((ref) async {
  final notifier = ref.read(tasbihProvider.notifier);
  return await notifier.getWeeklyStats();
});
