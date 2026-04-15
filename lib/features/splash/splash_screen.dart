// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback: Activity RESUMED durumuna geçtikten sonra çalıştır
    // initState içinde doğrudan çağırmak permission dialog'u engelleyebilir
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToNext());
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    // Prefs okuma ve animasyonu paralel yap — toplam bekleme süresi azalır
    final prefsResult = SharedPreferences.getInstance();

    // Android 13+ bildirim izni — Activity RESUMED olduğundan dialog görünür
    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted) {
      await Permission.notification.request();
    }

    // Konum izni iste ve konumu al (Cami bulucu için hazır olsun)
    await _requestAndCacheLocation();

    // Splash görsel süresi (animasyon için minimum)
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (!mounted) return;

    final prefs = await prefsResult;
    final isFirstLaunch = prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;
    final hasCity = prefs.getString(AppConstants.keySelectedCityId) != null;

    if (!mounted) return;

    if (isFirstLaunch || !hasCity) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// Konum izni iste ve alınan konumu SharedPreferences'a kaydet
  /// Cami bulucu ekranında anında gösterilmek üzere
  Future<void> _requestAndCacheLocation() async {
    try {
      // Önce konum servisi açık mı kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Konum servisi kapalı, splash konum atlanıyor');
        return;
      }

      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('📍 Konum izni reddedildi');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 Konum izni kalıcı olarak reddedildi');
        return;
      }

      // İzin var, konumu al (hızlı, yaklaşık konum yeterli)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Hızlı almak için low
          timeLimit: Duration(seconds: 5),  // 5 saniyede timeout
        ),
      );

      // Konumu kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('splash_cached_lat', position.latitude);
      await prefs.setDouble('splash_cached_lon', position.longitude);
      await prefs.setInt('splash_cached_at', DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('📍 Splash konum kaydedildi: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('📍 Splash konum alma hatası: $e');
      // Hata olsa bile devam et, cami bulucu kendi almaya çalışır
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      body: Stack(
        children: [
          // Arka Plan Motifleri (Görsel referanstaki soft çiçeksi şekiller)
          Positioned(
            top: -100,
            left: -50,
            child: _buildBackgroundCircle(300, AppTheme.primaryContainer.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBackgroundCircle(250, AppTheme.primaryContainer.withValues(alpha: 0.15)),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (Daire içinde Cami ikonu)
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mosque_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),

                const SizedBox(height: 48),

                // Başlık
                Text(
                  'Ezan Vakti',
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                // Slogan
                Text(
                  'YOUR DIGITAL SANCTUARY',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 64),

                // Yükleme Animasyonu (Noktalı Loading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .scale(
                        duration: 600.ms,
                        delay: (index * 200).ms,
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.5, 1.5),
                        curve: Curves.easeInOut,
                      )
                     .then()
                     .scale(duration: 600.ms, begin: const Offset(1.5, 1.5), end: const Offset(1.0, 1.0));
                  }),
                ),

                const SizedBox(height: 16),

                Text(
                  'LOADING PEACE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),

          // Alt Hijri Bilgisi
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '1445 Hijri',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SPIRITUAL FOCUS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
