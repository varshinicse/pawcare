import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_background_wrapper.dart';
import 'cart_screen.dart';

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
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'View Cart',
            icon: Badge(
              label: Text(ecoProvider.cart.length.toString()),
              isLabelVisible: ecoProvider.cart.isNotEmpty,
              backgroundColor: AppColors.alertCoral,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.canopy,
                      side: const BorderSide(color: AppColors.canopy, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      ecoProvider.addToCart(product);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${product.title}" added to cart! 🛍️'),
                          backgroundColor: AppColors.mossAccent,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ecoProvider.addToCart(product);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    child: const Text('Buy Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/pet_feeding_routine.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container
            Center(
              child: Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: product.imagePath.startsWith('assets/')
                              ? Image.asset(
                                  product.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.shopping_bag_rounded,
                                      size: 100,
                                      color: AppColors.clayPrimary,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.shopping_bag_rounded,
                                    size: 100,
                                    color: AppColors.clayPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (product.discountPercent > 0)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.alertCoral,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.discountPercent}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Brand & Category Pills
            Row(
              children: [
                if (product.brand.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.buttercreamAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.brand.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.canopy,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.clayLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.clayPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pistachioSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.petType == 'dog'
                        ? '🐶 Dog'
                        : product.petType == 'cat'
                            ? '🐱 Cat'
                            : '🐾 All Pets',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Title
            Text(
              product.title,
              style: AppTypography.displayMedium.copyWith(fontSize: 20, height: 1.25),
            ),
            const SizedBox(height: 10),

            // Rating & Reviews Count
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.mossAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.mossAccent, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.mossAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${product.reviewsCount} verified ratings',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Price tag & MRP
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: AppTypography.numericData.copyWith(
                    fontSize: 26,
                    color: AppColors.inkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (product.originalPrice > product.price) ...[
                  const SizedBox(width: 8),
                  Text(
                    '₹${product.originalPrice.toStringAsFixed(0)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.softTaupe,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save ₹${(product.originalPrice - product.price).toStringAsFixed(0)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.pistachioDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Supertails Express Delivery banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.buttercreamAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.canopy, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Supertails Super Express 🚀', style: AppTypography.labelLarge.copyWith(fontSize: 12)),
                        Text('Order within 2 hrs for delivery by tomorrow morning', style: AppTypography.bodySmall.copyWith(fontSize: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description Header
            Text(
              'About this item',
              style: AppTypography.displaySmall.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Description body
            Text(
              product.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.inkText.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Features Checklist
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  _buildFeatureRow(Icons.verified_outlined, '100% Authentic Supertails product guarantee'),
                  const Divider(height: 16, color: AppColors.dividerColor),
                  _buildFeatureRow(Icons.local_shipping_outlined, 'Free shipping on orders above ₹499'),
                  const Divider(height: 16, color: AppColors.dividerColor),
                  _buildFeatureRow(Icons.replay_rounded, 'Easy 7-day replacement for damaged items'),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryTerracotta),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.inkText),
          ),
        ),
      ],
    );
  }
}
