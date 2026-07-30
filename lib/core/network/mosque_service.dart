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

  /// Kullanıcı konumuna yakın camileri çek (online + mirror + offline destekli)
  Future<List<MosqueModel>> getNearbyMosques({
    required double lat,
    required double lon,
    double radiusMeters = AppConstants.mosqueSearchRadiusMeters,
    bool useCache = true,
    bool useLocalOnly = false,
  }) async {
    final radiusKm = radiusMeters / 1000.0;

    // LOCAL ONLY mod: direkt cache/SQLite'a git
    if (useLocalOnly) {
      debugPrint('📦 Local mod: Yerel veritabanından cami çekiliyor ($radiusKm km)...');
      return await _cache.getCachedNearbyMosques(lat: lat, lon: lon, maxDistanceKm: radiusKm);
    }

    // 1. Önce hızlı ve tam isim veren Nominatim API dene (OpenStreetMap resmi arama API'si)
    debugPrint('📍 Nominatim API ile camiler aranıyor...');
    var result = await _fetchFromNominatim(lat: lat, lon: lon);

    // 2. Nominatim boş dönerse Photon Komoot API dene
    if (result.isEmpty) {
      debugPrint('📍 Photon API deneniyor...');
      result = await _fetchFromPhoton(lat: lat, lon: lon);
    }

    // 3. Photon da boş dönerse Overpass API dene
    if (result.isEmpty) {
      debugPrint('📍 Overpass API deneniyor...');
      result = await _fetchFromOverpassEndpoints(lat: lat, lon: lon, radiusMeters: radiusMeters);
    }

    // 4. Sonuç geldiyse cache'e kaydet ve dön
    if (result.isNotEmpty) {
      if (useCache) {
        await _cache.cacheMosques(
          mosques: result,
          searchLat: lat,
          searchLon: lon,
        );
      }
      return result;
    }

    // 5. Online aramaların hepsi başarısızsa yerel SQLite veritabanını kullan
    if (useCache) {
      debugPrint('⚠️ Online cami aramaları yanıt vermedi, yerel veritabanı kullanılıyor...');
      return await _cache.getCachedNearbyMosques(lat: lat, lon: lon, maxDistanceKm: radiusKm);
    }

    return [];
  }

  /// Photon Komoot API ile açık kaynak hızlı cami arama (Komoot / OSM altyapısı)
  Future<List<MosqueModel>> _fetchFromPhoton({
    required double lat,
    required double lon,
  }) async {
    try {
      final url = 'https://photon.komoot.io/api/?q=cami&lat=$lat&lon=$lon&zoom=14&limit=50';
      final response = await _dio.get(
        url,
        options: Options(
          headers: {'User-Agent': 'EzanVaktiApp/1.0 (com.alllivesupport.ezanvakti)'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.data is Map && response.data['features'] is List) {
        final features = response.data['features'] as List;
        final mosques = <MosqueModel>[];

        for (final item in features) {
          if (item is Map && item['geometry'] is Map && item['properties'] is Map) {
            final props = item['properties'] as Map;
            final geom = item['geometry'] as Map;
            final coords = geom['coordinates'] as List?;
            if (coords != null && coords.length >= 2) {
              final itemLon = (coords[0] as num).toDouble();
              final itemLat = (coords[1] as num).toDouble();

              // Sadece gerçek cami/mescit sonuclarını al
              final osmtype = props['osm_type'] as String? ?? '';
              final type = props['type'] as String? ?? '';
              final subtype = props['osm_key'] as String? ?? '';
              final isMosque = osmtype == 'W' || osmtype == 'R' || osmtype == 'N' ||
                  type == 'place_of_worship' || subtype == 'amenity' || subtype == 'building';

              final rawName = props['name'] as String? ?? '';
              // Cami ismi yoksa veya cadde/sokak/no gibi görünüyorsa atla
              if (rawName.isEmpty || _isStreetLikeName(rawName)) continue;
              if (!isMosque && !_isMosqueName(rawName)) continue;

              final street = props['street'] as String? ?? '';
              final city = props['city'] as String? ?? props['state'] as String? ?? '';
              final addr = [street, city].where((s) => s.isNotEmpty).join(', ');

              final dist = _haversineMeters(lat, lon, itemLat, itemLon);
              if (dist <= 5000) {
                mosques.add(MosqueModel(
                  osmId: 'ph_${props['osm_id'] ?? itemLat}',
                  name: rawName,
                  address: addr.isEmpty ? 'Mevcut Bölge' : addr,
                  lat: itemLat,
                  lon: itemLon,
                  distanceMeters: dist,
                ));
              }
            }
          }
        }
        mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        if (mosques.isNotEmpty) {
          debugPrint('✅ Photon API: ${mosques.length} cami bulundu!');
          return mosques;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Photon arama hatası: $e');
    }
    return [];
  }

  /// OpenStreetMap Nominatim API ile alan sınırlı (bounded viewbox ~2.5km) yakın cami arama
  Future<List<MosqueModel>> _fetchFromNominatim({
    required double lat,
    required double lon,
  }) async {
    try {
      // 0.025 derece ~2.5km sıkı yakın çevre kutusu
      final left = lon - 0.025;
      final right = lon + 0.025;
      final top = lat + 0.025;
      final bottom = lat - 0.025;
      final url = 'https://nominatim.openstreetmap.org/search?format=json&q=cami&viewbox=$left,$top,$right,$bottom&bounded=1&limit=50&addressdetails=1';
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {'User-Agent': 'EzanVaktiApp/1.0 (com.alllivesupport.ezanvakti)'},
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.data is List) {
        final list = response.data as List;
        final mosques = <MosqueModel>[];
        for (final item in list) {
          if (item is Map) {
            final displayName = item['display_name'] as String? ?? '';
            final rawName = displayName.split(',').first.trim();

            if (!_isValidMosqueItem(item, rawName)) continue;

            final itemLat = double.tryParse(item['lat'].toString());
            final itemLon = double.tryParse(item['lon'].toString());
            if (itemLat != null && itemLon != null) {
              final dist = _haversineMeters(lat, lon, itemLat, itemLon);
              // Sadece 5km içindekileri kabul et
              if (dist <= 5000) {
                mosques.add(MosqueModel(
                  osmId: 'nom_${item['place_id']}',
                  name: rawName,
                  address: displayName,
                  lat: itemLat,
                  lon: itemLon,
                  distanceMeters: dist,
                ));
              }
            }
          }
        }
        // Mesafeye göre en yakından en uzağa kesin sırala
        mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        if (mosques.isNotEmpty) {
          debugPrint('✅ Nominatim API: ${mosques.length} en yakın cami bulundu!');
          return mosques;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Nominatim arama hatası: $e');
    }
    return [];
  }

  /// Overpass ana ve yedek sunucularından sırayla veri çekme
  Future<List<MosqueModel>> _fetchFromOverpassEndpoints({
    required double lat,
    required double lon,
    required double radiusMeters,
  }) async {
    final endpoints = [
      AppConstants.overpassUrl,
      AppConstants.overpassMirrorUrl,
      'https://overpass-api.de/api/interpreter', // Explicit 2nd fallback
    ];

    final query = '''
[out:json][timeout:15];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lon);
  node["building"="mosque"](around:$radiusMeters,$lat,$lon);
  way["building"="mosque"](around:$radiusMeters,$lat,$lon);
);
out center tags;
''';

    final bodyData = 'data=${Uri.encodeComponent(query)}';

    for (final url in endpoints) {
      try {
        debugPrint('🕌 Cami aranıyor: $url (Lat: $lat, Lon: $lon, Radius: ${radiusMeters}m)');
        final response = await _dio.post(
          url,
          data: bodyData,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.json,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

        if (response.data != null && response.data is Map) {
          final elements = response.data['elements'] as List?;
          if (elements != null && elements.isNotEmpty) {
            final mosques = _parseMosqueElements(elements, lat, lon);
            if (mosques.isNotEmpty) {
              debugPrint('✅ ${mosques.length} adet cami bulundu ($url)');
              return mosques;
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Overpass isteği başarısız ($url): $e');
      }
    }

    return [];
  }

  List<MosqueModel> _parseMosqueElements(List elements, double userLat, double userLon) {
    final mosques = <MosqueModel>[];

    for (final element in elements) {
      if (element is! Map) continue;
      final tags = element['tags'] as Map<String, dynamic>?;
      if (tags == null) continue;

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

      // İsmi tags'ten çek
      final rawName = tags['name:tr'] as String? ?? tags['name'] as String? ?? '';
      // İsim yoksa veya cadde/sokak gibi görünüyorsa atla
      if (rawName.isEmpty || _isStreetLikeName(rawName)) continue;

      final name = rawName;
      final addrStr = _buildAddress(tags);
      final distance = _haversineMeters(userLat, userLon, elLat, elLon);

      mosques.add(MosqueModel(
        osmId: '${element['type']}_${element['id']}',
        name: name,
        address: addrStr,
        lat: elLat,
        lon: elLon,
        distanceMeters: distance,
      ));
    }

    final seen = <String>{};
    final unique = mosques.where((m) => seen.add(m.osmId)).toList();
    unique.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return unique;
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) parts.add(tags['addr:street'] as String);
    if (tags['addr:housenumber'] != null) parts.add('No: ${tags['addr:housenumber']}');
    if (tags['addr:district'] != null) parts.add(tags['addr:district'] as String);
    if (tags['addr:city'] != null) parts.add(tags['addr:city'] as String);
    
    return parts.isEmpty ? 'Bilgi Yok' : parts.join(', ');
  }

  /// Nominatim & API öğesinin geçerli bir cami olup olmadığını doğrulayan Japon İşçiliği filtresi
  bool _isValidMosqueItem(Map item, String rawName) {
    if (rawName.isEmpty) return false;
    final lower = rawName.toLowerCase();

    // 1. Cami dışı ibadethane ve diğer yapı filtreleri
    const nonMosqueTerms = [
      'kilise', 'church', 'synagogue', 'havra', 'taziye', 'okul', 'lise',
      'park', 'belediye', 'hastane', 'eczane', 'köprü', 'tünel', 'istasyon'
    ];
    if (nonMosqueTerms.any((k) => lower.contains(k))) return false;

    // 2. Cadde / Sokak / Bulvar adı süzgeci (İçinde 'cami' veya 'mescit' yoksa)
    const streetTerms = ['cadde', 'sokak', 'bulvar', ' bulv', ' cd', ' sk', 'yolu', 'nolu', 'mah.'];
    final hasStreetTerm = streetTerms.any((k) => lower.contains(k));
    final hasMosqueTerm = _isMosqueName(rawName);

    if (hasStreetTerm && !hasMosqueTerm) return false;

    // 3. İsimde açıkça cami/mescit geçmiyorsa OSM sınıfını kontrol et
    if (!hasMosqueTerm) {
      final typeStr = (item['type'] as String? ?? '').toLowerCase();
      final osmClass = (item['class'] as String? ?? '').toLowerCase();
      final isValidClass = typeStr == 'place_of_worship' || typeStr == 'mosque' ||
          osmClass == 'amenity' || osmClass == 'building';
      if (!isValidClass) return false;
    }

    return true;
  }

  /// Bir ismin cadde/sokak/numara gibi görünüp görünmediğini kontrol eder
  bool _isStreetLikeName(String name) {
    final lower = name.toLowerCase();
    if (RegExp(r'^[\d\s\-\.]+$').hasMatch(name)) return true;
    final hasStreet = lower.contains('cadde') || lower.contains('sokak') ||
        lower.contains('bulvar') || lower.contains('nolu cad') ||
        lower.contains(' sk') || lower.contains(' cd') || lower.startsWith('no:');
    final hasMosque = _isMosqueName(name);
    return hasStreet && !hasMosque;
  }

  /// İsmin cami/mescit ile ilgili olup olmadığını kontrol eder
  bool _isMosqueName(String name) {
    final lower = name.toLowerCase();
    return lower.contains('cami') || lower.contains('mescit') || lower.contains('camii') ||
        lower.contains('mosque') || lower.contains('masjid') || lower.contains('jami');
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
