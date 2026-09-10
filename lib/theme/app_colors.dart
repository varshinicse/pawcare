import 'package:flutter/material.dart';

/// PawCare Design Tokens - Inspired by the Lush Jungle Canopy & Warm Earth palette
class AppColors {
  // Canopy & Forest Tokens
  static const Color canopy = Color(0xFF1B3D2F); // Deep lush evergreen / forest canopy
  static const Color canopyDark = Color(0xFF132E23); // Deeper canopy shade
  static const Color canopyLight = Color(0xFF265340); // Slightly brighter canopy
  static const Color canopySurface = Color(0xFF173529);

  // Terracotta & Warm Coral Tokens
  static const Color primaryTerracotta = Color(0xFFE0533C); // Warm terracotta-coral primary
  static const Color terracottaDark = Color(0xFFC0392B);
  static const Color terracottaLight = Color(0xFFFFECE8);
  static const Color primaryGlow = Color(0xFFFBBF24); // Warm amber glow / accents

  // Pistachio & Sage Green
  static const Color pistachioSecondary = Color(0xFF88C999); // Soft pistachio sage green
  static const Color pistachioDark = Color(0xFF1C422B); // Deep forest green for text on pistachio
  static const Color pistachioLight = Color(0xFFE8F5EB);

  // Buttercream & Warm Sand
  static const Color buttercreamAccent = Color(0xFFF5E6CC); // Warm buttercream accent card
  static const Color buttercreamDark = Color(0xFF2C3E2D); // Deep olive text for buttercream
  static const Color buttercreamLight = Color(0xFFFCF7EE);

  // Core background & surfaces
  static const Color creamBase = Color(0xFFF7F5EE); // Main background (warm oatmeal/linen)
  static const Color cardBg = Color(0xFFFFFFFF); // Clean white card background
  static const Color cardBgElevated = Color(0xFFFCFCFA);
  static const Color creamSurface = Color(0xFFF0EBE1); // Inset container background
  static const Color inkText = Color(0xFF1C2D27); // Deep forest charcoal text
  static const Color softTaupe = Color(0xFF7A8B84); // Muted secondary text
  static const Color lightTaupe = Color(0xFFA5B4AE); // Subtle placeholder text
  static const Color dividerColor = Color(0xFFE6E2D8); // Subtle warm border
  static const Color shimmerBase = Color(0xFFEAE6DC);
  static const Color shimmerHighlight = Color(0xFFF8F6F0);

  // Semantic states
  static const Color alertCoral = Color(0xFFDC2626); // Urgent alert / delete
  static const Color alertLight = Color(0xFFFEE2E2); // Alert tint
  static const Color successGreen = Color(0xFF16A34A); // Success
  static const Color successLight = Color(0xFFDCFCE7); // Success tint
  static const Color warningAmber = Color(0xFFD97706); // Warning
  static const Color warningLight = Color(0xFFFEF3C7); // Warning tint
  static const Color infoBlue = Color(0xFF0284C7); // Info
  static const Color infoLight = Color(0xFFE0F2FE); // Info tint

  // Gradients
  static const LinearGradient canopyGradient = LinearGradient(
    colors: [Color(0xFF1B3D2F), Color(0xFF122B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient terracottaGradient = LinearGradient(
    colors: [Color(0xFFE0533C), Color(0xFFD3432B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmSunGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF1E4334), Color(0xFF142F24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassOverlayGradient = LinearGradient(
    colors: [Colors.white24, Colors.white10],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backward-compatible aliases
  static const Color clayPrimary = primaryTerracotta;
  static const Color mossAccent = pistachioSecondary;
  static const Color clayLight = terracottaLight;
  static const Color mossLight = pistachioLight;
  static const Color navBarBg = canopy;
}


