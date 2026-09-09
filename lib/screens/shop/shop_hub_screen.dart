import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_switcher_pill.dart';
import 'cart_screen.dart';
import 'orders_list_screen.dart';
import 'product_detail_screen.dart';

class ShopHubScreen extends StatefulWidget {
  const ShopHubScreen({super.key});

  @override
  State<ShopHubScreen> createState() => _ShopHubScreenState();
}

class _ShopHubScreenState extends State<ShopHubScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCartSheet(BuildContext context, EcosystemProvider ecoProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Consumer<EcosystemProvider>(
          builder: (context, provider, _) {
            final cartItems = provider.cart;
            final total = provider.cartTotal;
            final petProvider = Provider.of<PetProvider>(context, listen: false);
            final activePet = petProvider.activePet;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Pet Care Cart 🛍️', style: AppTypography.displaySmall),
                      Text('${cartItems.length} items', style: AppTypography.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (cartItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text('Your cart is empty', style: AppTypography.bodyMedium),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.dividerColor),
                      itemBuilder: (c, idx) {
                        final product = cartItems[idx];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.title, style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                                  Text('₹${product.price.toStringAsFixed(0)}', style: AppTypography.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => provider.removeSingleFromCart(product.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => provider.addToCart(product),
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  if (cartItems.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount:', style: AppTypography.labelLarge),
                        Text('₹${total.toStringAsFixed(0)}', style: AppTypography.displaySmall.copyWith(fontSize: 20, color: AppColors.primaryTerracotta)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTerracotta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () async {
                          final petId = activePet?.id ?? 'default_pet';
                          await provider.checkoutCart(petId);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully! 🐾 Your items are on the way!'),
                                backgroundColor: AppColors.pistachioSecondary,
                              ),
                            );
                          }
                        },
                        child: const Text('Checkout & Place Order'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final allProducts = ecoProvider.products;
    final cartCount = ecoProvider.cart.length;

    final filtered = allProducts.where((p) {
      final matchesSearch = _searchQuery.isEmpty || p.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'all' || p.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, ecoProvider),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Curated For Your Pet Hero Banner
                    _buildCuratedHeroBanner(cartCount, () => _showCartSheet(context, ecoProvider)),
                    const SizedBox(height: 18),

                    // 2. Search & Filter Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.dividerColor),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Search food, grooming, medicine...',
                                prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.softTaupe),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Badge(
                            label: Text(cartCount.toString()),
                            isLabelVisible: cartCount > 0,
                            backgroundColor: AppColors.alertCoral,
                            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.inkText),
                          ),
                          onPressed: () => _showCartSheet(context, ecoProvider),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const CircleBorder(),
                            side: const BorderSide(color: AppColors.dividerColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 3. Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildCategoryFilterChip('Nutrition', 'food'),
                          const SizedBox(width: 8),
                          _buildCategoryFilterChip('Accessories', 'accessories'),
                          const SizedBox(width: 8),
                          _buildCategoryFilterChip('Grooming', 'grooming'),
                          const SizedBox(width: 8),
                          _buildCategoryFilterChip('Pharma', 'medicine'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4. Products Grid Section
                    Text(
                      'JUNGLE-TESTED FAVORITES',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryTerracotta,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Recommended for your pet', style: AppTypography.displaySmall.copyWith(fontSize: 20)),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (ctx, index) {
                        final product = filtered[index];
                        return _buildProductCard(context, product, ecoProvider);
                      },
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EcosystemProvider ecoProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamBase,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Paw Store',
                style: AppTypography.displaySmall.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'My Orders',
                icon: const Icon(Icons.receipt_long_rounded, color: AppColors.canopy),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              const PetSwitcherPill(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedHeroBanner(int cartCount, VoidCallback onCartTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.canopy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/pet-care-shop.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.buttercreamAccent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Free express delivery over ₹499',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.canopy, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pawsome Essentials\nDelivered Fresh 📦',
                    style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_rounded, size: 16),
                    label: Text(cartCount > 0 ? 'View Cart ($cartCount)' : 'View Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = value),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canopy : AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppColors.canopy : AppColors.dividerColor),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.inkText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, MarketplaceProduct product, EcosystemProvider ecoProvider) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.canopy.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview & Category Tag
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.creamSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getProductIcon(product.category),
                        size: 40,
                        color: AppColors.primaryTerracotta.withValues(alpha: 0.7),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(fontSize: 12.5, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.primaryGlow),
                      const SizedBox(width: 3),
                      Text('${product.rating}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: AppTypography.displaySmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta, size: 22),
                        onPressed: () {
                          ecoProvider.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.title} to cart 🛍️'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primaryTerracotta,
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      case 'grooming':
        return Icons.brush_rounded;
      case 'medicine':
        return Icons.medical_services_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }
}
