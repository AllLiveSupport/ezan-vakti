// lib/core/network/mosque_service.dart
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../services/mosque_cache_service.dart';

class MosqueModel {
  final String osmId;
  final String name;
  final String address;
  final double lat;
  final double lon;
  double distanceMeters;

  MosqueModel({
    required this.osmId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    this.distanceMeters = 0,
  });

  /// Tahmini yürüyüş süresi (dakika) — 80m/dk ortalama
  int get etaMinutes => (distanceMeters / 80).ceil();

  String get distanceFormatted {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toInt()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}

/// Overpass API ile yakın cami bulma servisi
class MosqueService {
  final Dio _dio;
  final MosqueCacheService _cache;

  MosqueService({Dio? dio, MosqueCacheService? cache})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 35),
            )),
        _cache = cache ?? MosqueCacheService();

  /// Kullanıcı konumuna yakın camileri çek (online + offline destekli)
  ///
  /// Overpass QL sorgusu:
  ///   [amenity=place_of_worship][religion=muslim] VEYA [building=mosque] radius km içinde
  ///   out center tags: way/relation için merkez koordinat döner
  Future<List<MosqueModel>> getNearbyMosques({
    required double lat,
    required double lon,
    double radiusMeters = AppConstants.mosqueSearchRadiusMeters,
    bool useCache = true,
  }) async {
    try {
      // Önce online dene
      final query = '''
[out:json][timeout:30];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  node["building"="mosque"](around:$radiusMeters,$lat,$lon);
  way["building"="mosque"](around:$radiusMeters,$lat,$lon);
);
out center tags;
''';

      final response = await _dio.post(
        AppConstants.overpassUrl,
        data: {'data': query},
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      final elements = response.data['elements'] as List?;
      if (elements == null || elements.isEmpty) {
        // Online boş döndü, cache dene
        if (useCache) {
          return await _cache.getCachedNearbyMosques(lat: lat, lon: lon);
        }
        return [];
      }

      final mosques = <MosqueModel>[];

      for (final element in elements) {
        final tags = element['tags'] as Map<String, dynamic>?;
        if (tags == null) continue;

        // Koordinatlar (node için direkt, way/relation için center)
        double? elLat;
        double? elLon;

        if (element['type'] == 'node') {
          elLat = (element['lat'] as num?)?.toDouble();
          elLon = (element['lon'] as num?)?.toDouble();
        } else if (element['center'] != null) {
          elLat = (element['center']['lat'] as num?)?.toDouble();
          elLon = (element['center']['lon'] as num?)?.toDouble();
        }

        if (elLat == null || elLon == null) continue;

        // İsim (Türkçe öncelikli, sonra genel)
        final name = tags['name:tr'] as String? ??
            tags['name'] as String? ??
            'Cami / Mescit';

        // Adres oluştur
        final addrStr = _buildAddress(tags);

        // Mesafeyi hesapla
        final distance = _haversineMeters(lat, lon, elLat, elLon);

        mosques.add(MosqueModel(
          osmId: '${element['type']}_${element['id']}',
          name: name,
          address: addrStr,
          lat: elLat,
          lon: elLon,
          distanceMeters: distance,
        ));
      }

      // Mesafeye göre sırala, aynı OSM id'yi birden fazla tagden gelirse tekilleştir
      final seen = <String>{};
      final unique = mosques.where((m) => seen.add(m.osmId)).toList();
      unique.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      
      // Cache'e kaydet
      if (unique.isNotEmpty && useCache) {
        await _cache.cacheMosques(
          mosques: unique,
          searchLat: lat,
          searchLon: lon,
        );
      }
      
      return unique;
    } catch (e) {
      // Online başarısız, cache dene
      if (useCache) {
        debugPrint('⚠️ Online cami arama başarısız, cache kullanılıyor: $e');
        return await _cache.getCachedNearbyMosques(lat: lat, lon: lon);
      }
      return [];
    }
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) parts.add(tags['addr:street'] as String);
    if (tags['addr:housenumber'] != null) parts.add('No: ${tags['addr:housenumber']}');
    if (tags['addr:district'] != null) parts.add(tags['addr:district'] as String);
    if (tags['addr:city'] != null) parts.add(tags['addr:city'] as String);
    
    return parts.isEmpty ? 'Bilgi Yok' : parts.join(', ');
  }

  /// Haversine formülü — metre cinsinden mesafe
  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Dünya yarıçapı
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }
}
