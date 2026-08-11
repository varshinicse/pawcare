import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String petId;
  final String type; // "feeding", "medication", "grooming", "vaccination", "checkup"
  final String title;
  final String notes;
  final DateTime scheduledTime;
  final String repeat; // "daily", "weekly", "once"
  final bool isCompleted;
  final DateTime? completedAt;

  Reminder({
    required this.id,
    required this.petId,
    required this.type,
    required this.title,
    required this.notes,
    required this.scheduledTime,
    required this.repeat,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'title': title,
      'notes': notes,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'repeat': repeat,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedScheduledTime;
    if (map['scheduledTime'] is Timestamp) {
      parsedScheduledTime = (map['scheduledTime'] as Timestamp).toDate();
    } else if (map['scheduledTime'] is String) {
      parsedScheduledTime = DateTime.tryParse(map['scheduledTime']) ?? DateTime.now();
    } else {
      parsedScheduledTime = DateTime.now();
    }

    DateTime? parsedCompletedAt;
    if (map['completedAt'] is Timestamp) {
      parsedCompletedAt = (map['completedAt'] as Timestamp).toDate();
    } else if (map['completedAt'] is String) {
      parsedCompletedAt = DateTime.tryParse(map['completedAt']);
    }

    return Reminder(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      type: map['type'] ?? 'feeding',
      title: map['title'] ?? 'Reminder',
      notes: map['notes'] ?? '',
      scheduledTime: parsedScheduledTime,
      repeat: map['repeat'] ?? 'daily',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: parsedCompletedAt,
    );
  }

  Reminder copyWith({
    String? id,
    String? petId,
    String? type,
    String? title,
    String? notes,
    DateTime? scheduledTime,
    String? repeat,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
