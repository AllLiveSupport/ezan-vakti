import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
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
  StreamSubscription? _connectivitySub; // Leak düzeltmesi
  String? _selectedMosqueId;
  
  String? _customLocationName;
  final TextEditingController _locationSearchController = TextEditingController();

  // FMTC Tile Provider
  FMTCTileProvider? _tileProvider;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _initTileCaching();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _locationSearchController.dispose();
    super.dispose();
  }
  
  /// Tile caching başlat
  Future<void> _initTileCaching() async {
    try {
      await FMTCObjectBoxBackend().initialise();
    } catch (_) {}
    
    final store = FMTCStore('mosqueMapStore');
    try {
      await store.manage.create();
    } catch (_) {}
    
    setState(() {
      _tileProvider = FMTCTileProvider(
        stores: const {'mosqueMapStore': BrowseStoreStrategy.readUpdateCreate},
        loadingStrategy: BrowseLoadingStrategy.cacheFirst,
      );
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = result.contains(ConnectivityResult.none) && result.length == 1;
      });
    }
    
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOffline = result.contains(ConnectivityResult.none) && result.length == 1;
        });
      }
    });
  }

  Future<void> _checkLocationPermission() async {
    final cachedLoc = await _getCachedSplashLocation();
    if (cachedLoc != null) {
      final isTurkey = cachedLoc.latitude >= 35.5 && cachedLoc.latitude <= 42.5 &&
          cachedLoc.longitude >= 25.5 && cachedLoc.longitude <= 45.0;
      if (isTurkey) {
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
        _refineLocationFromGPS();
        return;
      }
    }

    await _getLocationFromGPS();
  }

  Future<LatLng?> _getCachedSplashLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('splash_cached_lat');
      final lon = prefs.getDouble('splash_cached_lon');
      final cachedAt = prefs.getInt('splash_cached_at');

      if (lat == null || lon == null || cachedAt == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
      if (age > 5 * 60 * 1000) return null;

      return LatLng(lat, lon);
    } catch (e) {
      return null;
    }
  }

  Future<void> _getLocationFromGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final city = ref.read(activeCityProvider).value;

      if (!serviceEnabled) {
        debugPrint('📍 Konum servisi kapalı');
        if (city != null && mounted) {
          final cityLoc = LatLng(city.lat, city.lon);
          setState(() {
            _currentCenter = cityLoc;
            _isFirstLoad = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _mapController.move(cityLoc, 14);
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (city != null && mounted) {
            final cityLoc = LatLng(city.lat, city.lon);
            setState(() {
              _currentCenter = cityLoc;
              _isFirstLoad = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (city != null && mounted) {
          final cityLoc = LatLng(city.lat, city.lon);
          setState(() {
            _currentCenter = cityLoc;
            _isFirstLoad = false;
          });
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      LatLng targetLoc;
      if (position != null) {
        final isTurkey = position.latitude >= 35.5 && position.latitude <= 42.5 &&
            position.longitude >= 25.5 && position.longitude <= 45.0;
        if (isTurkey) {
          targetLoc = LatLng(position.latitude, position.longitude);
        } else if (city != null) {
          targetLoc = LatLng(city.lat, city.lon);
        } else {
          targetLoc = LatLng(position.latitude, position.longitude);
        }
      } else if (city != null) {
        targetLoc = LatLng(city.lat, city.lon);
      } else {
        targetLoc = _currentCenter;
      }

      if (mounted) {
        setState(() {
          _currentCenter = targetLoc;
          _isFirstLoad = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(targetLoc, 14);
        });
        ref.invalidate(nearbyMosquesProvider);
      }
    } catch (e) {
      debugPrint('📍 GPS konum alma hatası: $e');
      if (mounted) setState(() => _isFirstLoad = false);
    }
  }

  Future<void> _refineLocationFromGPS() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final isTurkey = position.latitude >= 35.5 && position.latitude <= 42.5 &&
          position.longitude >= 25.5 && position.longitude <= 45.0;

      if (!isTurkey) return;

      final newLoc = LatLng(position.latitude, position.longitude);
      final distance = const Distance().as(LengthUnit.Meter, _currentCenter, newLoc);

      if (distance > 100 && mounted) {
        setState(() => _currentCenter = newLoc);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(newLoc, 15);
        });
        ref.invalidate(nearbyMosquesProvider);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(nearbyMosquesProvider);
    final userLoc = ref.watch(userLocationProvider).asData?.value;
    final city = ref.watch(activeCityProvider).asData?.value;

    final isTurkeyUserLoc = userLoc != null &&
        userLoc.latitude >= 35.5 && userLoc.latitude <= 42.5 &&
        userLoc.longitude >= 25.5 && userLoc.longitude <= 45.0;

    if (_isFirstLoad) {
      if (isTurkeyUserLoc) {
        _currentCenter = userLoc;
        _isFirstLoad = false;
      } else if (city != null) {
        _currentCenter = LatLng(city.lat, city.lon);
        _isFirstLoad = false;
      }
    }

    final mosqueCount = mosquesAsync.asData?.value.length ?? 0;
    final isLoading = mosquesAsync.isLoading || _isSearching;
    final isLocating = _isFirstLoad;

    final displayLocation = _customLocationName ?? (city?.name ?? 'Konum Seç');

    return Scaffold(
      body: Stack(
        children: [
          // ─── Main Content: Map ──────────────────────────────────────────
          _buildMapView(isTurkeyUserLoc ? userLoc : null, mosquesAsync),

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

          // ─── Back Button ─────────────────────────────────────────────────
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

          // ─── Top Interactive Location Bar ───────────────────────────────
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: Navigator.of(context).canPop() ? 68 : 16,
            right: 72,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLocationSearchModal(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isOffline ? Icons.wifi_off_rounded : Icons.location_on_rounded, 
                        color: _isOffline ? Colors.orange : AppTheme.primary, 
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.primary),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              isLoading 
                                ? 'Camiler aranıyor...' 
                                : '$mosqueCount cami bulundu${_isOffline ? ' (Offline)' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isLoading ? AppTheme.primary : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        )
                      else
                        Icon(Icons.search_rounded, size: 18, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Right Side FABs ─────────────────────────────────────────────
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
                if (!_isOffline)
                  _MapFab(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Yenile',
                    onTap: _searchArea,
                  ),
              ],
            ),
          ),

          // ─── Bottom Panel: Cami Kartları & Yol Tarifi Carousel ────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bulunan Camiler Yatay Kaydırılabilir Kart Listesi
                if (mosqueCount > 0)
                  SizedBox(
                    height: 124,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: mosquesAsync.asData?.value.length ?? 0,
                      itemBuilder: (context, index) {
                        final mosque = mosquesAsync.asData!.value[index];
                        final isSelected = _selectedMosqueId == mosque.osmId;

                        return Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedMosqueId = mosque.osmId);
                              _mapController.move(LatLng(mosque.lat, mosque.lon), 16.0);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.mosque, color: AppTheme.primary, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        mosque.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 2),
                                    Text(
                                      mosque.distanceFormatted,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.directions_walk, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${mosque.etaMinutes} dk',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 34,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _launchNavigation(mosque.lat, mosque.lon),
                                    icon: const Icon(Icons.navigation_rounded, size: 15),
                                    label: const Text('Google Maps ile Git', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Bölgede Arama Butonu
                if (!_isOffline)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _searchArea,
                        icon: isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.search_rounded, size: 20),
                        label: Text(
                          isLoading ? 'Camiler Aranıyor...' : 'Bu Bölgede Cami Bul',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 6,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    ),
                  ),
              ],
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

    final isTurkey = userLoc != null &&
        userLoc.latitude >= 35.5 && userLoc.latitude <= 42.5 &&
        userLoc.longitude >= 25.5 && userLoc.longitude <= 45.0;

    final target = isTurkey ? userLoc : (city != null ? LatLng(city.lat, city.lon) : null);

    if (target != null) {
      setState(() {
        _customLocationName = isTurkey ? 'Mevcut Konumum' : (city?.name ?? 'Konum');
        _currentCenter = target;
      });
      _mapController.move(target, 15.0);
      ref.read(mosqueSearchCenterProvider.notifier).setCenter(target);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum tespiti yapılamadı.')),
      );
    }
  }

  void _searchArea() {
    setState(() => _isSearching = true);
    ref.read(mosqueSearchCenterProvider.notifier).setCenter(_currentCenter);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSearching = false);
    });
  }

  /// Kullanıcının istediği il/ilçe/konumu arayıp haritayı o bölgeye taşımasını sağlar
  void _showLocationSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationSearchBottomSheet(
        onLocationSelected: (name, lat, lon) {
          Navigator.pop(context);
          final newCenter = LatLng(lat, lon);
          setState(() {
            _customLocationName = name;
            _currentCenter = newCenter;
          });
          _mapController.move(newCenter, 14.0);
          ref.read(mosqueSearchCenterProvider.notifier).setCenter(newCenter);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 $name bölgesindeki camiler gösteriliyor'),
              duration: const Duration(seconds: 3),
              backgroundColor: AppTheme.primary,
            ),
          );
        },
        onUseMyLocation: () {
          Navigator.pop(context);
          _goToMyLocation();
        },
      ),
    );
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

