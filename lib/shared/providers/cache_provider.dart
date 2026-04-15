import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheState {
  final String? selectedCity;
  final bool isFirstLaunch;
  final int selectedYear;

  const CacheState({
    this.selectedCity,
    this.isFirstLaunch = true,
    this.selectedYear = 2026,
  });

  CacheState copyWith({
    String? selectedCity,
    bool? isFirstLaunch,
    int? selectedYear,
  }) {
    return CacheState(
      selectedCity: selectedCity ?? this.selectedCity,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class CacheNotifier extends AsyncNotifier<CacheState> {
  late SharedPreferences _prefs;

  @override
  Future<CacheState> build() async {
    _prefs = await SharedPreferences.getInstance();
    
    final city = _prefs.getString('selected_city');
    final isFirst = _prefs.getBool('is_first_launch') ?? true;
    final year = _prefs.getInt('selected_year') ?? DateTime.now().year;

    return CacheState(
      selectedCity: city,
      isFirstLaunch: isFirst,
      selectedYear: year,
    );
  }

  Future<void> setSelectedCity(String city) async {
    await _prefs.setString('selected_city', city);
    await _prefs.setBool('is_first_launch', false);
    state = AsyncData(state.value!.copyWith(selectedCity: city, isFirstLaunch: false));
  }

  Future<void> setSelectedYear(int year) async {
    await _prefs.setInt('selected_year', year);
    state = AsyncData(state.value!.copyWith(selectedYear: year));
  }
}

final cacheProvider = AsyncNotifierProvider<CacheNotifier, CacheState>(() {
  return CacheNotifier();
});
