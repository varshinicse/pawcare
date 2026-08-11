import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ProductDetailScreen extends StatelessWidget {
  final MarketplaceProduct product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(product.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image / Icon container
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.dividerColor, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 100,
                    color: AppColors.clayPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.clayLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.category.toUpperCase(),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.clayPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Product Name
            Text(
              product.title,
              style: AppTypography.displayMedium,
            ),
            const SizedBox(height: 8),

            // Rating
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${product.rating} / 5.0',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Price tag
            Text(
              '₹${product.price}',
              style: AppTypography.numericData.copyWith(
                fontSize: 28,
                color: AppColors.clayPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),

            // Description Header
            Text(
              'Product Description',
              style: AppTypography.displaySmall.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Description body
            Text(
              product.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.softTaupe,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),

            // Buy / Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ecoProvider.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${product.title}" added to your cart! 🛍️'),
                      backgroundColor: AppColors.mossAccent,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