/// Arama & Konum Seçimi Bottom Sheet
class _LocationSearchBottomSheet extends StatefulWidget {
  final void Function(String name, double lat, double lon) onLocationSelected;
  final VoidCallback onUseMyLocation;

  const _LocationSearchBottomSheet({
    required this.onLocationSelected,
    required this.onUseMyLocation,
  });

  @override
  State<_LocationSearchBottomSheet> createState() => _LocationSearchBottomSheetState();
}

class _LocationSearchBottomSheetState extends State<_LocationSearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  Timer? _debounceTimer;

  // Hızlı Seçim İçin Popüler Şehirler (Enlem, Boylam)
  final List<Map<String, dynamic>> _quickCities = const [
    {'name': 'Gaziantep', 'lat': 37.0660, 'lon': 37.3833},
    {'name': 'Hatay (Antakya)', 'lat': 36.2025, 'lon': 36.1641},
    {'name': 'İskenderun', 'lat': 36.5902, 'lon': 36.1710},
    {'name': 'İstanbul', 'lat': 41.0082, 'lon': 28.9784},
    {'name': 'Ankara', 'lat': 39.9334, 'lon': 32.8597},
    {'name': 'İzmir', 'lat': 38.4237, 'lon': 27.1428},
    {'name': 'Adana', 'lat': 37.0000, 'lon': 35.3213},
    {'name': 'Antalya', 'lat': 36.8969, 'lon': 30.7133},
    {'name': 'Bursa', 'lat': 40.1885, 'lon': 29.0610},
    {'name': 'Konya', 'lat': 37.8746, 'lon': 32.4932},
    {'name': 'Mersin', 'lat': 36.8121, 'lon': 34.6415},
    {'name': 'Şanlıurfa', 'lat': 37.1674, 'lon': 38.7955},
    {'name': 'Trabzon', 'lat': 41.0027, 'lon': 39.7168},
    {'name': 'Diyarbakır', 'lat': 37.9144, 'lon': 40.2306},
  ];

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    if (text.trim().length < 2) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () => _performGeocodeSearch(text.trim()));
  }

  Future<void> _performGeocodeSearch(String query) async {
    if (!mounted) return;
    setState(() => _searching = true);

    try {
      final dio = Dio();
      final url = 'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&countrycodes=tr&limit=8&addressdetails=1';
      final response = await dio.get(
        url,
        options: Options(headers: {'User-Agent': 'EzanVaktiApp/1.0 (com.alllivesupport.ezanvakti)'}),
      );

      if (response.data is List && mounted) {
        final list = response.data as List;
        final res = <Map<String, dynamic>>[];
        for (final item in list) {
          if (item is Map) {
            final lat = double.tryParse(item['lat'].toString());
            final lon = double.tryParse(item['lon'].toString());
            final displayName = item['display_name'] as String? ?? query;
            final shortName = displayName.split(',').take(2).join(', ').trim();

            if (lat != null && lon != null) {
              res.add({
                'name': shortName,
                'fullName': displayName,
                'lat': lat,
                'lon': lon,
              });
            }
          }
        }
        setState(() {
          _results = res;
          _searching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çizgi tutamaç
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
          const SizedBox(height: 16),

          // Başlık
          Row(
            children: [
              const Icon(Icons.saved_search_rounded, color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Konum veya Bölge Seçin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Arama Giriş Kutusu
          TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'İl, ilçe veya bölge adı yazın (örn: Hatay, Antakya, İskenderun)...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Mevcut Konum Butonu
          InkWell(
            onTap: widget.onUseMyLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.my_location_rounded, color: AppTheme.primary, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Mevcut GPS Konumumu Kullan',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Hızlı Şehir Seçenekleri (Arama Yapılmıyorsa)
          if (_controller.text.isEmpty) ...[
            Text(
              'Hızlı Şehir & Bölge Seçimi',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickCities.map((c) {
                return ChoiceChip(
                  label: Text(c['name'] as String),
                  selected: false,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  backgroundColor: colorScheme.surfaceContainerLow,
                  onSelected: (_) => widget.onLocationSelected(
                    c['name'] as String,
                    c['lat'] as double,
                    c['lon'] as double,
                  ),
                );
              }).toList(),
            ),
          ],

          // Arama Sonuçları
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            )
          else if (_results.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _results[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.location_city_rounded, color: AppTheme.primary, size: 20),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      item['fullName'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    onTap: () => widget.onLocationSelected(
                      item['name'] as String,
                      item['lat'] as double,
                      item['lon'] as double,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

