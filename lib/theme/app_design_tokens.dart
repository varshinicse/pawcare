import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Spacing, Radius, Shadow, and Animation Tokens
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(18.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
}

class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double round = 999.0;

  static BorderRadius get cardSm => BorderRadius.circular(sm);
  static BorderRadius get cardMd => BorderRadius.circular(md);
  static BorderRadius get cardLg => BorderRadius.circular(lg);
  static BorderRadius get cardXl => BorderRadius.circular(xl);
  static BorderRadius get cardXxl => BorderRadius.circular(xxl);
  static BorderRadius get pill => BorderRadius.circular(round);
}

class AppShadows {
  static List<BoxShadow> get softSm => [
        BoxShadow(
          color: AppColors.canopy.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softMd => [
        BoxShadow(
          color: AppColors.canopy.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get softLg => [
        BoxShadow(
          color: AppColors.canopy.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primaryTerracotta.withValues(alpha: 0.22),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get canopyGlow => [
        BoxShadow(
          color: AppColors.canopy.withValues(alpha: 0.28),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve gentle = Curves.easeInOutCubic;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve pop = Curves.easeOutBack;
}
