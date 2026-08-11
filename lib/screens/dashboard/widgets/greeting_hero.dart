import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class GreetingHero extends StatelessWidget {
  final String ownerName;
  final dynamic activePet;

  const GreetingHero({
    super.key,
    required this.ownerName,
    this.activePet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sub-pill badge at top center
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.creamSurface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.clayPrimary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'AI-powered care for 500+ species worldwide',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.clayPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Header Text (Centered)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTypography.displayMedium.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.inkText,
                height: 1.25,
              ),
              children: const [
                TextSpan(text: 'PetReminder AI: AI-Powered Care Reminders for '),
                TextSpan(
                  text: 'Every Pet Worldwide',
                  style: TextStyle(color: Color(0xFF5D9CEC)), // Nice blue color matching screenshot
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Row of Emojis (Centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🐶', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('🐱', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('🐦', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('🐢', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('🐟', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('🐹', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 18),

          // Subtitle description (Centered)
          Text(
            'Tailor-made schedules, family sync, fun rewards, and smart shopping—all in one app for dogs, cats, birds, reptiles, fish, and exotics.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.softTaupe,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Horizontal scroll of pet categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryCard('🐶', 'Dogs', '200+ breeds'),
                const SizedBox(width: 12),
                _buildCategoryCard('🐱', 'Cats', '100+ breeds'),
                const SizedBox(width: 12),
                _buildCategoryCard('🐦', 'Birds', '50+ species'),
                const SizedBox(width: 12),
                _buildCategoryCard('🐢', 'Reptiles', '30+ species'),
                const SizedBox(width: 12),
                _buildCategoryCard('🐟', 'Fish', '100+ species'),
                const SizedBox(width: 12),
                _buildCategoryCard('🐹', 'Small Pets', '20+ types'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String subtitle) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.creamBase,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.softTaupe),
          ),
        ],
      ),
    );
  }
}
