import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String petId;
  final String type; // "walk", "exercise", "sleep", "play"
  final DateTime date;
  final double durationMinutes;
  final double caloriesBurned;
  final String details;

  ActivityLog({
    required this.id,
    required this.petId,
    required this.type,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.details = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'details': details,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map, String docId) {
    return ActivityLog(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      type: map['type'] ?? 'walk',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      durationMinutes: (map['durationMinutes'] as num?)?.toDouble() ?? 30.0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 50.0,
      details: map['details'] ?? '',
    );
  }
}
