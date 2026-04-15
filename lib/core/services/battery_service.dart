import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Pil optimizasyonu bypass servisi
/// Bildirimlerin kesintisiz çalışması için gerekli izinleri yönetir
class BatteryOptimizationService {
  static const MethodChannel _channel = MethodChannel('com.alllivesupport.ezanvakti/battery');
  static late SharedPreferences _prefs;
  
  static const String _kBatteryOptBypassed = 'battery_opt_bypassed';
  static const String _kExactAlarmAllowed = 'exact_alarm_allowed';

  /// Servisi başlat
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BATTERY OPTIMIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pil optimizasyonu atlatıldı mı?
  static Future<bool> isBatteryOptimizationBypassed() async {
    if (!Platform.isAndroid) return true;
    
    // Önce shared preferences kontrol et
    final bypassed = _prefs.getBool(_kBatteryOptBypassed);
    if (bypassed != null) return bypassed;

    // Platform channel ile kontrol et
    try {
      final result = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      final isIgnored = result ?? false;
      await _prefs.setBool(_kBatteryOptBypassed, isIgnored);
      return isIgnored;
    } catch (e) {
      debugPrint('Battery optimization check error: $e');
      return false;
    }
  }

  /// Pil optimizasyon ayarlarını aç
  static Future<void> requestBatteryOptimizationBypass() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('requestBatteryOptimizationIgnore');
      // Kullanıcı ayarlara gidip döndükten sonra kontrol et
      final isIgnored = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored') ?? false;
      await _prefs.setBool(_kBatteryOptBypassed, isIgnored);
    } catch (e) {
      debugPrint('Battery optimization request error: $e');
      // Manuel ayarlara yönlendir
      await openBatteryOptimizationSettings();
    }
  }

  /// Pil optimizasyonu ayar sayfasını aç
  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
    } catch (e) {
      debugPrint('Open battery settings error: $e');
      // Fallback: Genel ayarlar
      await openAppSettings();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXACT ALARM (Android 12+)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Kesin alarm izni var mı? (Android 12+)
  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    
    // Android 12+ (API 31+) kontrolü
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt < 31) return true;

    // Önce cache kontrolü
    final allowed = _prefs.getBool(_kExactAlarmAllowed);
    if (allowed != null) return allowed;

    // Platform channel ile kontrol
    try {
      final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      final canSchedule = result ?? false;
      await _prefs.setBool(_kExactAlarmAllowed, canSchedule);
      return canSchedule;
    } catch (e) {
      debugPrint('Exact alarm check error: $e');
      return false;
    }
  }

  /// Kesin alarm izni iste
  static Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      debugPrint('Exact alarm request error: $e');
    }
  }

  /// Alarm ayarları sayfasını aç
  static Future<void> openAlarmSettings() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('openAlarmSettings');
    } catch (e) {
      debugPrint('Open alarm settings error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Bildirim izni var mı?
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Bildirim izni iste
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Uygulama ayarlarını aç
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Tüm gerekli izinlerin durumunu kontrol et
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'notifications': await hasNotificationPermission(),
      'batteryOptimization': await isBatteryOptimizationBypassed(),
      'exactAlarms': await canScheduleExactAlarms(),
    };
  }

  /// Tüm izinleri tek seferde iste (dialog göster)
  static Future<bool> requestAllPermissions(BuildContext context) async {
    final permissions = await checkAllPermissions();
    
    if (permissions.values.every((p) => p)) return true;

    if (!context.mounted) return false;

    // Dialog göster ve kullanıcıdan izin iste
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PermissionDialog(
        permissions: permissions,
        onRequest: () async {
          // Bildirim izni
          if (!permissions['notifications']!) {
            await requestNotificationPermission();
          }
          if (context.mounted) Navigator.of(context).pop(true);
        },
      ),
    );

    return result ?? false;
  }
}

/// İzin isteme dialogu
class _PermissionDialog extends StatelessWidget {
  final Map<String, bool> permissions;
  final VoidCallback onRequest;

  const _PermissionDialog({
    required this.permissions,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final allGranted = permissions.values.every((p) => p);
    
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.green),
          SizedBox(width: 12),
          Text('Bildirim İzinleri'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ezan vakitlerinde kesintisiz bildirim alabilmek için aşağıdaki ayarları yapmanız gerekli:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            icon: Icons.notifications,
            title: 'Bildirim İzni',
            granted: permissions['notifications']!,
          ),
          _PermissionItem(
            icon: Icons.battery_full,
            title: 'Pil Optimizasyonu',
            granted: permissions['batteryOptimization']!,
            subtitle: 'Uygulamanın arka planda çalışması için gerekli',
          ),
          _PermissionItem(
            icon: Icons.alarm,
            title: 'Kesin Alarm',
            granted: permissions['exactAlarms']!,
            subtitle: 'Tam vakitte bildirim için gerekli',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Daha Sonra'),
        ),
        if (!allGranted)
          FilledButton(
            onPressed: onRequest,
            child: const Text('İzinleri Ver'),
          ),
      ],
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool granted;

  const _PermissionItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.granted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
