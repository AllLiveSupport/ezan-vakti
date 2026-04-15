import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../../core/theme/app_theme.dart';
import '../../core/network/mosque_service.dart';
import '../../shared/providers/mosque_provider.dart';
import '../../shared/providers/prayer_provider.dart';

class MosqueMapScreen extends ConsumerStatefulWidget {
  const MosqueMapScreen({super.key});

  @override
  ConsumerState<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends ConsumerState<MosqueMapScreen> {
  LatLng _currentCenter = const LatLng(39.9334, 32.8597);
  final MapController _mapController = MapController();
  bool _isFirstLoad = true;
  bool _isSearching = false;
  bool _isOffline = false;
  
  // FMTC Tile Provider
  FMTCTileProvider? _tileProvider;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _initTileCaching();
    _checkLocationPermission();
  }
  
  /// Tile caching başlat
  Future<void> _initTileCaching() async {
    // FMTC ObjectBox backend başlat (sadece bir kez main'de yapılmalı, 
    // ama burada da kontrol ediyoruz)
    try {
      await FMTCObjectBoxBackend().initialise();
    } catch (e) {
      // Zaten initialise edilmiş olabilir, görmezden gel
    }
    
    // Store oluştur (eğer yoksa)
    final store = FMTCStore('mosqueMapStore');
    try {
      await store.manage.create();
    } catch (e) {
      // Store zaten varsa hata vermez, devam et
    }
    
    // Tile provider oluştur
    setState(() {
      _tileProvider = FMTCTileProvider(
        stores: const {'mosqueMapStore': BrowseStoreStrategy.readUpdateCreate},
        loadingStrategy: BrowseLoadingStrategy.cacheFirst,
      );
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = result.contains(ConnectivityResult.none) && result.length == 1;
    });
    
    // Dinleyici ekle
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result.contains(ConnectivityResult.none) && result.length == 1;
      });
    });
  }

  Future<void> _checkLocationPermission() async {
    // Önce splash'den kaydedilmiş konum var mı kontrol et (hızlı açılış için)
    final cachedLoc = await _getCachedSplashLocation();
    if (cachedLoc != null) {
      debugPrint('📍 Splash konumu kullanılıyor: $cachedLoc');
      if (mounted) {
        setState(() {
          _currentCenter = cachedLoc;
          _isFirstLoad = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(cachedLoc, 15);
        });
        ref.invalidate(nearbyMosquesProvider);
      }
      // Arka planda GPS'ten daha hassas konumu al (güncelleme için)
      _refineLocationFromGPS();
      return;
    }

    // Splash'de konum yok, GPS'ten al
    await _getLocationFromGPS();
  }

  /// Splash'den kaydedilmiş konumu getir (5 dakika içinde mi kontrol et)
  Future<LatLng?> _getCachedSplashLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('splash_cached_lat');
      final lon = prefs.getDouble('splash_cached_lon');
      final cachedAt = prefs.getInt('splash_cached_at');

      if (lat == null || lon == null || cachedAt == null) return null;

      // 5 dakika içinde kaydedilmiş mi kontrol et
      final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
      if (age > 5 * 60 * 1000) return null; // 5 dakikadan eski

      return LatLng(lat, lon);
    } catch (e) {
      return null;
    }
  }

  /// GPS'ten konum al (ana konum alma yöntemi)
  Future<void> _getLocationFromGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Konum servisi kapalı');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // İzin var, konum al ve haritayı güncelle
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        final gpsLoc = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentCenter = gpsLoc;
          _isFirstLoad = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(gpsLoc, 15);
        });
        ref.invalidate(nearbyMosquesProvider);
      }
    } catch (e) {
      debugPrint('📍 GPS konum alma hatası: $e');
    }
  }

  /// Arka planda GPS'ten daha hassas konum al (opsiyonel güncelleme)
  Future<void> _refineLocationFromGPS() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Eğer konum önemli ölçüde değiştiyse güncelle
      final newLoc = LatLng(position.latitude, position.longitude);
      final distance = const Distance().as(LengthUnit.Meter, _currentCenter, newLoc);

      if (distance > 50 && mounted) { // 50 metreden fazla değişiklik
        debugPrint('📍 Konum güncellendi (fark: ${distance.toStringAsFixed(0)}m)');
        setState(() => _currentCenter = newLoc);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(newLoc, 15);
        });
        ref.invalidate(nearbyMosquesProvider);
      }
    } catch (e) {
      // Arka plan güncelleme hatası önemli değil
      debugPrint('📍 Konum iyileştirme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(nearbyMosquesProvider);
    final userLoc = ref.watch(userLocationProvider).asData?.value;
    final city = ref.watch(activeCityProvider).asData?.value;

    if (_isFirstLoad && (userLoc != null || city != null)) {
      _currentCenter = userLoc ?? LatLng(city!.lat, city.lon);
      _isFirstLoad = false;
    }

    final mosqueCount = mosquesAsync.asData?.value.length ?? 0;
    final isLoading = mosquesAsync.isLoading || _isSearching;
    // Konum henüz yükleniyor mu? (Splash konumu bekleniyor veya GPS'ten alınıyor)
    final isLocating = _isFirstLoad;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Main Content: Map (Always show map, online or offline) ─────
          _buildMapView(userLoc, mosquesAsync),

          // ─── Location Loading Overlay ───────────────────────────────────
          if (isLocating)
            Container(
              color: Colors.white.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Konumunuz tespit ediliyor...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yakınınızdaki camiler gösteriliyor',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Back Button (sadece route olarak açıldığında göster) ──────
          if (Navigator.of(context).canPop())
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: _MapFab(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Geri',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),

          // ─── Top Status Bar ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: Navigator.of(context).canPop() ? 68 : 16,
            right: 72,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(
                    _isOffline ? Icons.wifi_off_rounded : Icons.mosque_rounded, 
                    color: _isOffline ? Colors.orange : AppTheme.primary, 
                    size: 18
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLoading 
                            ? 'Camiler aranıyor...' 
                            : '$mosqueCount cami bulundu${_isOffline ? ' (Offline)' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        if (_isOffline)
                          const Text(
                            'İnternet bağlantısı yok - Cache\'ten gösteriliyor',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ─── Right Side FABs ─────────────────────────────────────────────
          if (!_isOffline)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 16,
              child: Column(
                children: [
                  _MapFab(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Konumuma Git',
                    onTap: _goToMyLocation,
                  ),
                  const SizedBox(height: 10),
                  _MapFab(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Yenile',
                    onTap: _searchArea,
                  ),
                ],
              ),
            ),

          // ─── Bottom: Search Button (only when online) ───────────────────
          if (!_isOffline)
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _searchArea,
                icon: isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search_rounded, size: 22),
                label: Text(
                  isLoading ? 'Aranıyor...' : 'Bu Bölgede Cami Bul',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 8,
                  shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Map View (Online + Offline) ──────────────────────────────────────
  Widget _buildMapView(LatLng? userLoc, AsyncValue<List<MosqueModel>> mosquesAsync) {
    // Tile provider hazır değilse loading göster
    if (_tileProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentCenter,
        initialZoom: 14.5,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            setState(() => _currentCenter = position.center);
          }
        },
      ),
      children: [
        // FMTC ile offline tile caching
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ezan_vakti.app',
          maxZoom: 19,
          tileProvider: _tileProvider!, // Cache'li tile provider
        ),
        MarkerLayer(
          markers: [
            if (userLoc != null)
              Marker(
                point: userLoc,
                width: 44,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 22),
                ),
              ),
            // Offline/Online fark etmeksizin cache'teki camileri göster
            ...mosquesAsync.maybeWhen(
              data: (mosques) => mosques.map((m) => _buildMosqueMarker(context, m)).toList(),
              orElse: () => <Marker>[],
            ),
          ],
        ),
      ],
    );
  }

  void _goToMyLocation() {
    final userLoc = ref.read(userLocationProvider).asData?.value;
    final city = ref.read(activeCityProvider).asData?.value;
    final target = userLoc ?? (city != null ? LatLng(city.lat, city.lon) : null);
    if (target != null) {
      _mapController.move(target, 15.0);
      setState(() => _currentCenter = target);
    }
  }

  void _searchArea() {
    setState(() => _isSearching = true);
    ref.read(mosqueSearchCenterProvider.notifier).setCenter(_currentCenter);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSearching = false);
    });
  }

  Marker _buildMosqueMarker(BuildContext context, MosqueModel mosque) {
    return Marker(
      point: LatLng(mosque.lat, mosque.lon),
      width: 60,
      height: 60,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _showMosqueDetails(context, mosque),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque,
                color: Colors.white,
                size: 20,
              ),
            ),
            CustomPaint(
              size: const Size(10, 10),
              painter: TrianglePainter(AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _showMosqueDetails(BuildContext context, MosqueModel mosque) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              mosque.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  mosque.distanceFormatted,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(width: 12),
                Icon(Icons.directions_walk, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${mosque.etaMinutes} dk',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchNavigation(mosque.lat, mosque.lon),
                    icon: const Icon(Icons.navigation),
                    label: const Text('Yol Tarifi Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchNavigation(double lat, double lon) async {
    final url = Uri.parse('google.navigation:q=$lat,$lon&mode=w');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _MapFab({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
