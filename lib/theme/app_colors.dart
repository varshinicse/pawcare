import 'package:flutter/material.dart';

/// PawCare Design Tokens - Warm, playful, companion-like palette
class AppColors {
  // Core palette specified in design requirements
  static const Color creamBase = Color(0xFFFBF6EF); // Main background, warm and soft
  static const Color clayPrimary = Color(0xFFE17A47); // Primary terracotta-orange
  static const Color mossAccent = Color(0xFF6B8F71); // Secondary accent for healthy/completed
  static const Color inkText = Color(0xFF2B2420); // Primary text, warm near-black
  static const Color softTaupe = Color(0xFFA69C8F); // Secondary text / muted labels
  static const Color alertCoral = Color(0xFFE85D4A); // Urgent/medication reminders

  // Supporting tones for UI hierarchy (glassmorphism / soft cards / chips)
  static const Color cardBg = Color(0xFFFFFFFF); // Pure card surface
  static const Color creamSurface = Color(0xFFF4ECE1); // Soft inset background
  static const Color clayLight = Color(0xFFFBECE4); // Clay tint for badges / highlights
  static const Color mossLight = Color(0xFFEAF2EB); // Moss tint for success pills
  static const Color alertLight = Color(0xFFFCEBE9); // Alert tint for overdue cards
  static const Color dividerColor = Color(0xFFEAE2D8); // Subtle warm divider
  static const Color navBarBg = Color(0xFF332B25); // Dark warm charcoal for floating nav bar
}
