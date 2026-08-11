import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String petId;
  final String category; // "food", "vet", "medicine", "accessories", "insurance"
  final String title;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.petId,
    required this.category,
    required this.title,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'category': category,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String docId) {
    return Expense(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      category: map['category'] ?? 'food',
      title: map['title'] ?? 'Expense',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}
