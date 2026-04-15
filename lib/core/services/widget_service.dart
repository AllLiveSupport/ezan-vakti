import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/prayer_times_model.dart';
import '../../shared/models/city_model.dart';

class WidgetService {
  static const String androidWidgetName = 'PrayerWidgetProvider';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.ezan_vakti');
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> updateWidgetData(CityModel city, PrayerTimesModel times) async {
    final now = DateTime.now();
    final current = times.getCurrentPrayer(now);
    final next = times.getNextPrayer(now);

    final fajrStr = _formatTime(times.fajr);
    final sunriseStr = _formatTime(times.sunrise);
    final dhuhrStr = _formatTime(times.dhuhr);
    final asrStr = _formatTime(times.asr);
    final maghribStr = _formatTime(times.maghrib);
    final ishaStr = _formatTime(times.isha);

    // Save to home_widget (for Android widget)
    await HomeWidget.saveWidgetData<String>('city_name', city.name);
    await HomeWidget.saveWidgetData<String>('fajr', fajrStr);
    await HomeWidget.saveWidgetData<String>('sunrise', sunriseStr);
    await HomeWidget.saveWidgetData<String>('dhuhr', dhuhrStr);
    await HomeWidget.saveWidgetData<String>('asr', asrStr);
    await HomeWidget.saveWidgetData<String>('maghrib', maghribStr);
    await HomeWidget.saveWidgetData<String>('isha', ishaStr);
    await HomeWidget.saveWidgetData<String>('current_prayer_name', current.name);
    await HomeWidget.saveWidgetData<String>('next_prayer_name', next.name);

    // Also save to SharedPreferences for Native Foreground Service
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', city.name);
    await prefs.setString('fajr', fajrStr);
    await prefs.setString('sunrise', sunriseStr);
    await prefs.setString('dhuhr', dhuhrStr);
    await prefs.setString('asr', asrStr);
    await prefs.setString('maghrib', maghribStr);
    await prefs.setString('isha', ishaStr);

    // Widget'ı güncelle — qualifiedAndroidName: namespace (com.alllivesupport.ezanvakti) ile tanımlanmış sınıf
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      qualifiedAndroidName: 'com.alllivesupport.ezanvakti.$androidWidgetName',
    );
  }
}
