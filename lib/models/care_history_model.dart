import 'package:cloud_firestore/cloud_firestore.dart';

class CareHistory {
  final String id;
  final String petId;
  final String? reminderId;
  final String activityType; // "grooming", "medication", "feeding", "bathing", "vaccination", "vet_visit", "tank_cleaning", "water_change", "walking", "custom"
  final String title;
  final String description;
  final DateTime completedAt;
  final DateTime createdAt;

  CareHistory({
    required this.id,
    required this.petId,
    this.reminderId,
    required this.activityType,
    required this.title,
    this.description = '',
    required this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'reminderId': reminderId,
      'activityType': activityType,
      'title': title,
      'description': description,
      'completedAt': Timestamp.fromDate(completedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CareHistory.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CareHistory(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      reminderId: map['reminderId'],
      activityType: map['activityType'] ?? 'custom',
      title: map['title'] ?? 'Care Activity',
      description: map['description'] ?? '',
      completedAt: parseDate(map['completedAt']),
      createdAt: parseDate(map['createdAt']),
    );
  }

  CareHistory copyWith({
    String? id,
    String? petId,
    String? reminderId,
    String? activityType,
    String? title,
    String? description,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return CareHistory(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      reminderId: reminderId ?? this.reminderId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      description: description ?? this.description,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
