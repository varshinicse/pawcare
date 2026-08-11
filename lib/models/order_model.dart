import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

class OrderRecord {
  final String id;
  final List<MarketplaceProduct> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status; // "Pending", "Shipped", "Delivered"

  OrderRecord({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'Delivered',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }

  factory OrderRecord.fromMap(Map<String, dynamic> map, String docId) {
    return OrderRecord(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      items: (map['items'] as List? ?? [])
          .map((i) => MarketplaceProduct.fromMap(Map<String, dynamic>.from(i), ''))
          .toList(),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderDate: map['orderDate'] is Timestamp
          ? (map['orderDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['orderDate'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Delivered',
    );
  }

  OrderRecord copyWith({
    String? id,
    List<MarketplaceProduct>? items,
    double? totalAmount,
    DateTime? orderDate,
    String? status,
  }) {
    return OrderRecord(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
    );
  }
}
