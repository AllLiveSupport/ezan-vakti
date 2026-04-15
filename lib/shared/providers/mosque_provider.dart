import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/network/mosque_service.dart';
import 'prayer_provider.dart';

final mosqueServiceProvider = Provider<MosqueService>((ref) {
  return MosqueService();
});

/// Cihazın canlı GPS konumunu takip eden provider
/// Cihazın canlı GPS konumunu takip eden provider (Unblocked)
final userLocationProvider = StreamProvider<LatLng?>((ref) async* {
  yield null; // İlk adımda null dönerek bağımlı provider'ların bloklanmasını engeller.
  
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      ),
    );
    yield LatLng(position.latitude, position.longitude);
  } catch (_) {
    yield null;
  }
});

/// Cami arama merkezi (null ise userLocation veya city kullanılır)
class MosqueSearchCenterNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;

  void setCenter(LatLng center) {
    state = center;
  }

  void clear() {
    state = null;
  }
}

final mosqueSearchCenterProvider = NotifierProvider<MosqueSearchCenterNotifier, LatLng?>(
  MosqueSearchCenterNotifier.new,
);

/// Canlı konuma (GPS) veya seçili şehre göre camileri çeker.
final nearbyMosquesProvider = FutureProvider<List<MosqueModel>>((ref) async {
  final manualCenter = ref.watch(mosqueSearchCenterProvider);
  
  // AsyncValue'dan veriyi alıyoruz, loading durumunda ana provider'ı bloklamıyoruz.
  final userLoc = ref.watch(userLocationProvider).asData?.value;

  final city = ref.watch(activeCityProvider).asData?.value;
  
  // Öncelik: Manuel Seçilen > Canlı GPS > Şehir Merkezi
  final lat = manualCenter?.latitude ?? userLoc?.latitude ?? city?.lat;
  final lon = manualCenter?.longitude ?? userLoc?.longitude ?? city?.lon;

  if (lat == null || lon == null) return [];

  final service = ref.read(mosqueServiceProvider);
  return service.getNearbyMosques(lat: lat, lon: lon);
});

