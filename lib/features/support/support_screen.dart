import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'Destek & Bağış',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Heart Icon + Animation
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.error.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 80,
                  color: AppTheme.error,
                ).animate(onPlay: (c) => c.repeat())
                 .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms, curve: Curves.easeInOut)
                 .then()
                 .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeInOut),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Gelişime Katkıda Bulunun',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Ezan Vakti tamamen ücretsizdir ve reklam içermez. Uygulamanın gelişimine destek olmak ve daha fazla özellik eklenmesine katkıda bulunmak isterseniz bir kahve ısmarlayabilirsiniz.',
              style: GoogleFonts.manrope(
                fontSize: 16,
                height: 1.6,
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // BuyMeACoffee Card
            _SupportOptionCard(
              title: 'Buy Me A Coffee',
              subtitle: 'Tek seferlik veya aylık destek olun',
              icon: Icons.coffee_rounded,
              color: const Color(0xFFFFDD00),
              iconColor: Colors.black,
              onTap: () => _launchUrl('https://buymeacoffee.com/alllivesupport'),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            _SupportOptionCard(
              title: 'Geri Bildirim Gönder',
              subtitle: 'Öneri ve hata raporları için',
              icon: Icons.code_rounded,
              color: AppTheme.primary,
              iconColor: Colors.white,
              onTap: () => _launchUrl('https://github.com/AllLiveSupport/ezan-vakti/issues'),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 48),

            // Appreciation Note
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.orange),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Desteğiniz bizim için çok değerli. Allah razı olsun.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

class _SupportOptionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color, iconColor;
  final VoidCallback onTap;

  const _SupportOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
