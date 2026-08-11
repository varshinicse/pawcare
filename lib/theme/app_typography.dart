import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration for PawCare
class AppTypography {
  // Display font: Fredoka (rounded, friendly)
  static TextStyle displayLarge = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
    height: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
    height: 1.25,
  );

  static TextStyle displaySmall = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
    height: 1.3,
  );

  static TextStyle petNameDisplay = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
  );

  // Body font: Inter (clean, readable, tabular figures for data)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.inkText,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkText,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.softTaupe,
    height: 1.4,
  );

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.softTaupe,
    letterSpacing: 0.5,
  );

  // Data / Numerals with Tabular figures
  static TextStyle numericData = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.inkText,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
