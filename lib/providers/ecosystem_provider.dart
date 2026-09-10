import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/adoption_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class EcosystemProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CommunityPost> _posts = [];
  List<AdoptionListing> _adoptions = [];
  List<MarketplaceProduct> _cart = [];
  List<OrderRecord> _orders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // --- COMMUNITY FEED STATE ---
  List<CommunityPost> get posts => _posts;

  EcosystemProvider() {
    loadEcosystemData();
  }

  Future<void> loadEcosystemData() async {
    _isLoading = true;
    notifyListeners();

    _posts = await _firestoreService.getPostsOnce();
    _adoptions = await _firestoreService.getAdoptionsOnce();
    _cart = await _firestoreService.getCartOnce();
    _orders = await _firestoreService.getOrdersOnce();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> likePost(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updatedPost = _posts[index].copyWith(likes: _posts[index].likes + 1);
      _posts[index] = updatedPost;
      notifyListeners();
      await _firestoreService.updatePost(updatedPost);
    }
  }

  Future<void> addComment(String postId, String comment) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1 && comment.trim().isNotEmpty) {
      final updatedComments = List<String>.from(_posts[index].comments)..add(comment.trim());
      final updatedPost = _posts[index].copyWith(comments: updatedComments);
      _posts[index] = updatedPost;
      notifyListeners();
      await _firestoreService.updatePost(updatedPost);
    }
  }

  Future<void> createPost(String caption) async {
    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerName: 'Varshini',
      ownerAvatar: 'V',
      imagePath: '',
      caption: caption,
      likes: 0,
      createdAt: DateTime.now(),
      comments: [],
    );
    _posts.insert(0, newPost);
    notifyListeners();
    await _firestoreService.addPost(newPost);
  }

  // --- ADOPTIONS STATE ---
  List<AdoptionListing> get adoptions => _adoptions;

  Future<void> addAdoptionListing(AdoptionListing listing) async {
    _adoptions.insert(0, listing);
    notifyListeners();
    await _firestoreService.addAdoptionListing(listing);
  }

  // --- MARKETPLACE STATE (30 SUPERTAILS-STYLE PRODUCTS) ---
  final List<MarketplaceProduct> _products = [
    // 1. NUTRITION & FOOD
    MarketplaceProduct(
      id: 'prod_1',
      title: 'Royal Canin Maxi Adult Dry Dog Food (4kg)',
      category: 'food',
      brand: 'Royal Canin',
      description: 'Tailored nutrition for large breed adult dogs (26-44kg). Supports optimal bone & joint health and promotes high digestive security.',
      price: 2650.0,
      imagePath: 'assets/images/products/prod_rc_maxi.jpg',
      rating: 4.9,
      discountPercent: 12,
      reviewsCount: 340,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_2',
      title: 'Pedigree Chicken & Liver Gravy Pouch (Pack of 15 x 100g)',
      category: 'food',
      brand: 'Pedigree',
      description: 'Moist gourmet chunks in succulent gravy formulated with zinc and omega fatty acids for a shiny coat and active vitality.',
      price: 675.0,
      imagePath: 'assets/images/products/prod_pedigree_gravy.jpg',
      rating: 4.7,
      discountPercent: 15,
      reviewsCount: 512,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_3',
      title: 'Whiskas Ocean Fish & Salmon Dry Cat Food (3kg)',
      category: 'food',
      brand: 'Whiskas',
      description: 'Crunchy kibble with real salmon and essential taurine + vitamin A for sharp eyesight and healthy urinary tract maintenance.',
      price: 1050.0,
      imagePath: 'assets/images/products/prod_whiskas_salmon.jpg',
      rating: 4.8,
      discountPercent: 18,
      reviewsCount: 420,
      petType: 'cat',
    ),
    MarketplaceProduct(
      id: 'prod_4',
      title: 'Farmina N&D Grain Free Chicken & Pomegranate Adult Dog (2.5kg)',
      category: 'food',
      brand: 'Farmina N&D',
      description: 'Ultra-premium grain-free formula with 98% animal protein and cold infusion vitamins for sensitive digestive systems.',
      price: 3190.0,
      imagePath: 'assets/images/products/prod_farmina_nd.jpg',
      rating: 4.95,
      discountPercent: 10,
      reviewsCount: 195,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_5',
      title: 'Drools Focus Super Premium Puppy Starter Formula (3kg)',
      category: 'food',
      brand: 'Drools',
      description: 'High-calorie digestible kibble enriched with DHA from fish oil to support brain development in weaning puppies.',
      price: 1599.0,
      imagePath: 'assets/images/products/prod_drools_puppy.jpg',
      rating: 4.6,
      discountPercent: 20,
      reviewsCount: 280,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_6',
      title: 'Sheba Deluxe Tuna & Salmon in Gravy Wet Food (Pack of 12)',
      category: 'food',
      brand: 'Sheba',
      description: 'Fine dining culinary recipe crafted from genuine flaky fish shreds for discerning feline appetites.',
      price: 780.0,
      imagePath: 'assets/images/products/prod_sheba_tuna.jpg',
      rating: 4.85,
      discountPercent: 14,
      reviewsCount: 168,
      petType: 'cat',
    ),

    // 2. TREATS & CHEWS
    MarketplaceProduct(
      id: 'prod_7',
      title: 'Pedigree Dentastix Daily Dental Care Treats for Medium Dogs (7 Sticks)',
      category: 'treats',
      brand: 'Pedigree',
      description: 'Clinically proven X-shape dental chew that reduces tartar and plaque buildup by up to 80% while freshening breath.',
      price: 240.0,
      imagePath: 'assets/images/products/prod_dentastix_chews.jpg',
      rating: 4.8,
      discountPercent: 10,
      reviewsCount: 650,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_8',
      title: 'Chip Chops Real Chicken Tender Jerky Strips (70g)',
      category: 'treats',
      brand: 'Chip Chops',
      description: 'Pure slow-roasted chicken breast fillet strips. High protein, zero artificial preservatives, ideal training reward.',
      price: 215.0,
      imagePath: 'assets/images/products/prod_chicken_jerky.jpg',
      rating: 4.9,
      discountPercent: 12,
      reviewsCount: 390,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_9',
      title: 'Temptations Crunchy Cat Treats Salmon Savoury Pockets (85g)',
      category: 'treats',
      brand: 'Temptations',
      description: 'Irresistible dual-textured feline treats: crunchy outer shell with a soft, rich savory salmon center.',
      price: 185.0,
      imagePath: 'assets/images/products/prod_catnip_crunchies.jpg',
      rating: 4.92,
      discountPercent: 15,
      reviewsCount: 470,
      petType: 'cat',
    ),
    MarketplaceProduct(
      id: 'prod_10',
      title: 'Bark Out Loud Calming & Stress Relief Hemp Chews (30 Chews)',
      category: 'treats',
      brand: 'Bark Out Loud',
      description: 'Natural chamomile, L-theanine, and hemp seed oil soft chews to soothe thunder anxiety and car ride stress.',
      price: 599.0,
      imagePath: 'assets/images/products/prod_calming_chews.jpg',
      rating: 4.75,
      discountPercent: 25,
      reviewsCount: 145,
      petType: 'dog',
    ),

    // 3. GROOMING & HYGIENE
    MarketplaceProduct(
      id: 'prod_11',
      title: 'Captain Zack Barking Up The Tea Tree Anti-Itch Pet Shampoo (200ml)',
      category: 'grooming',
      brand: 'Captain Zack',
      description: 'Vegan anti-microbial tea tree and vitamin E formula to soothe hot spots, prevent dandruff, and eliminate odor.',
      price: 360.0,
      imagePath: 'assets/images/products/prod_herbal_shampoo.jpg',
      rating: 4.82,
      discountPercent: 20,
      reviewsCount: 285,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_12',
      title: 'Wahl Self-Cleaning Slicker Deshedding Brush',
      category: 'grooming',
      brand: 'Wahl',
      description: 'Retractable fine wire bristles remove loose undercoat fur with a one-touch ejector button for effortless cleaning.',
      price: 699.0,
      imagePath: 'assets/images/products/prod_slicker_brush.jpg',
      rating: 4.88,
      discountPercent: 30,
      reviewsCount: 310,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_13',
      title: 'Petkin Organic Healing Paw Balm with Vitamin E (60g)',
      category: 'grooming',
      brand: 'Petkin',
      description: 'All-weather beeswax and shea butter balm that heals cracked paw pads and dry noses from hot pavement and rough terrain.',
      price: 450.0,
      imagePath: 'assets/images/products/prod_paw_balm.jpg',
      rating: 4.78,
      discountPercent: 15,
      reviewsCount: 190,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_14',
      title: 'Dremel Electric USB Rechargeable Quiet Pet Nail Grinder',
      category: 'grooming',
      brand: 'Dremel',
      description: 'Low-noise diamond bit nail grinder with LED safety light to trim nails smoothly without cutting the quick.',
      price: 1299.0,
      imagePath: 'assets/images/products/prod_nail_grinder.jpg',
      rating: 4.65,
      discountPercent: 35,
      reviewsCount: 120,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_15',
      title: 'Himalaya Erina-EP Deep Cleansing Wet Wipes (80 Wipes)',
      category: 'grooming',
      brand: 'Himalaya',
      description: 'Hypoallergenic eucalyptus and neem wipes for quick paw cleanups, coat freshening, and post-walk sanitization.',
      price: 260.0,
      imagePath: 'assets/images/products/prod_pet_wipes.jpg',
      rating: 4.7,
      discountPercent: 18,
      reviewsCount: 480,
      petType: 'all',
    ),

    // 4. PHARMACY & WELLNESS
    MarketplaceProduct(
      id: 'prod_16',
      title: 'Fiprofort Plus Spot-On Flea & Tick Treatment (3 Pipettes)',
      category: 'medicine',
      brand: 'Savavet',
      description: 'Veterinary strength fipronil and (S)-methoprene topical solution providing 3 months of comprehensive parasite defense.',
      price: 799.0,
      imagePath: 'assets/images/products/prod_flea_tick_spray.jpg',
      rating: 4.88,
      discountPercent: 22,
      reviewsCount: 360,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_17',
      title: 'Beaphar Wild Alaskan Salmon Oil Pure Omega 3 & 6 (250ml)',
      category: 'medicine',
      brand: 'Beaphar',
      description: 'Cold-pressed wild salmon oil that relieves itchy skin, curbs shedding, and supports supple joints and brain health.',
      price: 950.0,
      imagePath: 'assets/images/products/prod_omega3_oil.jpg',
      rating: 4.93,
      discountPercent: 15,
      reviewsCount: 290,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_18',
      title: 'Himalaya Digyton Drops for Digestive Support (30ml)',
      category: 'medicine',
      brand: 'Himalaya',
      description: 'Herbal carminative and stomachic formulation that stimulates appetite, reduces gas, and balances bowel flora.',
      price: 165.0,
      imagePath: 'assets/images/products/prod_himalaya_digyton.jpg',
      rating: 4.8,
      discountPercent: 10,
      reviewsCount: 410,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_19',
      title: 'TropiClean Fresh Breath Dental Water Additive (473ml)',
      category: 'medicine',
      brand: 'TropiClean',
      description: 'Simply add to daily drinking water to eliminate bad breath for up to 12 hours and defend against periodontal plaque.',
      price: 890.0,
      imagePath: 'assets/images/products/prod_dental_water_additive.jpg',
      rating: 4.74,
      discountPercent: 20,
      reviewsCount: 175,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_20',
      title: 'Nutri-Vet Pre & Probiotic Digestive Enzyme Powder (100g)',
      category: 'medicine',
      brand: 'Nutri-Vet',
      description: 'Over 1 Billion live CFU cultures per serving to restore gut balance during antibiotic therapy and diet transitions.',
      price: 849.0,
      imagePath: 'assets/images/products/prod_probiotic_powder.jpg',
      rating: 4.85,
      discountPercent: 18,
      reviewsCount: 130,
      petType: 'all',
    ),

    // 5. TOYS & PLAY
    MarketplaceProduct(
      id: 'prod_21',
      title: 'KONG Classic Ultra-Durable Rubber Treat Dispensing Toy (Large)',
      category: 'toys',
      brand: 'KONG',
      description: 'The gold standard in dog toys for over 40 years. Unpredictable bounce and hollow center to stuff with peanut butter.',
      price: 999.0,
      imagePath: 'assets/images/products/prod_kong_classic.jpg',
      rating: 4.95,
      discountPercent: 10,
      reviewsCount: 620,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_22',
      title: 'PetSafe Automatic 360-Degree Rotating LED Laser Cat Toy',
      category: 'toys',
      brand: 'PetSafe',
      description: 'Hands-free automated laser beam that rotates unpredictably across floors and walls to stimulate hunting instincts.',
      price: 1450.0,
      imagePath: 'assets/images/products/prod_cat_laser_toy.jpg',
      rating: 4.7,
      discountPercent: 28,
      reviewsCount: 180,
      petType: 'cat',
    ),
    MarketplaceProduct(
      id: 'prod_23',
      title: 'Trixie Multi-Knot Heavy Cotton Dental Chew Tug Rope (50cm)',
      category: 'toys',
      brand: 'Trixie',
      description: '100% natural braided cotton fibers that floss teeth while playing vigorous games of tug-of-war and fetch.',
      price: 349.0,
      imagePath: 'assets/images/products/prod_rope_tug_toy.jpg',
      rating: 4.68,
      discountPercent: 25,
      reviewsCount: 240,
      petType: 'dog',
    ),

    // 6. ACCESSORIES, BEDS & LITTER
    MarketplaceProduct(
      id: 'prod_24',
      title: 'PawHut Multi-Level Sisal Scratching Tree Tower with Condo',
      category: 'accessories',
      brand: 'PawHut',
      description: 'Sturdy particle board tower with soft plush hammock, sisal-wrapped scratching posts, and hanging pom-pom toy.',
      price: 3499.0,
      imagePath: 'assets/images/products/prod_cat_tree_tower.jpg',
      rating: 4.88,
      discountPercent: 32,
      reviewsCount: 155,
      petType: 'cat',
    ),
    MarketplaceProduct(
      id: 'prod_25',
      title: 'Furhaven Orthopedic Memory Foam Velvet Dog Mattress Bed (L)',
      category: 'accessories',
      brand: 'Furhaven',
      description: 'Medical-grade egg-crate foam core cushions aching joints and neck pressure points with a removable machine-washable cover.',
      price: 2899.0,
      imagePath: 'assets/images/products/prod_orthopedic_bed.jpg',
      rating: 4.92,
      discountPercent: 24,
      reviewsCount: 275,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_26',
      title: 'PetVogue Anti-Skid Stainless Steel Feeding Bowl (900ml)',
      category: 'accessories',
      brand: 'PetVogue',
      description: 'Rust-resistant food grade stainless steel bowl with a heavy-duty silicone non-slip rubber base to prevent spills.',
      price: 399.0,
      imagePath: 'assets/images/products/prod_stainless_bowl.jpg',
      rating: 4.75,
      discountPercent: 20,
      reviewsCount: 390,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_27',
      title: 'Tractive Waterproof Live GPS & Health Activity Collar',
      category: 'accessories',
      brand: 'Tractive',
      description: 'Real-time live GPS satellite tracking with geofence virtual escape alerts, sleep monitoring, and health activity badges.',
      price: 4499.0,
      imagePath: 'assets/images/products/prod_gps_smart_collar.jpg',
      rating: 4.86,
      discountPercent: 15,
      reviewsCount: 210,
      petType: 'all',
    ),
    MarketplaceProduct(
      id: 'prod_28',
      title: 'Flexi New Classic Heavy-Duty Tape Retractable Leash (5m)',
      category: 'accessories',
      brand: 'Flexi',
      description: 'German engineered high-strength tape leash with short-stroke intuitive one-hand braking and recoil mechanism.',
      price: 1150.0,
      imagePath: 'assets/images/products/prod_retractable_leash.jpg',
      rating: 4.89,
      discountPercent: 18,
      reviewsCount: 340,
      petType: 'dog',
    ),
    MarketplaceProduct(
      id: 'prod_29',
      title: 'Intersand OdourLock Ultra Clumping Bentonite Cat Litter (12kg)',
      category: 'accessories',
      brand: 'Intersand',
      description: '99.9% dust-free natural sodium bentonite with Smart Odour Shield technology that neutralizes ammonia smells for 40 days.',
      price: 1499.0,
      imagePath: 'assets/images/products/prod_bentonite_litter.jpg',
      rating: 4.94,
      discountPercent: 16,
      reviewsCount: 460,
      petType: 'cat',
    ),
    MarketplaceProduct(
      id: 'prod_30',
      title: 'AmazonBasics Two-Door Top-Load Airline Approved Pet Travel Carrier',
      category: 'accessories',
      brand: 'AmazonBasics',
      description: 'Durable composite hard-shell crate with spring-loaded steel latch and 360-degree ventilation grids for road trips and flights.',
      price: 2199.0,
      imagePath: 'assets/images/products/prod_travel_carrier.jpg',
      rating: 4.79,
      discountPercent: 22,
      reviewsCount: 310,
      petType: 'all',
    ),
  ];

  List<MarketplaceProduct> get products => _products;
  List<MarketplaceProduct> get cart => _cart;
  List<OrderRecord> get orders => _orders;

  double get cartTotal => _cart.fold<double>(0, (sum, item) => sum + item.price);

  Future<void> addToCart(MarketplaceProduct product) async {
    _cart.add(product);
    notifyListeners();
    await _firestoreService.saveCart(_cart);
  }

  Future<void> removeFromCart(MarketplaceProduct product) async {
    _cart.remove(product);
    notifyListeners();
    await _firestoreService.saveCart(_cart);
  }

  Future<void> removeSingleFromCart(String productId) async {
    final index = _cart.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _cart.removeAt(index);
      notifyListeners();
      await _firestoreService.saveCart(_cart);
    }
  }

  Future<void> clearCart() async {
    _cart.clear();
    notifyListeners();
    await _firestoreService.saveCart(_cart);
  }

  Future<void> checkoutCart(String petId) async {
    if (_cart.isEmpty) return;

    final total = _cart.fold<double>(0, (sum, item) => sum + item.price);
    final order = OrderRecord(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_cart),
      totalAmount: total,
      orderDate: DateTime.now(),
      status: 'Delivered',
    );

    // Save order record to persistent database
    await _firestoreService.addOrder(order);
    _orders.insert(0, order);

    // Auto-log to expense tracker under the currently selected pet
    addExpense(Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      category: 'accessories',
      title: 'PawCare Shop Purchase',
      amount: total,
      date: DateTime.now(),
    ));

    _cart.clear();
    await _firestoreService.saveCart(_cart);
    notifyListeners();
  }

  // --- EXPENSE TRACKER STATE ---
  final List<Expense> _expenses = [
    Expense(
      id: 'exp_1',
      petId: 'pet_bruno_1',
      category: 'food',
      title: 'Monthly Royal Canin bag',
      amount: 2499.0,
      date: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Expense(
      id: 'exp_2',
      petId: 'pet_bruno_1',
      category: 'vet',
      title: 'Annual vaccination fee',
      amount: 1500.0,
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Expense(
      id: 'exp_3',
      petId: 'pet_bruno_1',
      category: 'medicine',
      title: 'Deworming tablets',
      amount: 450.0,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  List<Expense> get expenses => _expenses;

  void addExpense(Expense exp) {
    _expenses.insert(0, exp);
    notifyListeners();
  }

  double getCategoryTotal(String category) {
    return _expenses
        .where((e) => e.category == category)
        .fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  double get grandTotal {
    return _expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }
}
