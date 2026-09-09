import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration for PawCare - Display (Fredoka) & Body (Manrope)
class AppTypography {
  // Display font: Fredoka (rounded, friendly, bold character)
  static TextStyle displayLarge = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.inkText,
    height: 1.15,
  );

  static TextStyle displayMedium = GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
    height: 1.25,
  );

  static TextStyle petNameDisplay = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.inkText,
  );

  // Body font: Manrope (modern, geometric, clean legibility)
  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.inkText,
    height: 1.45,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkText,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.softTaupe,
    height: 1.4,
  );

  static TextStyle labelLarge = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.inkText,
  );

  static TextStyle labelMedium = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.softTaupe,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.softTaupe,
    letterSpacing: 0.6,
  );

  // Data / Numerals with Tabular figures
  static TextStyle numericData = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.inkText,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

