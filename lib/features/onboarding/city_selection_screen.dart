// lib/features/onboarding/city_selection_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/city_model.dart';
import '../../shared/providers/prayer_provider.dart';
import 'package:geolocator/geolocator.dart';

class CitySelectionScreen extends ConsumerStatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  ConsumerState<CitySelectionScreen> createState() =>
      _CitySelectionScreenState();
}

class _CitySelectionScreenState extends ConsumerState<CitySelectionScreen> {
  List<CityModel> _allCities = [];
  List<CityModel> _filteredCities = [];
  final _searchController = TextEditingController();
  bool _loading = true;
  CityModel? _selectedCity;
  bool _detectingLocation = false;
  String? _selectedRegion;

  String? _countryCode;
  String? _countryName;
  int _countryMethod = 13;
  bool _isTurkey = true;

  final List<String> _regions = [
    'Tümü', 'Marmara', 'Ege', 'Akdeniz',
    'İç Anadolu', 'Karadeniz', 'Doğu Anadolu', 'Güneydoğu Anadolu',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCities);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_allCities.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _countryCode = args?['countryCode'] as String? ?? 'TR';
      _countryName = args?['countryName'] as String? ?? 'Türkiye';
      _countryMethod = (args?['method'] as int?) ?? 13;
      _isTurkey = _countryCode == 'TR';
      _loadCities();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/world_cities.json');
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final countries = decoded['countries'] as List;

      final countryData = countries.firstWhere(
        (c) => c['code'] == _countryCode,
        orElse: () => countries.first,
      );

      final cityList = countryData['cities'] as List;
      final cities = cityList.map((c) {
        final m = c as Map<String, dynamic>;
        return CityModel(
          id: m['id'] as String,
          name: m['name'] as String,
          lat: (m['lat'] as num).toDouble(),
          lon: (m['lon'] as num).toDouble(),
          timezone: m['timezone'] as String,
          countryCode: _countryCode,
          country: _countryName,
          method: _countryMethod,
          diyanetId: m['diyanet_id'] as int?,
          region: m['region'] as String?,
        );
      }).toList();

      cities.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _allCities = cities;
        _filteredCities = cities;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _filterCities() {
    final query = _normalizeQuery(_searchController.text.trim());
    setState(() {
      _filteredCities = _allCities.where((city) {
        final nameNorm = _normalizeQuery(city.name);
        final regionMatch = !_isTurkey ||
            _selectedRegion == null ||
            _selectedRegion == 'Tümü' ||
            city.region == _selectedRegion;
        return nameNorm.contains(query) && regionMatch;
      }).toList();
    });
  }

  String _normalizeQuery(String input) {
    return input
        .toLowerCase()
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');
  }

