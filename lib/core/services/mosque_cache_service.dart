// lib/core/services/mosque_cache_service.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
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
        await db.execute('''
          CREATE INDEX idx_cached_at ON $_tableName(cached_at)
        ''');
      },
    );
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
  
  /// Yakındaki camileri cache'ten getir (max 50km)
  Future<List<MosqueModel>> getCachedNearbyMosques({
    required double lat,
    required double lon,
    double maxDistanceKm = 50.0,
  }) async {
    final db = await database;
    
    // Eski cache'i temizle (30 günden eski)
    final cutoffDate = DateTime.now().subtract(Duration(days: _maxCacheAgeDays)).millisecondsSinceEpoch;
    await db.delete(
      _tableName,
      where: 'cached_at < ?',
      whereArgs: [cutoffDate],
    );
    
    // Basit bounding box ile filtrele (rough approximation)
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
      orderBy: 'cached_at DESC',
      limit: 100, // Max 100 cami
    );
    
    final mosques = results.map((row) {
      final mosque = MosqueModel(
        osmId: row['osm_id'] as String,
        name: row['name'] as String,
        address: row['address'] as String? ?? '',
        lat: row['lat'] as double,
        lon: row['lon'] as double,
      );
      
      // Mesafeyi hesapla
      mosque.distanceMeters = _haversineMeters(lat, lon, mosque.lat, mosque.lon);
      return mosque;
    }).where((m) => m.distanceMeters <= maxDistanceKm * 1000).toList();
    
    // Mesafeye göre sırala
    mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    
    debugPrint('📤 Cache\'ten ${mosques.length} cami getirildi');
    return mosques;
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
