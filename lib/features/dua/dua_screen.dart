import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/dua_provider.dart';
import '../../core/network/dua_service.dart';

class DuaScreen extends ConsumerWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);
    final dhikrAsync = ref.watch(dailyDhikrProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dualar & Zikirler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).top + 80),
          ),

          // Günün Zikri
          SliverToBoxAdapter(
            child: dhikrAsync.when(
              data: (dhikr) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _DailyDhikrCard(dhikr: dhikr),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const SizedBox.shrink(),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 24, top: 24, bottom: 12),
              child: Text(
                'KATEGORİLER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          categoriesAsync.when(
            data: (categories) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CategoryCard(category: categories[index]),
                  childCount: categories.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => const SliverFillRemaining(child: Center(child: Text('Dualar yüklenemedi'))),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─── Günün Zikri Card ─────────────────────────────────────────────────────────
class _DailyDhikrCard extends StatelessWidget {
  final DailyDhikr dhikr;
  const _DailyDhikrCard({required this.dhikr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'GÜNÜN ZİKRİ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            dhikr.arabic,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 26,
              height: 1.7,
              color: Colors.white,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Text(
            dhikr.transliteration,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dhikr.turkish,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              dhikr.source,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final DuaCategory category;
  const _CategoryCard({required this.category});

  IconData _getIcon() {
    switch (category.icon) {
      case 'sunrise': return Icons.wb_twilight_rounded;
      case 'sunset': return Icons.wb_sunny_outlined;
      case 'moon': return Icons.nights_stay_rounded;
      case 'mosque': return Icons.mosque_rounded;
      case 'airplane': return Icons.flight_takeoff_rounded;
      case 'heart': return Icons.favorite_rounded;
      case 'noon': return Icons.light_mode_rounded;
      case 'afternoon': return Icons.wb_cloudy_outlined;
      case 'night': return Icons.dark_mode_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'friday': return Icons.people_rounded;
      case 'quran': return Icons.menu_book_rounded;
      default: return Icons.auto_stories_rounded;
    }
  }

  Color _getAccentColor() {
    switch (category.icon) {
      case 'sunrise': return const Color(0xFFFF8C42);
      case 'sunset': return const Color(0xFFFF6B6B);
      case 'moon': return const Color(0xFF6C63FF);
      case 'mosque': return AppTheme.primary;
      case 'airplane': return const Color(0xFF4ECDC4);
      case 'heart': return const Color(0xFFFF6B6B);
      case 'noon': return const Color(0xFFFFC857);
      case 'afternoon': return const Color(0xFF45B7D1);
      case 'night': return const Color(0xFF2C3E50);
      case 'food': return const Color(0xFF27AE60);
      case 'friday': return AppTheme.primary;
      default: return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _getAccentColor();
    final textColor = isDark ? Colors.white : AppTheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuaCategoryDetailScreen(category: category),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getIcon(), color: accent, size: 24),
              ),
              const Spacer(),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${category.duas.length} dua',
                style: TextStyle(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Detail Screen ───────────────────────────────────────────────────
class DuaCategoryDetailScreen extends StatelessWidget {
  final DuaCategory category;
  const DuaCategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(category.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: category.duas.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _DuaCard(
          dua: category.duas[index],
          index: index,
          allDuas: category.duas,
        ),
      ),
    );
  }
}

// ─── Dua Card ────────────────────────────────────────────────────────────────
class _DuaCard extends StatefulWidget {
  final DuaItem dua;
  final int index;
  final List<DuaItem> allDuas;
  const _DuaCard({required this.dua, required this.index, required this.allDuas});

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(
      text: '${widget.dua.arabic}\n\n${widget.dua.transliteration}\n\n${widget.dua.turkish}\n\n${widget.dua.source}',
    ));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.onSurface;
    final subTextColor = isDark ? Colors.white70 : AppTheme.onSurfaceVariant;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : AppTheme.surfaceContainerLow;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuaReaderScreen(
              duas: widget.allDuas,
              initialIndex: widget.index,
            ),
          ),
        ),
        child: Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.primary.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text
          Text(
            widget.dua.arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 22,
              height: 1.8,
              color: isDark ? const Color(0xFF4CAF50) : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          // Transliteration
          Text(
            widget.dua.transliteration,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: subTextColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          // Turkish meaning
          Text(
            widget.dua.turkish,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Footer
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.dua.source,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF4CAF50) : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _copy,
                child: Icon(
                  _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                  size: 20,
                  color: _copied ? Colors.green : subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ─── Dua Reader Screen ────────────────────────────────────────────────────────
class DuaReaderScreen extends StatefulWidget {
  final List<DuaItem> duas;
  final int initialIndex;
  const DuaReaderScreen({super.key, required this.duas, required this.initialIndex});

  @override
  State<DuaReaderScreen> createState() => _DuaReaderScreenState();
}

class _DuaReaderScreenState extends State<DuaReaderScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _copyDua(DuaItem dua) {
    Clipboard.setData(ClipboardData(
      text: '${dua.arabic}\n\n${dua.transliteration}\n\n${dua.turkish}\n\n${dua.source}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dua kopyalandı'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? AppTheme.surfaceDark : const Color(0xFFF8FBF8);
    final onSurfaceColor = isDark ? AppTheme.onSurfaceDark : AppTheme.onSurface;
    final mutedColor = isDark ? AppTheme.onSurfaceVariantDark : AppTheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.duas.length}',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: mutedColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => _copyDua(widget.duas[_currentIndex]),
            tooltip: 'Kopyala',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.duas.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final dua = widget.duas[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              dua.source,
                              style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Arapça — büyük, sağdan sola
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          dua.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            fontSize: 28,
                            height: 2.0,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'OKUNUŞU',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: mutedColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dua.transliteration,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.7,
                          color: onSurfaceColor,
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: primary.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),

                      Text(
                        'ANLAMI',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: mutedColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dua.turkish,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Alt navigasyon
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: _currentIndex > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut)
                        : null,
                    style: IconButton.styleFrom(
                      backgroundColor: _currentIndex > 0
                          ? primary.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      foregroundColor: _currentIndex > 0 ? primary : Colors.grey,
                    ),
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: LinearProgressIndicator(
                        value: widget.duas.isEmpty
                            ? 0
                            : (_currentIndex + 1) / widget.duas.length,
                        backgroundColor: primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _currentIndex < widget.duas.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut)
                        : null,
                    style: IconButton.styleFrom(
                      backgroundColor: _currentIndex < widget.duas.length - 1
                          ? primary.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      foregroundColor: _currentIndex < widget.duas.length - 1 ? primary : Colors.grey,
                    ),
                    icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
