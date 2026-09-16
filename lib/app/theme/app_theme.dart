import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// App theme for the Retro Japanese Minimalist aesthetic.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.indigo,
        surface: AppColors.cream,
        onSurface: AppColors.indigo,
        primary: AppColors.indigo,
        onPrimary: AppColors.cream,
        secondary: AppColors.wasabi,
        onSecondary: AppColors.cream,
        error: AppColors.crimson,
        onError: AppColors.cream,
      ),

      // Typography — Andika for headings, Cutive Mono for body labels
      textTheme: TextTheme(
        displayLarge: GoogleFonts.andika(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.indigo,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.andika(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.indigo,
        ),
        headlineLarge: GoogleFonts.andika(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.indigo,
        ),
        headlineMedium: GoogleFonts.andika(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.indigo,
        ),
        headlineSmall: GoogleFonts.andika(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.indigo,
        ),
        titleLarge: GoogleFonts.andika(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.indigo,
        ),
        titleMedium: GoogleFonts.andika(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.indigo,
        ),
        bodyLarge: GoogleFonts.andika(
          fontSize: 16,
          color: AppColors.indigo,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.andika(
          fontSize: 14,
          color: AppColors.indigoLight,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.andika(
          fontSize: 12,
          color: AppColors.indigoLight,
        ),
        labelLarge: GoogleFonts.cutiveMono(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.indigo,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.cutiveMono(
          fontSize: 12,
          color: AppColors.indigoLight,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.cutiveMono(
          fontSize: 10,
          color: AppColors.indigoLight,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.indigo,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.andika(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.indigo,
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.indigo,
        foregroundColor: AppColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.indigo, width: 1.5),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.wasabi, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.andika(
          color: AppColors.indigoLight.withValues(alpha: 0.5),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.creamDark,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.indigo,
        contentTextStyle: GoogleFonts.andika(
          color: AppColors.cream,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
      ),
    );
  }
}
