import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable background wrapper that layers cute pet photography beneath
/// smooth gradient curtains and frosted tinting to guarantee 100% text readability.
class PetBackgroundWrapper extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final double imageOpacity;
  final Alignment imageAlignment;
  final Color overlayColor;
  final List<Color>? gradientColors;

  const PetBackgroundWrapper({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/cat_dog_friends.jpg',
    this.imageOpacity = 0.20,
    this.imageAlignment = Alignment.topCenter,
    this.overlayColor = AppColors.creamBase,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. High-resolution Pet Photography (Fixed Full Background)
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: imageAlignment,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),

        // 2. Soft Tint & Vignette Gradient Veil for readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors ??
                    [
                      overlayColor.withValues(alpha: 0.82),
                      overlayColor.withValues(alpha: 0.78),
                      overlayColor.withValues(alpha: 0.88),
                    ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // 3. Foreground Content
        child,
      ],
    );
  }
}
