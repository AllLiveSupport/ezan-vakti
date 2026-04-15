// lib/shared/models/city_model.dart
import 'dart:math';

class CityModel {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String timezone;
  final int? diyanetId;
  final String? region;
  final String? country;
  final String? countryCode;
  final int? method;

  const CityModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.timezone,
    this.diyanetId,
    this.region,
    this.country,
    this.countryCode,
    this.method,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      timezone: json['timezone'] as String,
      diyanetId: json['diyanet_id'] as int?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      method: json['method'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lon': lon,
        'timezone': timezone,
        'diyanet_id': diyanetId,
        'region': region,
        'country': country,
        'country_code': countryCode,
        'method': method,
      };

  /// Haversine formülü ile iki koordinat arasındaki mesafe (km)
  double distanceTo(double otherLat, double otherLon) {
    const earthRadius = 6371.0;
    final dLat = _toRad(otherLat - lat);
    final dLon = _toRad(otherLon - lon);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat)) *
            cos(_toRad(otherLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  @override
  String toString() => 'CityModel($name, country=$country, lat=$lat, lon=$lon)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CityModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
