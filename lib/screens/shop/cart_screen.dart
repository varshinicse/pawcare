import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_background_wrapper.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final cartItems = ecoProvider.cart;
    final subtotal = ecoProvider.cartTotal;
    const deliveryFee = 0.0; // Free delivery threshold
    final total = subtotal + deliveryFee;

    // Group items by product for quantity display
    final Map<String, List<MarketplaceProduct>> grouped = {};
    for (var item in cartItems) {
      grouped.putIfAbsent(item.id, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('My Cart (${cartItems.length}) 🛒'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.alertCoral),
              onPressed: () => ecoProvider.clearCart(),
            ),
        ],
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount', style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
                        Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 22,
                            color: AppColors.canopy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTerracotta,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  items: cartItems,
                                  subtotal: subtotal,
                                  deliveryFee: deliveryFee,
                                  total: total,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_avatar_luna.jpg',
        imageOpacity: 0.12,
        child: cartItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.softTaupe),
                      const SizedBox(height: 16),
                      Text('Your Cart is Empty', style: AppTypography.displaySmall.copyWith(fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(
                        'Explore nutritious pet food, accessories, and grooming essentials in our Shop.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.canopy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Start Shopping'),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ITEMS LIST
                  Text('CART ITEMS', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                  const SizedBox(height: 12),
                  ...grouped.entries.map((entry) {
                    final item = entry.value.first;
                    final quantity = entry.value.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.clayLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryTerracotta, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${item.price.toStringAsFixed(0)} each',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // QUANTITY CONTROLS
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.creamSurface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16, color: AppColors.canopy),
                                    onPressed: () => ecoProvider.removeSingleFromCart(item.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16, color: AppColors.canopy),
                                    onPressed: () => ecoProvider.addToCart(item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // PRICE SUMMARY
                  Text('PRICE SUMMARY', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Items Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
                        const SizedBox(height: 10),
                        _buildRow('Standard Express Delivery', 'FREE'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                            Text(
                              '₹${total.toStringAsFixed(0)}',
                              style: AppTypography.displaySmall.copyWith(
                                fontSize: 20,
                                color: AppColors.canopy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
