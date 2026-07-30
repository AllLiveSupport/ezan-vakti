import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
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
    final status = await ph.Permission.notification.status;
    return status.isGranted;
  }

  /// Bildirim izni iste
  static Future<bool> requestNotificationPermission() async {
    final status = await ph.Permission.notification.request();
    return status.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Uygulama ayarlarını aç
  static Future<void> openAppSettings() async {
    await ph.openAppSettings(); // ← permission_handler paketi fonksiyonu
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
        onRefresh: () async {
          final updated = await checkAllPermissions();
          if (updated.values.every((p) => p) && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ),
    );

    return result ?? false;
  }
}

/// İzin isteme dialogu
class _PermissionDialog extends StatefulWidget {
  final Map<String, bool> permissions;
  final VoidCallback onRefresh;

  const _PermissionDialog({
    required this.permissions,
    required this.onRefresh,
  });

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  late Map<String, bool> _perms;

  @override
  void initState() {
    super.initState();
    _perms = Map.from(widget.permissions);
  }

  Future<void> _refresh() async {
    final updated = await BatteryOptimizationService.checkAllPermissions();
    if (mounted) {
      setState(() => _perms = updated);
      if (updated.values.every((p) => p)) {
        widget.onRefresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _perms.values.every((p) => p);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.battery_alert_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Arka Plan İzinleri',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ezan vakitlerinde alarmların ve bildirimlerin telefon kilitliyken kesintisiz çalışması için lütfen aşağıdaki kısıtlamaları kaldırın:',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            icon: Icons.notifications_active_rounded,
            title: 'Bildirim İzni',
            subtitle: 'Ezan vakti bildirimleri için',
            granted: _perms['notifications'] ?? false,
            onTap: () async {
              await BatteryOptimizationService.requestNotificationPermission();
              await _refresh();
            },
          ),
          _PermissionItem(
            icon: Icons.battery_saver_rounded,
            title: 'Pil Kısıtlamasını Kaldır',
            subtitle: 'Android pil optimizasyonunu yoksay',
            granted: _perms['batteryOptimization'] ?? false,
            onTap: () async {
              await BatteryOptimizationService.requestBatteryOptimizationBypass();
              await _refresh();
            },
          ),
          _PermissionItem(
            icon: Icons.alarm_rounded,
            title: 'Tam Zamanlı Alarm',
            subtitle: 'Tam vaktinde ezan okuyabilmek için',
            granted: _perms['exactAlarms'] ?? false,
            onTap: () async {
              await BatteryOptimizationService.requestExactAlarmPermission();
              await _refresh();
            },
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
            onPressed: () async {
              if (!(_perms['notifications'] ?? false)) {
                await BatteryOptimizationService.requestNotificationPermission();
              }
              if (!(_perms['batteryOptimization'] ?? false)) {
                await BatteryOptimizationService.requestBatteryOptimizationBypass();
              }
              if (!(_perms['exactAlarms'] ?? false)) {
                await BatteryOptimizationService.requestExactAlarmPermission();
              }
              await _refresh();
            },
            child: const Text('Tüm İzinleri Ver'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tamam'),
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
  final VoidCallback onTap;

  const _PermissionItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.granted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: granted ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              granted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: granted ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: granted ? Colors.black87 : Colors.orange[900],
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (!granted)
              const Icon(Icons.chevron_right_rounded, color: Colors.orange, size: 20),
          ],
        ),
      ),
    );
  }
}
