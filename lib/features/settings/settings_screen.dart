import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/settings_provider.dart';
import '../../core/services/battery_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        data: (settings) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            
            // Hesaplama Yöntemi
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Builder(builder: (bCtx) {
                  final isDark = Theme.of(bCtx).brightness == Brightness.dark;
                  return _SettingsCard(
                  title: 'Hesaplama Yöntemi',
                  icon: Icons.calculate_outlined,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: settings.calculationMethod,
                      dropdownColor: isDark ? AppTheme.surfaceContainerHighDark : AppTheme.surfaceContainerHigh,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'Turkey', child: Text('Diyanet İşleri Başkanlığı (TR)')),
                        DropdownMenuItem(value: 'MWL', child: Text('Muslim World League')),
                        DropdownMenuItem(value: 'Makkah', child: Text('Umm Al-Qura / Mekke (SA)')),
                        DropdownMenuItem(value: 'ISNA', child: Text('ISNA (Kuzey Amerika)')),
                        DropdownMenuItem(value: 'Egypt', child: Text('Mısır Genel Otoritesi')),
                        DropdownMenuItem(value: 'Karachi', child: Text('İslam Bilimleri Üniversitesi (PK)')),
                        DropdownMenuItem(value: 'Tehran', child: Text('Tahran Üniversitesi (IR)')),
                        DropdownMenuItem(value: 'Kuwait', child: Text('Kuveyt')),
                        DropdownMenuItem(value: 'Qatar', child: Text('Katar')),
                        DropdownMenuItem(value: 'Singapore', child: Text('Singapur MUIS')),
                        DropdownMenuItem(value: 'JAKIM', child: Text('Malezya JAKIM')),
                        DropdownMenuItem(value: 'France', child: Text('Fransa UOIF')),
                        DropdownMenuItem(value: 'Gulf', child: Text('Körfez Bölgesi')),
                        DropdownMenuItem(value: 'Morocco', child: Text('Fas')),
                        DropdownMenuItem(value: 'Indonesia', child: Text('Endonezya KEMENAG')),
                        DropdownMenuItem(value: 'Russia', child: Text('Rusya')),
                      ],
                      onChanged: (val) async {
                        if (val != null) {
                          await ref.read(settingsProvider.notifier).updateCalculationMethod(val);
                        }
                      },
                    ),
                  ),
                );
                }),
              ),
            ),

            // İkindi Mezhep
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Builder(builder: (bCtx) {
                  final isDark = Theme.of(bCtx).brightness == Brightness.dark;
                  return _SettingsCard(
                  title: 'İkindi (Asr) Mezhebi',
                  icon: Icons.access_time_filled_outlined,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: settings.madhab,
                      dropdownColor: isDark ? AppTheme.surfaceContainerHighDark : AppTheme.surfaceContainerHigh,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'Shafii', child: Text('Şafii, Maliki, Hanbeli (1x gölge)')),
                        DropdownMenuItem(value: 'Hanafi', child: Text('Hanefi (2x gölge)')),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(settingsProvider.notifier).updateMadhab(val);
                      },
                    ),
                  ),
                );
                }),
              ),
            ),

            // Tema Ayarı
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Builder(builder: (ctx) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  final dropBg = isDark
                      ? AppTheme.surfaceContainerHighDark
                      : AppTheme.surfaceContainerHigh;
                  return _SettingsCard(
                    title: 'Renk Teması',
                    icon: Icons.palette_outlined,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AppThemeVariant>(
                        isExpanded: true,
                        value: settings.themeVariant,
                        dropdownColor: dropBg,
                        style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        items: const [
                          DropdownMenuItem(value: AppThemeVariant.system,     child: Text('Sistem Teması')),
                          DropdownMenuItem(value: AppThemeVariant.whiteGreen,  child: Text('Açık')),
                          DropdownMenuItem(value: AppThemeVariant.pureDark,    child: Text('Koyu')),
                        ],
                        onChanged: (val) {
                          if (val != null) ref.read(settingsProvider.notifier).updateThemeVariant(val);
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Cami Veri Kaynağı Ayarı
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _SettingsCard(
                  title: 'Cami Verisi Kaynağı',
                  icon: Icons.mosque_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Online seçeneği
                      _DataSourceOption(
                        value: 'online',
                        groupValue: settings.mosqueDataSource,
                        icon: Icons.cloud_outlined,
                        title: 'Online (OpenStreetMap)',
                        subtitle: 'Canlı ve güncel veri · GPS koordinatlı · İnternet gerektirir',
                        onChanged: (v) => ref.read(settingsProvider.notifier).updateMosqueDataSource(v),
                      ),
                      const Divider(height: 8),
                      // Local seçeneği
                      _DataSourceOption(
                        value: 'local',
                        groupValue: settings.mosqueDataSource,
                        icon: Icons.storage_outlined,
                        title: 'Yerel Veritabanı (Offline • 90.524 Cami)',
                        subtitle: 'Çevrimdışı Türkiye cami rehberi · İnternet gerektirmez',
                        onChanged: (v) => ref.read(settingsProvider.notifier).updateMosqueDataSource(v),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cami Arama Mesafesi (Yarıçap)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Builder(builder: (bCtx) {
                  final isDark = Theme.of(bCtx).brightness == Brightness.dark;
                  return _SettingsCard(
                    title: 'Cami Arama Mesafesi (Yarıçap)',
                    icon: Icons.radar_outlined,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: settings.mosqueSearchRadiusKm,
                        dropdownColor: isDark ? AppTheme.surfaceContainerHighDark : AppTheme.surfaceContainerHigh,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 km (Çok Yakın Çevre)')),
                          DropdownMenuItem(value: 2, child: Text('2 km (Yakın Mahalle)')),
                          DropdownMenuItem(value: 3, child: Text('3 km (Bölgesel)')),
                          DropdownMenuItem(value: 5, child: Text('5 km (Şehir İçi • Varsayılan)')),
                          DropdownMenuItem(value: 10, child: Text('10 km (Geniş Bölge)')),
                          DropdownMenuItem(value: 15, child: Text('15 km (Tüm İlçe/Şehir)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(settingsProvider.notifier).updateMosqueSearchRadiusKm(val);
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Geliştirici ve Destek (Premium Section)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _MenuActionTile(
                      title: 'Alarm ve Bildirimler',
                      subtitle: 'Ezan ve uyarı ayarları',
                      icon: Icons.alarm_on_rounded,
                      onTap: () => Navigator.pushNamed(context, '/alarms'),
                    ),
                    const SizedBox(height: 12),
                    _MenuActionTile(
                      title: 'Pil Optimizasyonu ve İzinler',
                      subtitle: 'Arka planda kesintisiz ezan için pil kısıtlamasını kaldır',
                      icon: Icons.battery_saver_rounded,
                      iconColor: Colors.orange[800],
                      onTap: () => BatteryOptimizationService.requestAllPermissions(context),
                    ),
                    const SizedBox(height: 12),
                    _MenuActionTile(
                      title: 'Geliştirici Hakkında',
                      subtitle: 'Mehmet Ali Balavuver',
                      icon: Icons.person_pin_rounded,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    const SizedBox(height: 12),
                    _MenuActionTile(
                      title: 'Destek ve Bağış',
                      subtitle: 'Uygulamayı destekle',
                      icon: Icons.favorite_rounded,
                      iconColor: AppTheme.error,
                      onTap: () => Navigator.pushNamed(context, '/support'),
                    ),
                  ],
                ),
              ),
            ),

            // Uygulama Hakkında - versiyon, lisans, GitHub
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _AppInfoFooter(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(child: Text('Ayarlar yüklenemedi.')),
      ),
    );
  }
}

// ─── Cami Veri Kaynağı Seçenek Satırı ────────────────────────────────────
class _DataSourceOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String title;
  final String subtitle;
  final ValueChanged<String> onChanged;

  const _DataSourceOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: isSelected ? AppTheme.primary : Theme.of(context).colorScheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.primary : null,
                          )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          )),
                ],
              ),
            ),
            // Seçim göstergesi (Radio yerine basit daire)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuActionTile extends StatelessWidget {

  final String title, subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _MenuActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
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

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainer;
    final borderColor = isDark
        ? AppTheme.onSurfaceVariantDark.withValues(alpha: 0.2)
        : AppTheme.onSurfaceVariant.withValues(alpha: 0.2);
    return Container(
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AppInfoFooter extends StatelessWidget {
  const _AppInfoFooter();

  Future<void> _openGitHub() async {
    final uri = Uri.parse('https://github.com/AllLiveSupport/ezan-vakti');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? Colors.white38 : Colors.black38;
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque_rounded, size: 14, color: AppTheme.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              'Ezan Vakti  v1.0.1',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subColor),
            ),
            Text('  •  MIT Lisans', style: TextStyle(fontSize: 12, color: subColor)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openGitHub,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code_rounded, size: 13, color: AppTheme.primary.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text(
                'github.com/AllLiveSupport/ezan-vakti',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.primary.withValues(alpha: 0.8),
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Harita © OpenStreetMap  •  © 2026 AllLiveSupport',
          style: TextStyle(fontSize: 10, color: subColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
