import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/providers/prayer_provider.dart';

class AlarmSettingsScreen extends ConsumerWidget {
  const AlarmSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prayerNames = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Alarm ve Bildirimler', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: settingsAsync.when(
        data: (settings) => prayerTimesAsync.when(
          data: (times) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: prayerNames.length + 1,
            separatorBuilder: (context, index) => index == 0
                ? const SizedBox(height: 8)
                : const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) return const _PermissionBanner();
              final i = index - 1;
              final prayerName = prayerNames[i];
              final prayerTime = _getPrayerTime(times, i);
              final adhanEnabled = settings.prayerAdhanEnabled[i];
              final notifEnabled = settings.prayerNotifEnabled[i];
              final offset = settings.prayerOffsets[i];

              return _AlarmCard(
                index: i,
                name: prayerName,
                time: times?.formatTime(prayerTime) ?? '--:--',
                adhanEnabled: adhanEnabled,
                notifEnabled: notifEnabled,
                offset: offset,
                isDark: isDark,
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  DateTime _getPrayerTime(dynamic times, int index) {
    if (times == null) return DateTime.now();
    switch (index) {
      case 0: return times.fajr;
      case 1: return times.sunrise;
      case 2: return times.dhuhr;
      case 3: return times.asr;
      case 4: return times.maghrib;
      case 5: return times.isha;
      default: return DateTime.now();
    }
  }
}

class _AlarmCard extends ConsumerWidget {
  final int index;
  final String name;
  final String time;
  final bool adhanEnabled;
  final bool notifEnabled;
  final int offset;
  final bool isDark;

  const _AlarmCard({
    required this.index,
    required this.name,
    required this.time,
    required this.adhanEnabled,
    required this.notifEnabled,
    required this.offset,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildPrayerIcon(index),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name, 
                        style: GoogleFonts.manrope(
                          fontSize: 18, 
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        time, 
                        style: GoogleFonts.inter(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Offset', 
                      style: GoogleFonts.inter(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                    Text(
                      '${offset > 0 ? "+" : ""}$offset dk', 
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_time_rounded, 
                    size: 20,
                    color: isDark ? Colors.white70 : AppTheme.onSurfaceVariant,
                  ),
                  onPressed: () => _showOffsetDialog(context, ref),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildToggle(
                  label: 'Ezan',
                  icon: Icons.volume_up_rounded,
                  value: adhanEnabled,
                  isDark: isDark,
                  onChanged: (val) => ref.read(settingsProvider.notifier).updatePrayerAdhan(index, val),
                ),
                _buildToggle(
                  label: 'Bildirim',
                  icon: Icons.notifications_active_rounded,
                  value: notifEnabled,
                  isDark: isDark,
                  onChanged: (val) => ref.read(settingsProvider.notifier).updatePrayerNotif(index, val),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildPrayerIcon(int index) {
    IconData icon;
    Color color;
    switch (index) {
      case 0: icon = Icons.nights_stay_rounded; color = Colors.indigo; break;
      case 1: icon = Icons.wb_sunny_rounded; color = Colors.orange; break;
      case 2: icon = Icons.wb_sunny_rounded; color = Colors.amber; break;
      case 3: icon = Icons.wb_twilight_rounded; color = Colors.deepOrange; break;
      case 4: icon = Icons.wb_twilight_rounded; color = Colors.redAccent; break;
      case 5: icon = Icons.nightlight_round_rounded; color = Colors.blueGrey; break;
      default: icon = Icons.timer; color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildToggle({
    required String label,
    required IconData icon,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: value ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? AppTheme.primary : (isDark ? Colors.white30 : Colors.grey.withValues(alpha: 0.3))),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: value ? AppTheme.primary : (isDark ? Colors.white54 : Colors.grey)),
            const SizedBox(width: 8),
            Text(
              label, 
              style: GoogleFonts.inter(
                fontSize: 13, 
                fontWeight: FontWeight.w600, 
                color: value ? AppTheme.primary : (isDark ? Colors.white70 : Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Custom Switch looks
            Container(
              width: 32,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value ? AppTheme.primary : (isDark ? Colors.white30 : Colors.grey.withValues(alpha: 0.3)),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOffsetDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$name Uyarısı', 
              style: GoogleFonts.manrope(
                fontSize: 20, 
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vakit gelmeden önce veya sonra alarm kurun.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [-30, -15, -10, -5, 0, 5, 10, 15, 30].map((m) => ChoiceChip(
                label: Text(
                  '${m > 0 ? "+" : ""}$m dk',
                  style: TextStyle(
                    color: offset == m 
                      ? (isDark ? Colors.black : Colors.white) 
                      : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                selected: offset == m,
                backgroundColor: isDark ? Colors.white24 : Colors.grey[200],
                selectedColor: AppTheme.primary,
                onSelected: (val) {
                  ref.read(settingsProvider.notifier).updatePrayerOffset(index, m);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Android 12+ exact alarm ve pil optimizasyonu izin uyarı banner'ı
class _PermissionBanner extends StatefulWidget {
  const _PermissionBanner();

  @override
  State<_PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends State<_PermissionBanner> with WidgetsBindingObserver {
  bool _exactAlarmOk = true;
  bool _notifOk = true;
  bool _fullScreenOk = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kullanıcı ayarlardan dönünce izinleri tekrar kontrol et
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final info = await DeviceInfoPlugin().androidInfo;
    bool exactOk = true;
    if (info.version.sdkInt >= 31) {
      exactOk = await Permission.scheduleExactAlarm.isGranted;
    }
    final notifOk = await Permission.notification.isGranted;

    // Android 14+ tam ekran alarm izni kontrolü
    bool fullScreenOk = true;
    try {
      const channel = MethodChannel('com.alllivesupport.ezanvakti/battery');
      fullScreenOk = await channel.invokeMethod<bool>('canUseFullScreenIntent') ?? true;
    } catch (_) {
      fullScreenOk = true;
    }

    if (mounted) {
      setState(() {
        _exactAlarmOk = exactOk;
        _notifOk = notifOk;
        _fullScreenOk = fullScreenOk;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final issues = [
      if (!_notifOk) _Issue(
        icon: Icons.notifications_off_rounded,
        text: 'Bildirim izni verilmemiş',
        onTap: () async {
          await Permission.notification.request();
          _checkPermissions();
        },
      ),
      if (!_exactAlarmOk) _Issue(
        icon: Icons.alarm_off_rounded,
        text: 'Kesin alarm izni gerekli (Android 12+)',
        onTap: () async {
          await Permission.scheduleExactAlarm.request();
          _checkPermissions();
        },
      ),
      if (!_fullScreenOk) _Issue(
        icon: Icons.fullscreen_rounded,
        text: 'Tam ekran alarm izni gerekli — "Durdur" butonu ve kilit ekranı alarmı için',
        onTap: () async {
          try {
            const channel = MethodChannel('com.alllivesupport.ezanvakti/battery');
            await channel.invokeMethod('requestFullScreenIntentPermission');
          } catch (_) {}
        },
      ),
    ];

    if (issues.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text('İzin Uyarıları',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          ...issues.map((issue) => InkWell(
            onTap: issue.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Icon(issue.icon, color: Colors.orange, size: 15),
                const SizedBox(width: 8),
                Expanded(child: Text(issue.text,
                    style: const TextStyle(fontSize: 12))),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.orange),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

class _Issue {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _Issue({required this.icon, required this.text, required this.onTap});
}
