// lib/core/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ─── Tablolar ──────────────────────────────────────────────────────────────

/// Namaz vakitleri önbelleği (30 günlük)
class PrayerTimesTable extends Table {
  @override
  String get tableName => 'prayer_times';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get cityId => text().withLength(max: 20)();
  TextColumn get date => text()(); // 'YYYY-MM-DD'
  TextColumn get fajr => text()();
  TextColumn get sunrise => text()();
  TextColumn get dhuhr => text()();
  TextColumn get asr => text()();
  TextColumn get maghrib => text()();
  TextColumn get isha => text()();
  TextColumn get hijriDate => text().withDefault(const Constant(''))();
  TextColumn get calculationMethod => text().withDefault(const Constant('Turkey'))();
  IntColumn get fetchedAt => integer()(); // Unix timestamp

  @override
  List<Set<Column>> get uniqueKeys => [
        {cityId, date}
      ];
}

/// Kayıtlı şehirler
class SavedLocationsTable extends Table {
  @override
  String get tableName => 'saved_locations';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get cityId => text().unique()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get timezone => text()();
  TextColumn get region => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
}

/// Tesbih sayaçları (günlük)
class TasbihSessionsTable extends Table {
  @override
  String get tableName => 'tasbih_sessions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // 'YYYY-MM-DD'
  IntColumn get subhanallah => integer().withDefault(const Constant(0))();
  IntColumn get alhamdulillah => integer().withDefault(const Constant(0))();
  IntColumn get allahuakbar => integer().withDefault(const Constant(0))();
  IntColumn get totalCycles => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date}
      ];
}

/// Cami önbelleği (Overpass API - 7 günlük)
class MosqueCacheTable extends Table {
  @override
  String get tableName => 'mosque_cache';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get osmId => text().unique()();
  TextColumn get name => text()();
  TextColumn get address => text().withDefault(const Constant(''))();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get lastUpdated => integer()();
}

/// Aylık namaz takvimi önbelleği
class MonthlyCalendarTable extends Table {
  @override
  String get tableName => 'monthly_calendar';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get cityId => text()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  TextColumn get jsonData => text()(); // Ham JSON string
  IntColumn get fetchedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {cityId, year, month}
      ];
}

// ─── Veritabanı ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  PrayerTimesTable,
  SavedLocationsTable,
  TasbihSessionsTable,
  MosqueCacheTable,
  MonthlyCalendarTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  // ─── Prayer Times DAO ───────────────────────────────────────────────────

  Future<PrayerTimesTableData?> getPrayerTimes(
      String cityId, String date) async {
    return (select(prayerTimesTable)
          ..where((t) => t.cityId.equals(cityId) & t.date.equals(date)))
        .getSingleOrNull();
  }

  Future<void> savePrayerTimes(PrayerTimesTableCompanion entry) async {
    await into(prayerTimesTable).insertOnConflictUpdate(entry);
  }

  Future<void> cleanOldPrayerTimes(int keepDays) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: keepDays))
        .millisecondsSinceEpoch ~/
        1000;
    await (delete(prayerTimesTable)
          ..where((t) => t.fetchedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  // ─── Locations DAO ──────────────────────────────────────────────────────

  Future<List<SavedLocationsTableData>> getSavedLocations() {
    return select(savedLocationsTable).get();
  }

  Future<SavedLocationsTableData?> getActiveLocation() {
    return (select(savedLocationsTable)
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();
  }

  Future<void> saveLocation(SavedLocationsTableCompanion entry) async {
    await into(savedLocationsTable).insertOnConflictUpdate(entry);
  }

  Future<void> setActiveLocation(String cityId) async {
    // Önce tümünü pasif yap
    await (update(savedLocationsTable))
        .write(const SavedLocationsTableCompanion(
      isActive: Value(false),
    ));
    // Seçileni aktif yap
    await (update(savedLocationsTable)
          ..where((t) => t.cityId.equals(cityId)))
        .write(const SavedLocationsTableCompanion(isActive: Value(true)));
  }

  // ─── Tasbih DAO ─────────────────────────────────────────────────────────

  Future<TasbihSessionsTableData?> getTodayTasbih(String date) {
    return (select(tasbihSessionsTable)
          ..where((t) => t.date.equals(date)))
        .getSingleOrNull();
  }

  Future<void> upsertTasbih(TasbihSessionsTableCompanion entry) async {
    // Date varsa güncelle, yoksa ekle
    final existing = await getTodayTasbih(entry.date.value);
    if (existing != null) {
      // Güncelle
      await (update(tasbihSessionsTable)
            ..where((t) => t.date.equals(entry.date.value)))
          .write(TasbihSessionsTableCompanion(
        subhanallah: entry.subhanallah,
        alhamdulillah: entry.alhamdulillah,
        allahuakbar: entry.allahuakbar,
        totalCycles: entry.totalCycles,
      ));
    } else {
      // Yeni ekle
      await into(tasbihSessionsTable).insert(entry);
    }
  }

  // ─── Mosque Cache DAO ───────────────────────────────────────────────────

  Future<List<MosqueCacheTableData>> getCachedMosques() {
    return select(mosqueCacheTable).get();
  }

  Future<void> saveMosques(List<MosqueCacheTableCompanion> mosques) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(mosqueCacheTable, mosques);
    });
  }

  Future<void> clearOldMosques(int olderThanHours) async {
    final cutoff = DateTime.now()
            .subtract(Duration(hours: olderThanHours))
            .millisecondsSinceEpoch ~/
        1000;
    await (delete(mosqueCacheTable)
          ..where((t) => t.lastUpdated.isSmallerThanValue(cutoff)))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ezan_vakti.db'));
    return NativeDatabase.createInBackground(file);
  });
}
