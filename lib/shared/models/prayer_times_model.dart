// lib/shared/models/prayer_times_model.dart
import 'package:intl/intl.dart';

/// 6 vakit modeli (İmsak, Sabah, Güneş, Öğle, İkindi, Akşam, Yatsı)
class PrayerTimesModel {
  final String cityId;
  final DateTime date;
  final DateTime imsak;  // İmsak vakti (Kerahat başlangıcı)
  final DateTime fajr;   // Sabah vakti (Namaz başlangıcı)
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String hijriDate;
  final String calculationMethod;
  final DateTime fetchedAt;
  
  /// Kullanıcı ayarlarından gelen ofsetler (İmsak, Sabah, Güneş, Öğle, İkindi, Akşam, Yatsı)
  final List<int> offsets;

  const PrayerTimesModel({
    required this.cityId,
    required this.date,
    required this.imsak,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.calculationMethod,
    required this.fetchedAt,
    this.offsets = const [0, 0, 0, 0, 0, 0, 0],
  });

  /// AlAdhan API JSON'undan parse et
  factory PrayerTimesModel.fromAlAdhanJson({
    required String cityId,
    required Map<String, dynamic> json,
    required String calculationMethod,
    List<int> offsets = const [0, 0, 0, 0, 0, 0],
  }) {
    final timings = json['timings'] as Map<String, dynamic>;
    final dateData = json['date'] as Map<String, dynamic>;
    final hijri = dateData['hijri'] as Map<String, dynamic>;

    final date =
        DateFormat('dd-MM-yyyy').parse(dateData['gregorian']['date'] as String);

    return PrayerTimesModel(
      cityId: cityId,
      date: date,
      imsak: _parseTime(timings['Imsak'] as String? ?? timings['Fajr'] as String, date),
      fajr: _parseTime(timings['Fajr'] as String, date),
      sunrise: _parseTime(timings['Sunrise'] as String, date),
      dhuhr: _parseTime(timings['Dhuhr'] as String, date),
      asr: _parseTime(timings['Asr'] as String, date),
      maghrib: _parseTime(timings['Maghrib'] as String, date),
      isha: _parseTime(timings['Isha'] as String, date),
      hijriDate:
          '${hijri['day']} ${hijri['month']['en']} ${hijri['year']} AH',
      calculationMethod: calculationMethod,
      fetchedAt: DateTime.now(),
      offsets: offsets,
    );
  }

  factory PrayerTimesModel.fromAdhanDart({
    required String cityId,
    required DateTime date,
    required DateTime imsak,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    String hijriDate = '',
    List<int> offsets = const [0, 0, 0, 0, 0, 0, 0],
  }) {
    return PrayerTimesModel(
      cityId: cityId,
      date: date,
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      hijriDate: hijriDate,
      calculationMethod: 'Turkey (Offline)',
      fetchedAt: DateTime.now(),
      offsets: offsets,
    );
  }

  static DateTime _parseTime(String timeStr, DateTime date) {
    final clean = timeStr.split(' ').first.trim();
    final parts = clean.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Ofset uygulanmış vakitler listesi
  List<DateTime> get adjustedTimes => [
    imsak.add(Duration(minutes: offsets[0])),
    fajr.add(Duration(minutes: offsets[1])),
    sunrise.add(Duration(minutes: offsets[2])),
    dhuhr.add(Duration(minutes: offsets[3])),
    asr.add(Duration(minutes: offsets[4])),
    maghrib.add(Duration(minutes: offsets[5])),
    isha.add(Duration(minutes: offsets[6])),
  ];

  ({String name, DateTime time, int index}) getNextPrayer(DateTime now) {
    final adjusted = adjustedTimes;
    final names = ['İmsak', 'Sabah', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];

    for (int i = 0; i < adjusted.length; i++) {
      if (now.isBefore(adjusted[i])) {
        return (name: names[i], time: adjusted[i], index: i);
      }
    }
    // Yarınki İmsak
    return (name: 'İmsak', time: adjusted[0].add(const Duration(days: 1)), index: 0);
  }

  ({String name, int index}) getCurrentPrayer(DateTime now) {
    final adjusted = adjustedTimes;
    if (now.isBefore(adjusted[0])) return (name: 'Yatsı', index: 6);
    if (now.isBefore(adjusted[1])) return (name: 'İmsak', index: 0);
    if (now.isBefore(adjusted[2])) return (name: 'Sabah', index: 1);
    if (now.isBefore(adjusted[3])) return (name: 'Güneş Vakti', index: 2);
    if (now.isBefore(adjusted[4])) return (name: 'Öğle', index: 3);
    if (now.isBefore(adjusted[5])) return (name: 'İkindi', index: 4);
    if (now.isBefore(adjusted[6])) return (name: 'Akşam', index: 5);
    return (name: 'Yatsı', index: 6);
  }

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  List<({String name, DateTime time, int index})> get allPrayers {
    final adjusted = adjustedTimes;
    return [
      (name: 'İmsak', time: adjusted[0], index: 0),
      (name: 'Sabah', time: adjusted[1], index: 1),
      (name: 'Güneş', time: adjusted[2], index: 2),
      (name: 'Öğle', time: adjusted[3], index: 3),
      (name: 'İkindi', time: adjusted[4], index: 4),
      (name: 'Akşam', time: adjusted[5], index: 5),
      (name: 'Yatsı', time: adjusted[6], index: 6),
    ];
  }

  DateTime get sahur => adjustedTimes[0]; // Adjusted Fajr
  DateTime get iftar => adjustedTimes[4]; // Adjusted Maghrib

  bool get isCacheValid {
    return DateTime.now().difference(fetchedAt).inHours < 24;
  }

  @override
  String toString() =>
      'PrayerTimes($cityId, ${DateFormat('dd.MM.yyyy').format(date)}, '
      'Fajr: ${formatTime(fajr)}, Isha: ${formatTime(isha)})';
}

