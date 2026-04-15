import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/qibla_math_service.dart';
import 'prayer_provider.dart';

/// Kullanıcının Kabe'ye olan mesafesini tutar (KM)
final qiblaDistanceProvider = Provider<double>((ref) {
  final cityAsync = ref.watch(activeCityProvider);
  final city = cityAsync.asData?.value;
  if (city == null) return 0.0;
  return QiblaMathService.calculateDistanceToKaaba(city.lat, city.lon);
});

/// Kullanıcının konumuna göre Kabe yönünün açısını (Bearing) tutar
final qiblaBearingProvider = Provider<double>((ref) {
  final cityAsync = ref.watch(activeCityProvider);
  final city = cityAsync.asData?.value;
  if (city == null) return 0.0;
  return QiblaMathService.calculateQiblaBearing(city.lat, city.lon);
});

/// Cihaz pusulasının canlı yön verisini (Heading) dinler
final compassStreamProvider = StreamProvider<CompassEvent>((ref) {
  return FlutterCompass.events ?? const Stream.empty();
});

/// Cihazın Kıble hedefine tam dönüp dönmediğini kontrol eden stream (Kalp atışı, vs için UI'a yardımcı)
final isFacingQiblaProvider = Provider<bool>((ref) {
  final compassAsync = ref.watch(compassStreamProvider);
  final currentHeading = compassAsync.asData?.value.heading;
  final qiblaBearing = ref.watch(qiblaBearingProvider);

  if (currentHeading == null) return false;

  // 3 derecelik hata payı (Threshold)
  const threshold = 3.0;
  
  // Açı farkını bul. (Örn: Cihaz Heading 358°, Qibla 2°) 
  // Mod 360 alarak dairesel farkı temizle
  double diff = (currentHeading - qiblaBearing).abs() % 360.0;
  double distance = diff > 180 ? 360 - diff : diff;

  return distance <= threshold;
});
