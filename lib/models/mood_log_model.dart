import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLog {
  final String id;
  final String petId;
  final String mood; // "happy", "sad", "lazy", "aggressive", "excited", "sick"
  final DateTime date;
  final String behaviors;

  MoodLog({
    required this.id,
    required this.petId,
    required this.mood,
    required this.date,
    this.behaviors = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'mood': mood,
      'date': Timestamp.fromDate(date),
      'behaviors': behaviors,
    };
  }

  factory MoodLog.fromMap(Map<String, dynamic> map, String docId) {
    return MoodLog(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      mood: map['mood'] ?? 'happy',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      behaviors: map['behaviors'] ?? '',
    );
  }
}
