import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/pet_model.dart';
import '../../../models/product_model.dart';
import '../../../providers/ecosystem_provider.dart';
import '../../../services/recommendation_engine.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../shop/product_detail_screen.dart';

class AiSuggestionCard extends StatefulWidget {
  final Pet? activePet;

  const AiSuggestionCard({
    super.key,
    required this.activePet,
  });

  @override
  State<AiSuggestionCard> createState() => _AiSuggestionCardState();
}

class _AiSuggestionCardState extends State<AiSuggestionCard> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed || widget.activePet == null) {
      return const SizedBox.shrink();
    }

    final pet = widget.activePet!;
    final recommendation = RecommendationEngine.getSuggestion(pet);

    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final allProducts = ecoProvider.products;

    List<MarketplaceProduct> recommendedProducts = [];
    if (recommendation.category == 'grooming') {
      recommendedProducts = allProducts.where((p) => p.category == 'grooming').toList();
    } else if (recommendation.category == 'diet') {
      recommendedProducts = allProducts.where((p) => p.category == 'food').toList();
    } else {
      recommendedProducts = allProducts.where((p) => p.category == 'medicine').toList();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mossLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.mossAccent.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.mossAccent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.mossAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI Health Insight (${recommendation.category.toUpperCase()})',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.mossAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.softTaupe,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Suggestion body text
          Text(
            recommendation.suggestion,
            style: AppTypography.displaySmall.copyWith(
              fontSize: 16,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // AI Reasoning explainability banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.mossAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Why this tip? ${recommendation.reasoning}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.inkText.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recommended Products List
          if (recommendedProducts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.dividerColor),
            const SizedBox(height: 10),
            Text(
              'Recommended Products 🛍️',
              style: AppTypography.labelLarge.copyWith(fontSize: 12, color: AppColors.mossAccent),
            ),
            const SizedBox(height: 8),
            Column(
              children: recommendedProducts.map((product) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: AppColors.clayPrimary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title, style: AppTypography.labelMedium.copyWith(fontSize: 13)),
                              Text('₹${product.price}', style: AppTypography.numericData.copyWith(color: AppColors.clayPrimary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softTaupe),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }
}
