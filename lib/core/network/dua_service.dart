import 'dart:convert';
import 'package:flutter/services.dart';

class DuaCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<DuaItem> duas;

  DuaCategory({required this.id, required this.title, required this.description, required this.icon, required this.duas});

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      duas: (json['duas'] as List).map((e) => DuaItem.fromJson(e)).toList(),
    );
  }
}

class DuaItem {
  final String id;
  final String arabic;
  final String turkish;
  final String transliteration;
  final String source;

  DuaItem({required this.id, required this.arabic, required this.turkish, required this.transliteration, required this.source});

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] ?? '',
      arabic: json['arabic'],
      turkish: json['turkish'],
      transliteration: json['transliteration'],
      source: json['source'],
    );
  }
}

class DailyDhikr {
  final String arabic;
  final String turkish;
  final String transliteration;
  final String source;

  DailyDhikr({required this.arabic, required this.turkish, required this.transliteration, required this.source});

  factory DailyDhikr.fromJson(Map<String, dynamic> json) {
    return DailyDhikr(
      arabic: json['arabic'],
      turkish: json['turkish'],
      transliteration: json['transliteration'],
      source: json['source'],
    );
  }
}

class DuaService {
  Future<List<DuaCategory>> getDuaCategories() async {
    final String response = await rootBundle.loadString('assets/data/duas.json');
    final data = await json.decode(response);
    return (data['categories'] as List).map((e) => DuaCategory.fromJson(e)).toList();
  }

  Future<DailyDhikr> getDhikrOfDay() async {
    final String response = await rootBundle.loadString('assets/data/duas.json');
    final data = await json.decode(response);
    final dhikrs = (data['dhikr_of_day'] as List).map((e) => DailyDhikr.fromJson(e)).toList();
    
    // Günü baz alarak değişen günlük zikir
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return dhikrs[dayOfYear % dhikrs.length];
  }
}
