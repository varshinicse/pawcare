import 'package:flutter/material.dart';

/// PawCare Design Tokens - Inspired by the Lush Jungle Canopy & Warm Earth palette
class AppColors {
  // Canopy & Earth Tokens
  static const Color canopy = Color(0xFF1B3D2F); // Deep lush evergreen / forest canopy
  static const Color canopyDark = Color(0xFF132E23); // Deeper canopy shade
  static const Color primaryTerracotta = Color(0xFFE0533C); // Warm terracotta-coral primary
  static const Color primaryGlow = Color(0xFFFBBF24); // Warm amber glow / accents
  static const Color pistachioSecondary = Color(0xFF88C999); // Soft pistachio sage green
  static const Color pistachioDark = Color(0xFF1C422B); // Deep forest green for text on pistachio
  static const Color buttercreamAccent = Color(0xFFF5E6CC); // Warm buttercream accent card
  static const Color buttercreamDark = Color(0xFF2C3E2D); // Deep olive text for buttercream

  // Core background & surfaces
  static const Color creamBase = Color(0xFFF7F5EE); // Main background (warm oatmeal/linen)
  static const Color cardBg = Color(0xFFFFFFFF); // Clean white card background
  static const Color creamSurface = Color(0xFFF0EBE1); // Inset container background
  static const Color inkText = Color(0xFF1C2D27); // Deep forest charcoal text
  static const Color softTaupe = Color(0xFF7A8B84); // Muted secondary text
  static const Color dividerColor = Color(0xFFE6E2D8); // Subtle warm border

  // Semantic states
  static const Color alertCoral = Color(0xFFDC2626); // Urgent alert / delete
  static const Color alertLight = Color(0xFFFEE2E2); // Alert tint
  static const Color successGreen = Color(0xFF16A34A); // Success
  static const Color successLight = Color(0xFFDCFCE7); // Success tint

  // Backward-compatible aliases
  static const Color clayPrimary = primaryTerracotta;
  static const Color mossAccent = pistachioSecondary;
  static const Color clayLight = Color(0xFFFCEAE6);
  static const Color mossLight = Color(0xFFE8F5EB);
  static const Color navBarBg = canopy;
}

