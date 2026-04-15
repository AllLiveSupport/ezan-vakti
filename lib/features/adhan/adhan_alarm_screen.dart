import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alarm/alarm.dart';

class AdhanAlarmScreen extends StatefulWidget {
  final String prayerName;
  final String cityName;
  final String prayerTime;
  final int alarmId; // Ekledik: Hangi alarm çalıyor?

  const AdhanAlarmScreen({
    super.key,
    required this.prayerName,
    required this.cityName,
    required this.prayerTime,
    this.alarmId = 0,
  });

  @override
  State<AdhanAlarmScreen> createState() => _AdhanAlarmScreenState();
}

class _AdhanAlarmScreenState extends State<AdhanAlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _stopAlarm() async {
    // Alarm durdurma
    await Alarm.stop(widget.alarmId);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snoozeAlarm() async {
    // Mevcut alarmı durdur
    final currentSettings = await Alarm.getAlarm(widget.alarmId);
    await Alarm.stop(widget.alarmId);

    if (currentSettings != null) {
      // 10 dakika sonraya yeni bir alarm kur
      // Snooze ID: Orijinal ID + 10000 (Çakışma riskini minimize eder)
      final snoozeId = widget.alarmId > 10000 
          ? widget.alarmId // Zaten bir snooze ise aynı ID'yi kullan
          : widget.alarmId + 10000;

      final snoozeSettings = AlarmSettings(
        id: snoozeId,
        dateTime: DateTime.now().add(const Duration(minutes: 10)),
        assetAudioPath: currentSettings.assetAudioPath,
        loopAudio: true,
        vibrate: true,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 3),
        ),
        notificationSettings: NotificationSettings(
            title: '${widget.prayerName} (Ertelenmiş)',
            body: 'Ezan vakti 10 dakika ertelendi.',
            stopButton: 'Durdur',
            icon: 'notification_icon',
        ),
        androidFullScreenIntent: true,
      );
      
      await Alarm.set(alarmSettings: snoozeSettings);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ezan 10 dakika ertelendi'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Stack(
          children: [
            // Arka plan gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
              ),
            ),

            // İçerik
            Column(
              children: [
                const Spacer(flex: 2),

                // Başlık
                Text(
                  'Ezan Vakti',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(duration: 600.ms),

                const SizedBox(height: 40),

                // Cami ikon + nabız animasyonu
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dış halka
                        Container(
                          width: 180 + (_pulseController.value * 20),
                          height: 180 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                                alpha: 0.05 * (1 - _pulseController.value)),
                          ),
                        ),
                        // İç halka
                        Container(
                          width: 150 + (_pulseController.value * 10),
                          height: 150 + (_pulseController.value * 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                                alpha: 0.08 * (1 - _pulseController.value * 0.5)),
                          ),
                        ),
                        // Cami ikonu
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.mosque_rounded,
                            size: 70,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Vakit adı
                Text(
                  '${widget.prayerName} Vakti',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 12),

                // Saat ve şehir
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'ŞİMDİ  •  ${widget.cityName.toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const Spacer(flex: 2),

                // Durdur butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: _stopAlarm,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8BC34A),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8BC34A).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_off_rounded,
                              color: Color(0xFF1B5E20), size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Durdur',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
                ),

                const SizedBox(height: 16),

                // Ertele butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: _snoozeAlarm,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.snooze_rounded,
                              color: Colors.white70, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            '10 dk Ertele',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
