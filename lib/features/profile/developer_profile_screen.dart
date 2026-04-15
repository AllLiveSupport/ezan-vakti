import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Profile Pic
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppTheme.primary,
                        AppTheme.secondary,
                      ],
                    ),
                  ),
                ),
                // Decorative Path
                Positioned(
                  top: -20,
                  right: -20,
                  child: Icon(
                    Icons.code_rounded,
                    size: 200,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                // Profile Avatar
                Transform.translate(
                  offset: const Offset(0, 50),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppTheme.surfaceDark : AppTheme.surface, width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/148607928.jpg',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 140,
                          height: 140,
                          color: Colors.white,
                          child: const Icon(Icons.person_rounded, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // Name and Title
            Text(
              'Mehmet Ali Balavuver',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.primary,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
            
            Text(
              'Mobil Geliştirici & Açık Kaynak Gönüllüsü',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 32),

            // Bio Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'Tutkulu bir mobil geliştirici ve açık kaynak gönüllüsü. Maneviyatı dijital dünyayla harmanlayarak, insanların iç huzuruna katkı sunacak çözümler üretiyorum.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 32),

            // Social Links
            _SocialButton(
              title: 'LinkedIn',
              icon: Icons.link_rounded,
              color: const Color(0xFF0077B5),
              onTap: () => _launchUrl('https://www.linkedin.com/in/mehmetalibalavuver/'),
            ).animate(delay: 700.ms).fadeIn().slideX(begin: -0.2, end: 0),
            
            _SocialButton(
              title: 'GitHub',
              icon: Icons.code_rounded,
              color: isDark ? Colors.white : Colors.black,
              onTap: () => _launchUrl('https://github.com/AllLiveSupport'),
            ).animate(delay: 800.ms).fadeIn().slideX(begin: 0.2, end: 0),

            const SizedBox(height: 16),
            
            // Support Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => _launchUrl('https://buymeacoffee.com/alllivesupport'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDD00),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleType.rounded.borderRadius(20),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.coffee_rounded),
                    const SizedBox(width: 12),
                    Text(
                      'Bir Kahve Ismarla',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.5, end: 0),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleType.rounded.borderRadius(16),
        tileColor: color.withValues(alpha: 0.1),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: color),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

extension on RoundedRectangleType {
  RoundedRectangleBorder borderRadius(double r) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
}
enum RoundedRectangleType { rounded }
