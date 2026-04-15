// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Noor Essence Design System - "The Digital Sanctuary"
/// Light: Pure white + mint-green surfaces | Dark: Modern near-black + vivid green
class AppTheme {
  AppTheme._();

  // ─── Ana Renkler ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF237329);
  static const Color primaryDim = Color(0xFF12661E);
  static const Color primaryContainer = Color(0xFF9DF197);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF002204);

  static const Color secondary = Color(0xFF52634F);
  static const Color secondaryContainer = Color(0xFFD5E8CF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ─── Surface Hiyerarşisi (No-Line Rule) ──────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);              // Level 0: Saf beyaz
  static const Color surfaceContainerLow = Color(0xFFF0F9F0);  // Level 1: Çok hafif mint
  static const Color surfaceContainer = Color(0xFFE3F4E3);     // Level 2: Hafif yeşil
  static const Color surfaceContainerHigh = Color(0xFFD6EDD6); // Level 3: Açık yeşil
  static const Color surfaceContainerHighest = Color(0xFFC9E6C9); // Level 4: Yeşil tonu

  static const Color onSurface = Color(0xFF1C2B1C);     // Derin koyu yeşil-siyah
  static const Color onSurfaceVariant = Color(0xFF3D5C3D);
  static const Color outlineVariant = Color(0xFFB8D4B8);

  // ─── Dark Mode Renkleri (Teal Dark — Image 1 referans) ───────────────
  static const Color surfaceDark = Color(0xFF060D0C);           // Near-black, hafif teal tint
  static const Color surfaceContainerLowDark = Color(0xFF0A1514); // Çok koyu
  static const Color surfaceContainerDark = Color(0xFF111D1C);  // Kart yüzeyi
  static const Color surfaceContainerHighDark = Color(0xFF162827); // Elevated kart
  static const Color onSurfaceDark = Color(0xFFE0F4F1);         // Temiz beyaz-teal
  static const Color onSurfaceVariantDark = Color(0xFF7AB8B2);  // Orta teal
  static const Color primaryDark = Color(0xFF00C9A7);           // Canlı teal
  static const Color primaryDimDark = Color(0xFF009E84);        // Orta teal

  // ─── Beyaz Yeşil Tema Renkleri ───────────────────────────────────────
  static const Color wgSurface = Color(0xFFFFFFFF);
  static const Color wgContainerLow = Color(0xFFF7F7F7);
  static const Color wgContainer = Color(0xFFEEEEEE);
  static const Color wgContainerHigh = Color(0xFFE5E5E5);
  static const Color wgContainerHighest = Color(0xFFDADADA);
  static const Color wgOnSurface = Color(0xFF1A1A1A);
  static const Color wgOnSurfaceVariant = Color(0xFF5C5C5C);
  static const Color wgOutlineVariant = Color(0xFFCCCCCC);

  // ─── Pure Dark Tema Renkleri ────────────────────────────────────────
  static const Color pdSurface = Color(0xFF121212);
  static const Color pdContainerLow = Color(0xFF1C1C1C);
  static const Color pdContainer = Color(0xFF252525);
  static const Color pdContainerHigh = Color(0xFF2E2E2E);
  static const Color pdContainerHighest = Color(0xFF383838);
  static const Color pdOnSurface = Color(0xFFE8E8E8);
  static const Color pdOnSurfaceVariant = Color(0xFFA0A0A0);
  static const Color pdOutlineVariant = Color(0xFF3C3C3C);

  // ─── Semantik Renkler ────────────────────────────────────────────────────
  static const Color activePrayer = primary;
  static const Color inactivePrayer = surfaceContainerHighest;
  static const Color ramadanAccent = Color(0xFF8B4513); // Kahverengi/toprak tonu
  static const Color jummahAccent = Color(0xFFB91C1C);  // Cuma için kırmızı
  static const Color activeGreen = Color(0xFF4CAF50);   // Sensör / Hedef onay rengi

  // ─── Tipografi ────────────────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        // Display - Manrope: Dramatik, prayer countdown için
        displayLarge: GoogleFonts.manrope(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          letterSpacing: -2.0,
          color: onSurface,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          color: onSurface,
        ),

        // Headline - Manrope: Namaz isimleri için yetkili
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: onSurface,
        ),
        headlineSmall: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),

        // Title - Inter: Temiz, ikincil bilgi için
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: onSurface,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: onSurface,
        ),

        // Body - Inter: Yüksek okunabilirlik, geniş satır yüksekliği
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurfaceVariant,
        ),

        // Label - Inter: Büyük harf, metadata/timer için
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: onSurfaceVariant,
        ),
      );

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: Color(0xFF111F0F),
          tertiary: Color(0xFF386667),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFBBEBEC),
          onTertiaryContainer: Color(0xFF002021),
          error: error,
          onError: Color(0xFFFFFFFF),
          errorContainer: errorContainer,
          onErrorContainer: Color(0xFF410002),
          surface: surface,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          outline: Color(0xFF73756A),
          outlineVariant: outlineVariant,
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF2E3128),
          onInverseSurface: Color(0xFFF5F1E6),
          inversePrimary: primaryDark,
        ),
        textTheme: textTheme,
        scaffoldBackgroundColor: surface,
        appBarTheme: AppBarTheme(
          backgroundColor: surface.withValues(alpha: 0.85),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
          iconTheme: const IconThemeData(color: primary),
        ),
        cardTheme: CardThemeData(
          // No-Line Rule: Tonal borders yerine sadece renk farkı
          color: surfaceContainerLow,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // rounded-xl
          ),
        ),
        // Chip — Active prayer indicator
        chipTheme: ChipThemeData(
          backgroundColor: surfaceContainerHighest,
          selectedColor: primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        // ElevatedButton — Primary CTA
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999), // tam yuvarlak
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        // TextButton — Tertiary action
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
          ),
        ),
        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return onPrimary;
            return onSurfaceVariant;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primary;
            return outlineVariant;
          }),
        ),
        // Input Field — Filled style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          hintStyle: GoogleFonts.inter(
            color: onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: onSurfaceVariant,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        // Divider — Asla kullanma, ama zorunluysa çok hafif
        dividerTheme: const DividerThemeData(
          color: Colors.transparent, // No-Line Rule
          thickness: 0,
        ),
        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: onSurface,
          contentTextStyle: GoogleFonts.inter(color: surface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primary,
        ),
        // Slider (Volume control)
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          inactiveTrackColor: outlineVariant,
        ),
      );

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: Color(0xFF00201A),
          primaryContainer: Color(0xFF004A3A),
          onPrimaryContainer: Color(0xFFA8EDE1),
          secondary: Color(0xFF8AB8B4),
          onSecondary: Color(0xFF0A2522),
          secondaryContainer: Color(0xFF1A3532),
          onSecondaryContainer: Color(0xFFC0DDD9),
          tertiary: Color(0xFF7EC8C9),
          onTertiary: Color(0xFF003738),
          tertiaryContainer: Color(0xFF1B4E4F),
          onTertiaryContainer: Color(0xFFBBEBEC),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          onSurfaceVariant: onSurfaceVariantDark,
          outline: Color(0xFF3A5855),
          outlineVariant: Color(0xFF1A302E),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: surface,
          onInverseSurface: onSurface,
          inversePrimary: primary,
        ),
        textTheme: textTheme.apply(
          bodyColor: onSurfaceDark,
          displayColor: onSurfaceDark,
        ),
        scaffoldBackgroundColor: surfaceDark,
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryDark,
          ),
          iconTheme: const IconThemeData(color: primaryDark),
        ),
        cardTheme: CardThemeData(
          color: surfaceContainerDark,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: surfaceContainerHighDark,
          selectedColor: Color(0xFF0E3D35),
          shape: StadiumBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDark,
            foregroundColor: Color(0xFF00201A),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryDark),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? const Color(0xFF00201A) : onSurfaceVariantDark;
          }),
          trackColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? primaryDark : const Color(0xFF1A3430);
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceContainerHighDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryDark, width: 2),
          ),
          hintStyle: GoogleFonts.inter(color: onSurfaceVariantDark, fontSize: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: onSurfaceVariantDark,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
          thickness: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surfaceContainerHighDark,
          contentTextStyle: GoogleFonts.inter(color: onSurfaceDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryDark),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primaryDark,
          thumbColor: primaryDark,
          inactiveTrackColor: Color(0xFF1A3430),
        ),
      );

  // ─── Beyaz Yeşil Tema ─────────────────────────────────────────────────────────
  static ThemeData get whiteGreenTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: onSecondary,
          secondaryContainer: Color(0xFFDEDEDE),
          onSecondaryContainer: Color(0xFF111111),
          tertiary: Color(0xFF386667),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFBBEBEC),
          onTertiaryContainer: Color(0xFF002021),
          error: error,
          onError: Color(0xFFFFFFFF),
          errorContainer: errorContainer,
          onErrorContainer: Color(0xFF410002),
          surface: wgSurface,
          onSurface: wgOnSurface,
          onSurfaceVariant: wgOnSurfaceVariant,
          outline: Color(0xFF8C8C8C),
          outlineVariant: wgOutlineVariant,
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF2E2E2E),
          onInverseSurface: Color(0xFFF5F5F5),
          inversePrimary: primaryDark,
        ),
        textTheme: textTheme,
        scaffoldBackgroundColor: wgSurface,
        appBarTheme: AppBarTheme(
          backgroundColor: wgSurface.withValues(alpha: 0.85),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
          iconTheme: const IconThemeData(color: primary),
        ),
        cardTheme: CardThemeData(
          color: wgContainerLow,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: wgContainerHighest,
          selectedColor: primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primary),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? onPrimary : wgOnSurfaceVariant;
          }),
          trackColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? primary : wgOutlineVariant;
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: wgContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          hintStyle: GoogleFonts.inter(color: wgOnSurfaceVariant, fontSize: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: wgSurface,
          selectedItemColor: primary,
          unselectedItemColor: wgOnSurfaceVariant,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(color: Colors.transparent, thickness: 0),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: wgOnSurface,
          contentTextStyle: GoogleFonts.inter(color: wgSurface),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          inactiveTrackColor: wgOutlineVariant,
        ),
      );

  // ─── Pure Dark Tema ───────────────────────────────────────────────────────────
  static ThemeData get pureDarkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: Color(0xFF00201A),
          primaryContainer: Color(0xFF004A3A),
          onPrimaryContainer: Color(0xFFA8EDE1),
          secondary: Color(0xFF8AB8B4),
          onSecondary: Color(0xFF0A2522),
          secondaryContainer: Color(0xFF1A3532),
          onSecondaryContainer: Color(0xFFC0DDD9),
          tertiary: Color(0xFF7EC8C9),
          onTertiary: Color(0xFF003738),
          tertiaryContainer: Color(0xFF1B4E4F),
          onTertiaryContainer: Color(0xFFBBEBEC),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: pdSurface,
          onSurface: pdOnSurface,
          onSurfaceVariant: pdOnSurfaceVariant,
          outline: Color(0xFF5C5C5C),
          outlineVariant: pdOutlineVariant,
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: wgSurface,
          onInverseSurface: wgOnSurface,
          inversePrimary: primary,
        ),
        textTheme: textTheme.apply(
          bodyColor: pdOnSurface,
          displayColor: pdOnSurface,
        ),
        scaffoldBackgroundColor: pdSurface,
        appBarTheme: AppBarTheme(
          backgroundColor: pdSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryDark,
          ),
          iconTheme: const IconThemeData(color: primaryDark),
        ),
        cardTheme: CardThemeData(
          color: pdContainer,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: pdContainerHigh,
          selectedColor: Color(0xFF0E3D35),
          shape: StadiumBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDark,
            foregroundColor: Color(0xFF00201A),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryDark),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? const Color(0xFF00201A) : pdOnSurfaceVariant;
          }),
          trackColor: WidgetStateProperty.resolveWith((s) {
            return s.contains(WidgetState.selected) ? primaryDark : pdOutlineVariant;
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: pdContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryDark, width: 2),
          ),
          hintStyle: GoogleFonts.inter(color: pdOnSurfaceVariant, fontSize: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: pdSurface,
          selectedItemColor: primaryDark,
          unselectedItemColor: pdOnSurfaceVariant,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(color: Colors.transparent, thickness: 0),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: pdContainerHigh,
          contentTextStyle: GoogleFonts.inter(color: pdOnSurface),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryDark),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primaryDark,
          thumbColor: primaryDark,
          inactiveTrackColor: pdOutlineVariant,
        ),
      );

  // ─── Yardımcı Metodlar ────────────────────────────────────────────────────

  /// Hero CTA butonu için gradient (primary → primaryDim, 135°)
  static const LinearGradient heroCTAGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDim],
    stops: [0.0, 1.0],
  );

  /// Glass morphism efekti için
  static BoxDecoration glassDecoration({
    double opacity = 0.8,
    double blurRadius = 20,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: surface.withValues(alpha: opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: outlineVariant.withValues(alpha: 0.2), // Ghost Border Rule
        width: 1,
      ),
    );
  }

  /// Ambient shadow (Material 2 değil — çok yumuşak)
  static List<BoxShadow> get ambientShadow => [
        BoxShadow(
          color: onSurface.withValues(alpha: 0.08),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  /// Active prayer card decoration
  static BoxDecoration activePrayerDecoration({bool isDark = false}) {
    return BoxDecoration(
      gradient: heroCTAGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          offset: const Offset(0, 8),
          blurRadius: 20,
          spreadRadius: -2,
        ),
      ],
    );
  }
}
