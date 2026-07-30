import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../network/mosque_service.dart';

/// Offline cami cache servisi
class MosqueCacheService {
  static Database? _db;
  static const String _tableName = 'cached_mosques';
  static const int _maxCacheAgeDays = 30; // 30 gün eski cache temizlenir
  
  /// Database başlat
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mosques_cache.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            osm_id TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            address TEXT,
            lat REAL NOT NULL,
            lon REAL NOT NULL,
            cached_at INTEGER NOT NULL,
            search_lat REAL NOT NULL,
            search_lon REAL NOT NULL
          )
        ''');
        
        // Spatial index için (basit bounding box arama)
        await db.execute('''
          CREATE INDEX idx_location ON $_tableName(search_lat, search_lon)
        ''');
        await _seedDefaultMosques(db);
      },
    );
  }

  Future<void> _seedDefaultMosques(Database db) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/turkey_mosques.json');
      final list = json.decode(jsonString) as List;
      final now = DateTime.now().millisecondsSinceEpoch;

      final batch = db.batch();
      for (final item in list) {
        if (item is Map) {
          final itemLat = (item['lat'] as num).toDouble();
          final itemLon = (item['lon'] as num).toDouble();
          batch.insert(
            _tableName,
            {
              'osm_id': item['osm_id'].toString(),
              'name': item['name'] as String? ?? 'Cami',
              'address': item['address'] as String? ?? '',
              'lat': itemLat,
              'lon': itemLon,
              'cached_at': now,
              'search_lat': (item['search_lat'] as num?)?.toDouble() ?? itemLat,
              'search_lon': (item['search_lon'] as num?)?.toDouble() ?? itemLon,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
      await batch.commit(noResult: true);
      debugPrint('🕌 Türkiye genelinden ${list.length} adet güncel cami SQLite veritabanına kaydedildi!');
    } catch (e) {
      debugPrint('⚠️ Offline cami verisi yükleme hatası: $e');
    }
  }
  
  /// Camileri cache'e kaydet
  Future<void> cacheMosques({
    required List<MosqueModel> mosques,
    required double searchLat,
    required double searchLon,
  }) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (final mosque in mosques) {
      batch.insert(
        _tableName,
        {
          'osm_id': mosque.osmId,
          'name': mosque.name,
          'address': mosque.address,
          'lat': mosque.lat,
          'lon': mosque.lon,
          'cached_at': now,
          'search_lat': searchLat,
          'search_lon': searchLon,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
    debugPrint('📥 ${mosques.length} cami cache\'e kaydedildi');
  }
  
  /// Yakındaki camileri cache'ten getir (Mesafe öncelikli & Sokak adı filtreli)
  Future<List<MosqueModel>> getCachedNearbyMosques({
    required double lat,
    required double lon,
    double maxDistanceKm = 15.0,
  }) async {
    final db = await database;
    
    // Eski cache'i temizle (30 günden eski)
    final cutoffDate = DateTime.now().subtract(Duration(days: _maxCacheAgeDays)).millisecondsSinceEpoch;
    await db.delete(
      _tableName,
      where: 'cached_at < ?',
      whereArgs: [cutoffDate],
    );
    
    // 1 derece yaklaşık 111 km
    final latDelta = maxDistanceKm / 111.0;
    final lonDelta = maxDistanceKm / (111.0 * math.cos(lat * math.pi / 180));
    
    final results = await db.query(
      _tableName,
      where: 'lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?',
      whereArgs: [
        lat - latDelta,
        lat + latDelta,
        lon - lonDelta,
        lon + lonDelta,
      ],
    );
    
    final mosques = <MosqueModel>[];
    for (final row in results) {
      final name = row['name'] as String? ?? 'Cami';
      // Cadde/sokak/numara gibi görünen isimleri filtrele
      if (_isStreetLikeName(name)) continue;

      final mosque = MosqueModel(
        osmId: row['osm_id'] as String,
        name: name,
        address: row['address'] as String? ?? '',
        lat: row['lat'] as double,
        lon: row['lon'] as double,
      );
      
      mosque.distanceMeters = _haversineMeters(lat, lon, mosque.lat, mosque.lon);
      if (mosque.distanceMeters <= maxDistanceKm * 1000) {
        mosques.add(mosque);
      }
    }
    
    // Mesafeye göre A'dan Z'ye EN YAKINDAN EN UZAĞA sırala
    mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    
    final closestMosques = mosques.take(40).toList();

    // Üst üste binen (çakışan) koordinatları ayrıştır (De-stacking Golden Spiral)
    final coordGroups = <String, List<MosqueModel>>{};
    for (final m in closestMosques) {
      final key = '${m.lat.toStringAsFixed(4)}_${m.lon.toStringAsFixed(4)}';
      coordGroups.putIfAbsent(key, () => []).add(m);
    }

    final unstackedList = <MosqueModel>[];
    coordGroups.forEach((key, group) {
      if (group.length == 1) {
        unstackedList.add(group.first);
      } else {
        // Çakışan camileri spiral şeklinde doğal olarak çevre mahalleye dağıt
        for (int i = 0; i < group.length; i++) {
          final m = group[i];
          if (i == 0) {
            unstackedList.add(m);
          } else {
            final radiusMeters = (i * 140.0) + 100.0; // 100m, 240m, 380m...
            final angleRad = i * 2.399963229728653; // Altın açı ~137.5°
            final latOffset = (radiusMeters * math.cos(angleRad)) / 111000.0;
            final lonOffset = (radiusMeters * math.sin(angleRad)) / (111000.0 * math.cos(m.lat * math.pi / 180));
            
            final newLat = m.lat + latOffset;
            final newLon = m.lon + lonOffset;
            final newDist = _haversineMeters(lat, lon, newLat, newLon);

            unstackedList.add(MosqueModel(
              osmId: '${m.osmId}_$i',
              name: m.name,
              address: m.address,
              lat: newLat,
              lon: newLon,
              distanceMeters: newDist,
            ));
          }
        }
      }
    });

    unstackedList.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    debugPrint('📤 Cache\'ten ${unstackedList.length} en yakın cami ayrıştırılarak getirildi (Mesafe: ${unstackedList.isNotEmpty ? unstackedList.first.distanceFormatted : "0m"})');
    return unstackedList;
  }

  bool _isStreetLikeName(String name) {
    final lower = name.toLowerCase();
    if (RegExp(r'^[\d\s\-\.]+$').hasMatch(name)) return true;
    final hasStreet = lower.contains('cadde') || lower.contains('sokak') ||
        lower.contains('bulvar') || lower.contains('nolu cad') ||
        lower.contains(' sk') || lower.contains(' cd');
    final hasMosque = lower.contains('cami') || lower.contains('mescit') || lower.contains('camii') || lower.contains('mosque');
    return hasStreet && !hasMosque;
  }
  
  /// Cache'te cami var mı kontrol et
  Future<bool> hasCachedMosques({
    required double lat,
    required double lon,
    double maxDistanceKm = 50.0,
  }) async {
    final mosques = await getCachedNearbyMosques(
      lat: lat,
      lon: lon,
      maxDistanceKm: maxDistanceKm,
    );
    return mosques.isNotEmpty;
  }
  
  /// Tüm cache'i temizle
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableName);
    debugPrint('🗑️ Cami cache\'i temizlendi');
  }
  
  /// Cache boyutunu getir
  Future<int> getCacheSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return (result.first['count'] as int?) ?? 0;
  }
  
  /// Haversine formülü ile mesafe hesaplama (metre)
  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Dünya yarıçapı (metre)
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}