  Future<void> _detectLocation() async {
    setState(() => _detectingLocation = true);

    try {
      final permission = await Geolocator.checkPermission();
      LocationPermission finalPermission = permission;

      if (permission == LocationPermission.denied) {
        finalPermission = await Geolocator.requestPermission();
      }

      if (finalPermission == LocationPermission.deniedForever) {
        _showSnack('Konum izni verilmemiş. Ayarlardan açabilirsin.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      CityModel? nearest;
      double minDist = double.infinity;
      for (final city in _allCities) {
        final dist = city.distanceTo(position.latitude, position.longitude);
        if (dist < minDist) {
          minDist = dist;
          nearest = city;
        }
      }

      if (nearest != null && minDist < 80) {
        setState(() => _selectedCity = nearest);
        _showSnack('${nearest.name} tespit edildi ✓');
      } else {
        final customCity = CityModel(
          id: 'GPS_CUSTOM',
          name: 'Mevcut Konum',
          lat: position.latitude,
          lon: position.longitude,
          timezone: 'UTC',
          countryCode: _countryCode,
          country: _countryName,
          method: _countryMethod,
        );
        setState(() => _selectedCity = customCity);
        _showSnack('GPS konumu belirlendi ✓');
      }
    } catch (e) {
      _showSnack('Konum tespit edilemedi.');
    } finally {
      setState(() => _detectingLocation = false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedCity == null) {
      _showSnack('Lütfen bir şehir seç.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedCityId, _selectedCity!.id);
    await prefs.setString(AppConstants.keySelectedCityName, _selectedCity!.name);
    await prefs.setDouble(AppConstants.keyCityLat, _selectedCity!.lat);
    await prefs.setDouble(AppConstants.keyCityLon, _selectedCity!.lon);
    await prefs.setString(AppConstants.keyCityTimezone, _selectedCity!.timezone);
    await prefs.setString(AppConstants.keySelectedCountryCode, _countryCode ?? 'TR');
    await prefs.setString(AppConstants.keySelectedCountryName, _countryName ?? 'Türkiye');
    await prefs.setInt(AppConstants.keyCityMethod, _countryMethod);
    await prefs.setBool(AppConstants.keyIsFirstLaunch, false);

    if (mounted) {
      ref.invalidate(activeCityProvider);
      ref.invalidate(todayPrayerTimesProvider);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.onSurface;
    final subTextColor = isDark ? Colors.white70 : AppTheme.onSurfaceVariant;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Ülke seçim sayfası kaldırıldı - geri butonu yok
                      // IconButton(
                      //   icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      //   onPressed: () => Navigator.pushReplacementNamed(context, '/country-selection'),
                      //   color: textColor,
                      // ),
                      // const SizedBox(width: 4),
                      Text(
                        _countryName ?? 'Şehir Seç',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Şehrinizi Seçin',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textColor),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Namaz vakitleri seçtiğiniz şehre göre hesaplanır.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: subTextColor,
                        ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 20),

                  // GPS Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _detectingLocation ? null : _detectLocation,
                      icon: _detectingLocation
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: Text(_detectingLocation ? 'Konum Tespit Ediliyor...' : 'GPS ile Konum Bul'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 14),

                  // Search
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Şehir ara...',
                      hintStyle: TextStyle(color: subTextColor),
                      prefixIcon: Icon(Icons.search_rounded, color: subTextColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: subTextColor),
                              onPressed: () { _searchController.clear(); _filterCities(); },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 10),

                  // Region chips (only for Turkey)
                  if (_isTurkey)
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _regions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final r = _regions[i];
                          final isSelected = (_selectedRegion == null && r == 'Tümü') || _selectedRegion == r;
                          final chipTextColor = isSelected ? AppTheme.onPrimaryContainer : textColor;
                          return FilterChip(
                            selected: isSelected,
                            label: Text(r, style: TextStyle(fontSize: 12, color: chipTextColor)),
                            onSelected: (_) { setState(() { _selectedRegion = r == 'Tümü' ? null : r; }); _filterCities(); },
                            backgroundColor: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerHighest,
                            selectedColor: AppTheme.primaryContainer,
                            checkmarkColor: AppTheme.primary,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            // ─── City List ─────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _filteredCities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: subTextColor),
                              const SizedBox(height: 12),
                              Text('Şehir bulunamadı.\nGPS butonu ile konumunuzu belirleyin.', 
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredCities.length,
                          itemBuilder: (ctx, i) {
                            final city = _filteredCities[i];
                            final isSelected = _selectedCity?.id == city.id;
                            final tileBgColor = isSelected 
                                ? AppTheme.primaryContainer 
                                : (isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow);
                            final tileTextColor = isSelected ? AppTheme.onPrimaryContainer : textColor;
                            final subTextColorTile = isSelected 
                                ? AppTheme.onPrimaryContainer.withValues(alpha: 0.7) 
                                : subTextColor;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tileBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected ? Border.all(color: AppTheme.primary, width: 1.5) : null,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                title: Text(
                                  city.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: tileTextColor,
                                  ),
                                ),
                                subtitle: city.region != null
                                    ? Text(city.region!, style: TextStyle(fontSize: 12, color: subTextColorTile))
                                    : null,
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
                                    : Icon(Icons.chevron_right_rounded, color: subTextColor),
                                onTap: () => setState(() => _selectedCity = city),
                              ),
                            );
                          },
                        ),
            ),

            // ─── Continue Button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  if (_selectedCity != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedCity!.id == 'GPS_CUSTOM' ? Icons.gps_fixed_rounded : Icons.location_city_rounded,
                            color: AppTheme.primary, size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedCity!.name} seçildi',
                            style: const TextStyle(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedCity != null ? _saveAndContinue : null,
                      child: const Text('Başla  →', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
