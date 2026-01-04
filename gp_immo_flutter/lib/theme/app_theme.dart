import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color ink = Color(0xFF101828);
  static const Color ocean = Color(0xFF1E6F6D);
  static const Color coral = Color(0xFFE37A5C);
  static const Color sand = Color(0xFFF4EFE8);
  static const Color cloud = Color(0xFFFDFBF7);
  static const Color gold = Color(0xFFF2C469);

  static ThemeData lightTheme() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: ocean,
      onPrimary: Colors.white,
      secondary: coral,
      onSecondary: Colors.white,
      error: Color(0xFFBF2A2A),
      onError: Colors.white,
      background: sand,
      onBackground: ink,
      surface: cloud,
      onSurface: ink,
    );

    final base = ThemeData.light().textTheme;
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base).copyWith(
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      bodySmall: GoogleFonts.workSans(
        fontWeight: FontWeight.w400,
        color: ink.withOpacity(0.7),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: sand,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: cloud,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ocean,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ocean,
          side: const BorderSide(color: ocean, width: 1.2),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sand,
        selectedColor: gold,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ocean,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        borderRadius: BorderRadius.circular(14),
        selectedColor: Colors.white,
        fillColor: ocean,
        textStyle: textTheme.labelLarge,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cloud,
        selectedItemColor: ocean,
        unselectedItemColor: Color(0xFF667085),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
