class MarketplaceProduct {
  final String id;
  final String title;
  final String category; // "food", "medicine", "accessories", "toys"
  final String description;
  final double price;
  final String imagePath;
  final double rating;

  MarketplaceProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.imagePath,
    this.rating = 4.5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'rating': rating,
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
    );
  }
}
