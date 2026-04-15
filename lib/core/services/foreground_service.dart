import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ForegroundService {
  static const MethodChannel _channel =
      MethodChannel('com.alllivesupport.ezanvakti/service');

  static Future<void> start() async {
    try {
      await _channel.invokeMethod('startForegroundService');
      debugPrint('✅ Foreground service started');
    } catch (e) {
      debugPrint('❌ Failed to start foreground service: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopForegroundService');
      debugPrint('✅ Foreground service stopped');
    } catch (e) {
      debugPrint('❌ Failed to stop foreground service: $e');
    }
  }
}
