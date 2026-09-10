import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'interactive_motion/floating_bubble.dart';

/// Jungle Canopy Hero Card with interactive motion, floating ambient particles,
/// and smooth tactile response.
class JungleHeroCard extends StatefulWidget {
  final Pet pet;
  final String userName;
  final VoidCallback onAddReminder;
  final VoidCallback onViewHealth;

  const JungleHeroCard({
    super.key,
    required this.pet,
    required this.userName,
    required this.onAddReminder,
    required this.onViewHealth,
  });

  @override
  State<JungleHeroCard> createState() => _JungleHeroCardState();
}

class _JungleHeroCardState extends State<JungleHeroCard> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petName = widget.pet.name.isNotEmpty ? widget.pet.name : 'Your Pet';
    final isCat = widget.pet.species.toLowerCase() == 'cat' || petName.toLowerCase() == 'luna';
    final assetImage = isCat ? 'assets/images/cat_avatar_luna.jpg' : 'assets/images/dog_avatar_bruno.jpg';

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 280),
        decoration: BoxDecoration(
          color: AppColors.canopy,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.canopy.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.pistachioSecondary.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: FloatingAmbientParticles(
            count: 7,
            particleColor: AppColors.buttercreamAccent,
            child: Stack(
              children: [
                // Background Photography
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.45,
                    child: Image.asset(
                      assetImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/bruno-jungle.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (_, __, ___) => _buildFallbackPattern(),
                      ),
                    ),
                  ),
                ),
                // Gradient Shade Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.canopy.withValues(alpha: 0.96),
                          AppColors.canopy.withValues(alpha: 0.70),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Live Cloud Status Pill with Glassmorphism
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded, size: 14, color: AppColors.pistachioSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Care trail on track • Live Cloud 🐾',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Greeting Eyebrow
                      Text(
                        'GOOD MORNING, ${widget.userName.toUpperCase()}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryGlow,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Display Heading
                      Text(
                        '$petName is ready for a wild day.',
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'One supplement, a sunset brush, and plenty of tail-wagging adventure ahead for $petName.',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Action Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.onAddReminder,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('Add reminder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTerracotta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 2,
                              textStyle: AppTypography.labelLarge.copyWith(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: widget.onViewHealth,
                            icon: const Icon(Icons.favorite_border_rounded, size: 16, color: Colors.white),
                            label: const Text('View health'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              textStyle: AppTypography.labelLarge.copyWith(fontSize: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPattern() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.pistachioSecondary.withValues(alpha: 0.2),
            Colors.transparent,
          ],
          radius: 0.8,
          center: Alignment.topRight,
        ),
      ),
    );
  }
}
