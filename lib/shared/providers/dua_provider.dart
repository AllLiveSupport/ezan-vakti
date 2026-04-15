import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dua_service.dart';

final duaServiceProvider = Provider<DuaService>((ref) {
  return DuaService();
});

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) async {
  return ref.read(duaServiceProvider).getDuaCategories();
});

final dailyDhikrProvider = FutureProvider<DailyDhikr>((ref) async {
  return ref.read(duaServiceProvider).getDhikrOfDay();
});
