import 'dart:math' as math;

/// Kabe Koordinatları (Mekke, Suudi Arabistan)
const double _kaabaLat = 21.422487;
const double _kaabaLon = 39.826206;

class QiblaMathService {
  /// Küresel Trigonometri ile Kıble Yönü (Bearing) hesaplar.
  /// Dönüş değeri Kuzey'den itibaren saat yönünde (0-360) derecedir.
  static double calculateQiblaBearing(double userLat, double userLon) {
    if (userLat == 0.0 && userLon == 0.0) return 0.0;

    final lat1 = userLat * math.pi / 180.0;
    final lon1 = userLon * math.pi / 180.0;
    final lat2 = _kaabaLat * math.pi / 180.0;
    final lon2 = _kaabaLon * math.pi / 180.0;

    final lonDelta = lon2 - lon1;

    final y = math.sin(lonDelta) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(lonDelta);

    var bearing = math.atan2(y, x) * 180.0 / math.pi;
    return (bearing + 360.0) % 360.0;
  }

  /// Haversine formülü kullanılarak kullanıcının Kabe'ye olan en kısa (kuş uçuşu) mesafesini kilometre cinsinden hesaplar.
  static double calculateDistanceToKaaba(double userLat, double userLon) {
    if (userLat == 0.0 && userLon == 0.0) return 0.0;

    final lat1 = userLat * math.pi / 180.0;
    final lon1 = userLon * math.pi / 180.0;
    final lat2 = _kaabaLat * math.pi / 180.0;
    final lon2 = _kaabaLon * math.pi / 180.0;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return 6371.0 * c; // Dünya yarıçapı ~6371 km
  }
}
