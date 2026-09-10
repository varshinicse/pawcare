import 'package:flutter/material.dart';

import '../../models/pet_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/interactive_motion/staggered_entrance.dart';
import '../../widgets/pet_background_wrapper.dart';

class AiHealthInsightsScreen extends StatelessWidget {
  final Pet pet;

  const AiHealthInsightsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('AI Health Insights'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_avatar_luna.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 1. AI Summary Hero Card
            StaggeredEntrance(
              index: 0,
              child: JumpingCard(
                enableFloating: true,
                floatAmplitude: 2.2,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.canopy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.canopy.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.buttercreamAccent.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.buttercreamAccent, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'PAWCARE AI AGENT',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryGlow,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pistachioSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Health Score: 94/100', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${pet.name} is in Prime Health Condition 🌟',
                        style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 19),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Based on recent vitals, activity logs, and consistent feeding routines, ${pet.name} shows strong cardiovascular resilience and ideal weight trajectory.',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70, fontSize: 12.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Trend Observations Section
            StaggeredEntrance(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Behavioral & Clinical Trends', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                  const SizedBox(height: 10),
                  _buildInsightItem(
                    Icons.trending_up_rounded,
                    'Activity Level Surge (+14%)',
                    '${pet.name} averaged 55 mins of active exercise per day this week, an increase from 48 mins last week. High vitality detected.',
                    AppColors.pistachioDark,
                  ),
                  const SizedBox(height: 10),
                  _buildInsightItem(
                    Icons.scale_rounded,
                    'Stable Body Mass Index',
                    'Weight is consistently maintained within the ideal 28.0 - 28.5 kg range for a ${pet.breed}. Muscle tone is well balanced.',
                    AppColors.canopy,
                  ),
                  const SizedBox(height: 10),
                  _buildInsightItem(
                    Icons.event_available_rounded,
                    'Immunization Schedule Alert',
                    'Bordetella Kennel Cough booster is recommended in 25 days before monsoon park outings.',
                    AppColors.primaryTerracotta,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Personalized Care Suggestions
            StaggeredEntrance(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personalized Care Recommendations', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _buildSuggestionRow('1. Hydration Boost', 'Increase fresh water bowls during high temperature afternoon hours.'),
                        const Divider(height: 16, color: AppColors.dividerColor),
                        _buildSuggestionRow('2. Joint Support', 'Continue Omega-3 wild salmon oil daily with morning kibbles.'),
                        const Divider(height: 16, color: AppColors.dividerColor),
                        _buildSuggestionRow('3. Dental Routine', 'Maintain chew sessions with Pedigree Dentastix 3x per week for plaque prevention.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontSize: 13.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(description, style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: AppColors.inkText.withValues(alpha: 0.75), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionRow(String heading, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.pistachioDark, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(heading, style: AppTypography.labelMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(text, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
            ],
          ),
        ),
      ],
    );
  }
}
