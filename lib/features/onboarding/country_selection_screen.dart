import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class CountryModel {
  final String code;
  final String name;
  final String flag;
  final int method;
  final int school;

  const CountryModel({
    required this.code,
    required this.name,
    required this.flag,
    required this.method,
    required this.school,
  });
}

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryModel> _allCountries = [];
  List<CountryModel> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final String raw = await rootBundle.loadString('assets/data/world_cities.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final countries = (data['countries'] as List).map((c) => CountryModel(
      code: c['code'] as String,
      name: c['name'] as String,
      flag: c['flag'] as String,
      method: (c['method'] as num).toInt(),
      school: (c['school'] as num).toInt(),
    )).toList();

    // Sort: Turkey first, then alphabetical
    countries.sort((a, b) {
      if (a.code == 'TR') return -1;
      if (b.code == 'TR') return 1;
      return a.name.compareTo(b.name);
    });

    setState(() {
      _allCountries = countries;
      _filtered = countries;
      _loading = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _allCountries
          : _allCountries.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  void _selectCountry(CountryModel country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedCountryCode, country.code);
    await prefs.setString(AppConstants.keySelectedCountryName, country.name);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/city-selection',
      arguments: {'countryCode': country.code, 'countryName': country.name, 'method': country.method, 'school': country.school},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.public_rounded, color: AppTheme.primary, size: 28),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 20),
                  Text(
                    'Ülkenizi Seçin',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 6),
                  Text(
                    'Namaz vakitleri bulunduğunuz ülkeye göre hesaplanır.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.12)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ülke ara...',
                    hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            // Country list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final country = _filtered[index];
                        return _CountryTile(
                          country: country,
                          onTap: () => _selectCountry(country),
                          delay: (index * 30).ms,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final CountryModel country;
  final VoidCallback onTap;
  final Duration delay;

  const _CountryTile({
    required this.country,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = country.code == 'TR';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppTheme.primary.withValues(alpha: 0.08)
                  : AppTheme.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : AppTheme.onSurfaceVariant.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Text(
                  country.flag,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                      color: isHighlighted ? AppTheme.primary : AppTheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: delay).fadeIn().slideX(begin: 0.05, end: 0),
    );
  }
}
