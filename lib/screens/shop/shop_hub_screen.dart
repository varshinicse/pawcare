import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/interactive_motion/staggered_entrance.dart';
import '../../widgets/pet_background_wrapper.dart';
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
  final _pageController = PageController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedBrand = 'all';
  String _sortBy = 'popular'; // 'popular', 'price_asc', 'price_desc', 'rating'
  final Set<String> _wishlistIds = {};

  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  Timer? _flashTimer;
  Duration _flashSaleRemaining = const Duration(hours: 3, minutes: 42, seconds: 18);

  final List<Map<String, String>> _heroBanners = [
    {
      'tag': '⚡ SUPERTAILS MEGA SALE',
      'title': 'Up to 40% OFF on Top Pet Food & Chews',
      'subtitle': 'Royal Canin, Farmina, Pedigree & more',
      'code': 'Use code: SUPERPET',
      'bgImage': 'assets/images/pet-care-shop.jpg',
    },
    {
      'tag': '💊 PET PHARMACY EXPRESS',
      'title': '100% Genuine Vet-Approved Meds',
      'subtitle': 'Ticks, Flea sprays, Dewormers & Supplements',
      'code': 'Free delivery above ₹499',
      'bgImage': 'assets/images/bruno-jungle.jpg',
    },
    {
      'tag': '🎾 PLAY & COMFORT FEST',
      'title': 'Buy 2 Get 1 Free on KONG & Plush Toys',
      'subtitle': 'Beds, Leashes, Bowls & Smart Collars',
      'code': 'Extra ₹150 OFF with code PLAYTIME',
      'bgImage': 'assets/images/pets-community.jpg',
    },
  ];

  final List<Map<String, dynamic>> _quickRoundels = [
    {'label': 'Dog Food', 'category': 'food', 'petType': 'dog', 'icon': '🐶'},
    {'label': 'Cat Food', 'category': 'food', 'petType': 'cat', 'icon': '🐱'},
    {'label': 'Pharmacy', 'category': 'medicine', 'petType': 'all', 'icon': '💊'},
    {'label': 'Treats', 'category': 'treats', 'petType': 'all', 'icon': '🍖'},
    {'label': 'Grooming', 'category': 'grooming', 'petType': 'all', 'icon': '🛁'},
    {'label': 'Toys', 'category': 'toys', 'petType': 'all', 'icon': '🎾'},
    {'label': 'Accessories', 'category': 'accessories', 'petType': 'all', 'icon': '🎒'},
    {'label': 'Flash Deals', 'category': 'flash', 'petType': 'all', 'icon': '⚡'},
  ];

  final List<String> _topBrands = [
    'All Brands',
    'Royal Canin',
    'Pedigree',
    'Whiskas',
    'Farmina',
    'KONG',
    'Boltz',
    'Drools',
    'Sheba',
    'Himalaya',
    'Captain Zack',
    'Wiggles',
  ];

  @override
  void initState() {
    super.initState();

    // Auto rotate banners
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final next = (_currentBannerIndex + 1) % _heroBanners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    // Flash sale countdown timer
    _flashTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _flashSaleRemaining.inSeconds > 0) {
        setState(() {
          _flashSaleRemaining = _flashSaleRemaining - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _flashTimer?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleWishlist(String productId) {
    setState(() {
      if (_wishlistIds.contains(productId)) {
        _wishlistIds.remove(productId);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            duration: Duration(milliseconds: 900),
          ),
        );
      } else {
        _wishlistIds.add(productId);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to wishlist ❤️'),
            duration: Duration(milliseconds: 900),
            backgroundColor: AppColors.alertCoral,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final allProducts = ecoProvider.products;
    final cartItems = ecoProvider.cart;
    final cartCount = cartItems.length;
    final cartTotal = ecoProvider.cartTotal;

    // Filter logic
    var filtered = allProducts.where((p) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);

      bool matchesCat = true;
      if (_selectedCategory == 'all') {
        matchesCat = true;
      } else if (_selectedCategory == 'dog') {
        matchesCat = p.petType.toLowerCase() == 'dog' || p.petType.toLowerCase() == 'all';
      } else if (_selectedCategory == 'cat') {
        matchesCat = p.petType.toLowerCase() == 'cat' || p.petType.toLowerCase() == 'all';
      } else if (_selectedCategory == 'flash') {
        matchesCat = p.discountPercent >= 20;
      } else {
        matchesCat = p.category.toLowerCase() == _selectedCategory.toLowerCase();
      }

      bool matchesBrand = true;
      if (_selectedBrand != 'all' && _selectedBrand != 'All Brands') {
        matchesBrand = p.brand.toLowerCase() == _selectedBrand.toLowerCase();
      }

      return matchesSearch && matchesCat && matchesBrand;
    }).toList();

    // Sort logic
    if (_sortBy == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'discount') {
      filtered.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    }

    final flashSaleProducts = allProducts.where((p) => p.discountPercent >= 20).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/pet_feeding_routine.jpg',
        imageOpacity: 0.10,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                // 1. Supertails Delivery Location & Brand Bar
                _buildSupertailsHeader(context, ecoProvider),

                // 2. Scrollable Supertails Shop
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 10,
                      bottom: cartCount > 0 ? 80 : 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        _buildSearchBar(),
                        const SizedBox(height: 12),

                        // Supertails Roundels / Category Avatars
                        _buildRoundelsSection(),
                        const SizedBox(height: 14),

                        // Promotional Hero Carousel
                        _buildHeroCarousel(),
                        const SizedBox(height: 16),

                        // Flash Deals / Lightning Timer Rail
                        _buildFlashDealsSection(flashSaleProducts, ecoProvider),
                        const SizedBox(height: 16),

                        // Brand Spotlights Rail
                        _buildBrandSpotlights(),
                        const SizedBox(height: 16),

                        // Supertails Category Filter Chips & Sort Dropdown
                        _buildCategoryFilterRow(),
                        const SizedBox(height: 12),

                        // Catalog Header with Count
                        _buildCatalogHeader(filtered.length),
                        const SizedBox(height: 10),

                        // Product Grid (30 items)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 185,
                            childAspectRatio: 0.54,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (ctx, index) {
                            final product = filtered[index];
                            final qty = cartItems.where((p) => p.id == product.id).length;
                            final isWishlisted = _wishlistIds.contains(product.id);

                            return StaggeredEntrance(
                              index: index < 10 ? index : 10,
                              child: JumpingCard(
                                enableFloating: true,
                                floatAmplitude: (index % 3 == 0) ? 2.2 : ((index % 3 == 1) ? 1.6 : 2.8),
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                                  );
                                },
                                child: _buildSupertailsProductCard(
                                  context,
                                  product,
                                  ecoProvider,
                                  qty,
                                  isWishlisted,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. Floating Cart Bottom Bar (Supertails style)
            if (cartCount > 0)
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: _buildFloatingCartBar(context, cartCount, cartTotal),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSupertailsHeader(BuildContext context, EcosystemProvider ecoProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Supertails Brand Logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59), // Supertails Yellow
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFDE59).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pets_rounded, size: 16, color: Color(0xFF1E1E1E)),
                        const SizedBox(width: 4),
                        Text(
                          'supertails',
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Action Icons: Orders & Cart
              Row(
                children: [
                  IconButton(
                    tooltip: 'My Orders',
                    icon: const Icon(Icons.receipt_long_rounded, color: AppColors.canopy, size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersListScreen()),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Wishlist',
                    icon: Badge(
                      label: Text(_wishlistIds.length.toString()),
                      isLabelVisible: _wishlistIds.isNotEmpty,
                      backgroundColor: AppColors.alertCoral,
                      child: Icon(
                        _wishlistIds.isNotEmpty ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _wishlistIds.isNotEmpty ? AppColors.alertCoral : AppColors.inkText,
                        size: 22,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_wishlistIds.length} items in your wishlist ❤️'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Cart',
                    icon: Badge(
                      label: Text(ecoProvider.cart.length.toString()),
                      isLabelVisible: ecoProvider.cart.isNotEmpty,
                      backgroundColor: AppColors.alertCoral,
                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.inkText, size: 22),
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
            ],
          ),
          const SizedBox(height: 4),
          // Delivery Locator Strip
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryTerracotta),
              const SizedBox(width: 4),
              Text(
                'Deliver to: ',
                style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.softTaupe),
              ),
              Text(
                'Indiranagar, Bangalore 560038',
                style: AppTypography.labelSmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkText),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.pistachioSecondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '⚡ 2-Hr Express',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pistachioDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: "Search 'Royal Canin', 'Cat Food', 'Chews'...",
          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe, fontSize: 12.5),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryTerracotta),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildRoundelsSection() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickRoundels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, index) {
          final item = _quickRoundels[index];
          final isSelected = _selectedCategory == item['category'];

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = item['category'] as String;
              });
            },
            borderRadius: BorderRadius.circular(30),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFDE59) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.canopy : AppColors.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      item['icon'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item['label'] as String,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.canopy : AppColors.inkText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
            itemCount: _heroBanners.length,
            itemBuilder: (ctx, index) {
              final banner = _heroBanners[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.canopy.withValues(alpha: 0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.35,
                          child: Image.asset(
                            banner['bgImage']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.canopy.withValues(alpha: 0.95),
                                AppColors.canopy.withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.65, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDE59),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner['tag']!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: const Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner['title']!,
                              style: AppTypography.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 14.5,
                                height: 1.15,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner['code']!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryGlow,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _heroBanners.length,
            (idx) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == idx ? 16 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: _currentBannerIndex == idx ? AppColors.canopy : AppColors.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashDealsSection(List<MarketplaceProduct> flashProducts, EcosystemProvider ecoProvider) {
    if (flashProducts.isEmpty) return const SizedBox.shrink();

    final hours = _flashSaleRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (_flashSaleRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_flashSaleRemaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Light Yellow Glow
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDE59), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    'LIGHTNING DEALS',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.canopy,
                      letterSpacing: 0.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Ends in: ', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
                  _buildTimerBox(hours),
                  const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  _buildTimerBox(minutes),
                  const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  _buildTimerBox(seconds),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: flashProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, index) {
                final product = flashProducts[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 75,
                                width: double.infinity,
                                color: AppColors.creamSurface,
                                child: Image.asset(product.imagePath, fit: BoxFit.contain),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.alertCoral,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${product.discountPercent}% OFF',
                                  style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.inkText),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '₹${product.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 8.5, color: AppColors.softTaupe, decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.canopy,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildBrandSpotlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOP PET BRANDS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primaryTerracotta,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            if (_selectedBrand != 'all' && _selectedBrand != 'All Brands')
              TextButton(
                onPressed: () => setState(() => _selectedBrand = 'all'),
                child: const Text('Clear Filter', style: TextStyle(fontSize: 11, color: AppColors.primaryTerracotta)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topBrands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (ctx, index) {
              final brand = _topBrands[index];
              final isSelected = (_selectedBrand == brand) || (_selectedBrand == 'all' && brand == 'All Brands');

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedBrand = brand == 'All Brands' ? 'all' : brand;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.canopy : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.canopy : AppColors.dividerColor),
                  ),
                  child: Text(
                    brand,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.inkText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterRow() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 6),
                _buildFilterChip('🐶 Dogs', 'dog'),
                const SizedBox(width: 6),
                _buildFilterChip('🐱 Cats', 'cat'),
                const SizedBox(width: 6),
                _buildFilterChip('🍖 Food', 'food'),
                const SizedBox(width: 6),
                _buildFilterChip('🦴 Treats', 'treats'),
                const SizedBox(width: 6),
                _buildFilterChip('🛁 Grooming', 'grooming'),
                const SizedBox(width: 6),
                _buildFilterChip('💊 Pharmacy', 'medicine'),
                const SizedBox(width: 6),
                _buildFilterChip('🎾 Toys', 'toys'),
                const SizedBox(width: 6),
                _buildFilterChip('🎒 Accessories', 'accessories'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Sort Dropdown
        PopupMenuButton<String>(
          initialValue: _sortBy,
          tooltip: 'Sort Products',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: const Icon(Icons.sort_rounded, size: 18, color: AppColors.canopy),
          ),
          onSelected: (val) => setState(() => _sortBy = val),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'popular', child: Text('Most Popular')),
            const PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
            const PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
            const PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
            const PopupMenuItem(value: 'discount', child: Text('Biggest Discount')),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = value),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canopy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.canopy : AppColors.dividerColor),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 10.5,
            color: isSelected ? Colors.white : AppColors.inkText,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Supertails Catalog ($count items)',
          style: AppTypography.displaySmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDE59).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '100% Authentic 🐾',
            style: AppTypography.labelSmall.copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.canopy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupertailsProductCard(
    BuildContext context,
    MarketplaceProduct product,
    EcosystemProvider ecoProvider,
    int quantityInCart,
    bool isWishlisted,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerColor.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Badges
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.creamSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.shopping_bag_rounded, size: 36, color: AppColors.canopy),
                      ),
                    ),
                  ),
                ),
                // Discount Ribbon (Supertails Coral)
                if (product.discountPercent > 0)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.alertCoral,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Wishlist Heart Button
                Positioned(
                  right: 4,
                  top: 4,
                  child: InkWell(
                    onTap: () => _toggleWishlist(product.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 14,
                        color: isWishlisted ? AppColors.alertCoral : AppColors.softTaupe,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Tag
                      if (product.brand.isNotEmpty)
                        Text(
                          product.brand.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryTerracotta,
                            letterSpacing: 0.4,
                          ),
                        ),
                      const SizedBox(height: 1),

                      // Title
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Rating & Verified Count
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.mossAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 10, color: AppColors.mossAccent),
                                const SizedBox(width: 1),
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.mossAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewsCount})',
                            style: const TextStyle(fontSize: 8, color: AppColors.softTaupe),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Price & Strike-through MRP
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.inkText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (product.originalPrice > product.price)
                            Text(
                              '₹${product.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.softTaupe,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Supertails Add to Cart / Quantity Controller
                  SizedBox(
                    width: double.infinity,
                    height: 25,
                    child: quantityInCart > 0
                        ? Container(
                            decoration: BoxDecoration(
                              color: AppColors.canopy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => ecoProvider.removeSingleFromCart(product.id),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.remove, size: 12, color: Colors.white),
                                  ),
                                ),
                                Text(
                                  '$quantityInCart in cart',
                                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () => ecoProvider.addToCart(product),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.add, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTerracotta,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ecoProvider.addToCart(product);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${product.title} to cart 🛍️'),
                                  duration: const Duration(milliseconds: 1200),
                                  backgroundColor: AppColors.canopy,
                                ),
                              );
                            },
                            child: const Text(
                              'ADD TO CART',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCartBar(BuildContext context, int cartCount, double cartTotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canopy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDE59),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_rounded, size: 16, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$cartCount item${cartCount > 1 ? 's' : ''} added',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    '₹${cartTotal.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text('View Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTerracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
