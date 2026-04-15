import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationHelpScreen extends StatelessWidget {
  const NotificationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları Yardım'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Xiaomi MIUI Uyarısı
            _buildWarningCard(
              icon: Icons.warning_amber_rounded,
              title: 'Xiaomi / Redmi / POCO Telefonlar',
              subtitle: 'MIUI sistem bildirimleri kısıtlıyor. Aşağıdaki adımları uygulayın.',
              color: Colors.orange,
            ),
            
            const SizedBox(height: 24),
            
            // Adım 1
            _buildStep(
              number: 1,
              title: 'Bildirim İzni',
              description: 'Ayarlar > Uygulamalar > Ezan Vakti > Bildirimler',
              subSteps: [
                'Tüm bildirimlere izin ver',
                'Kilit ekranında göster',
                'Başlangıçta çalıştır',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Adım 2
            _buildStep(
              number: 2,
              title: 'Pil Optimizasyonu (ÖNEMLİ!)',
              description: 'Ayarlar > Uygulamalar > Ezan Vakti > Pil',
              subSteps: [
                'Pil kısıtlaması yok',
                'Arka planda çalışmaya izin ver',
                'Otomatik başlatmayı aç',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Adım 3
            _buildStep(
              number: 3,
              title: 'Güvenlik Uygulaması',
              description: 'Güvenlik uygulaması > Hızlandırıcı > Ezan Vakti',
              subSteps: [
                'Kilitle (Hafıza temizlemeye karşı koruma)',
                'Temizleme listesinden çıkar',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Diğer markalar
            _buildBrandSection(),
            
            const SizedBox(height: 24),
            
            // Test butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _testNotification(context),
                icon: const Icon(Icons.notifications_active),
                label: const Text('TEST BİLDİRİMİ GÖNDER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required List<String> subSteps,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...subSteps.map((step) => Padding(
            padding: const EdgeInsets.only(left: 44, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBrandSection() {
    final brands = [
      ('Samsung', 'Ayarlar > Bakım > Pil > Arka planda kullanım kısıtlaması > Ezan Vakti > Kısıtlama yok'),
      ('Huawei', 'Ayarlar > Uygulamalar > Ezan Vakti > Pil > Arka planda çalışmaya izin ver'),
      ('OPPO / realme', 'Ayarlar > Pil > Uygulama güç tüketimi > Ezan Vakti > Arka planda çalışmaya izin ver'),
      ('OnePlus', 'Ayarlar > Uygulamalar > Ezan Vakti > Pil optimizasyonu > Kısıtlama yok'),
      ('Google Pixel', 'Ayarlar > Uygulamalar > Ezan Vakti > Pil > Arka planda çalışmaya izin ver'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diğer Markalar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...brands.map((brand) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                brand.$1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    brand.$2,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _testNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test bildirimi gönderildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
