import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/adoption_model.dart';
import '../models/lost_pet_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class EcosystemProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CommunityPost> _posts = [];
  List<AdoptionListing> _adoptions = [];
  List<LostPetAlert> _lostPets = [];
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
    _lostPets = await _firestoreService.getLostPetsOnce();
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

  // --- LOST & FOUND STATE ---
  List<LostPetAlert> get lostPets => _lostPets;

  Future<void> reportLostPet(LostPetAlert alert) async {
    _lostPets.insert(0, alert);
    notifyListeners();
    await _firestoreService.addLostPetAlert(alert);
  }

  // --- MARKETPLACE STATE ---
  final List<MarketplaceProduct> _products = [
    MarketplaceProduct(
      id: 'prod_1',
      title: 'Royal Canin Golden Retriever Dry Food',
      category: 'food',
      description: 'Tailored nutrition for adult Retrievers, supports joint health.',
      price: 2499.0,
      imagePath: 'assets/rc_golden.png',
      rating: 4.8,
    ),
    MarketplaceProduct(
      id: 'prod_2',
      title: 'Antigravity GPS Smart Tracker Collar',
      category: 'accessories',
      description: 'Real-time GPS tracking with geofencing and health reports.',
      price: 3999.0,
      imagePath: 'assets/gps_collar.png',
      rating: 4.6,
    ),
    MarketplaceProduct(
      id: 'prod_3',
      title: 'Tick & Flea Prevention Chewables (3 pack)',
      category: 'medicine',
      description: 'Veterinary approved tick defense formulation.',
      price: 899.0,
      imagePath: 'assets/flea_chew.png',
      rating: 4.7,
    ),
    MarketplaceProduct(
      id: 'prod_4',
      title: 'Premium Pin Slicker Grooming Brush',
      category: 'grooming',
      description: 'Gently removes loose undercoat hair and prevents matting.',
      price: 649.0,
      imagePath: 'assets/grooming_brush.png',
      rating: 4.5,
    ),
    MarketplaceProduct(
      id: 'prod_5',
      title: 'Hypoallergenic Herbal Oatmeal Shampoo',
      category: 'grooming',
      description: 'Soothing oat extracts to reduce dry skin scratching.',
      price: 499.0,
      imagePath: 'assets/oatmeal_shampoo.png',
      rating: 4.6,
    ),
  ];

  List<MarketplaceProduct> get products => _products;
  List<MarketplaceProduct> get cart => _cart;
  List<OrderRecord> get orders => _orders;

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
