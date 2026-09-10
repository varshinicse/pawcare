import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A premium glassmorphic frosted glass container with gradient borders,
/// subtle blur, backdrop filtering, and ambient lighting reflections.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final List<Color>? borderGradientColors;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.65,
    this.borderRadius,
    this.padding,
    this.margin,
    this.tintColor,
    this.borderGradientColors,
    this.borderWidth = 1.2,
    this.shadows,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    final baseTint = tintColor ?? Colors.white;

    final borderColors = borderGradientColors ??
        [
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.15),
          AppColors.primaryTerracotta.withValues(alpha: 0.2),
        ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.canopy.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: baseTint.withValues(alpha: opacity),
              borderRadius: br,
              border: Border.all(
                color: borderColors.first,
                width: borderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseTint.withValues(alpha: opacity + 0.15),
                  baseTint.withValues(alpha: opacity),
                  baseTint.withValues(alpha: (opacity - 0.1).clamp(0.0, 1.0)),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
