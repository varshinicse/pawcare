class MarketplaceProduct {
  final String id;
  final String title;
  final String category; // "food", "treats", "grooming", "medicine", "toys", "accessories", "hygiene"
  final String description;
  final double price;
  final String imagePath;
  final double rating;
  final String brand;
  final int discountPercent;
  final int reviewsCount;
  final String petType; // "dog", "cat", "all"

  MarketplaceProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.imagePath,
    this.rating = 4.8,
    this.brand = 'Supertails',
    this.discountPercent = 20,
    this.reviewsCount = 120,
    this.petType = 'all',
  });

  double get originalPrice => discountPercent > 0 ? (price / (1 - (discountPercent / 100))) : price;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'rating': rating,
      'brand': brand,
      'discountPercent': discountPercent,
      'reviewsCount': reviewsCount,
      'petType': petType,
    };
  }

  factory MarketplaceProduct.fromMap(Map<String, dynamic> map, String docId) {
    return MarketplaceProduct(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      title: map['title'] ?? 'Product',
      category: map['category'] ?? 'food',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 9.99,
      imagePath: map['imagePath'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      brand: map['brand'] ?? 'Supertails',
      discountPercent: (map['discountPercent'] as num?)?.toInt() ?? 20,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 120,
      petType: map['petType'] ?? 'all',
    );
  }
}
