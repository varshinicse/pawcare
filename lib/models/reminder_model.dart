import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String petId;
  final String type; // Category: "feeding", "medication", "grooming", "walking", "vaccination", "checkup", "water_change", "tank_cleaning", etc.
  final String title;
  final String notes;
  final DateTime scheduledTime;
  final String repeat; // "once", "daily", "weekly", "monthly"
  final bool isCompleted;
  final DateTime? completedAt;
  final bool notificationEnabled;
  final int notificationId;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.notificationEnabled = true,
    int? notificationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : notificationId = notificationId ?? (id.hashCode.abs() % 100000),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get category => type;
  String get repeatType => repeat;
  DateTime get scheduledDateTime => scheduledTime;

  String get status {
    if (isCompleted) return 'Completed';
    if (DateTime.now().isAfter(scheduledTime)) return 'Overdue';
    return 'Pending';
  }

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(scheduledTime);

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
      'notificationEnabled': notificationEnabled,
      'notificationId': notificationId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val, [DateTime? defaultVal]) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? (defaultVal ?? DateTime.now());
      return defaultVal ?? DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final id = docId.isNotEmpty ? docId : (map['id'] ?? '');

    return Reminder(
      id: id,
      petId: map['petId'] ?? '',
      type: map['type'] ?? (map['category'] ?? 'feeding'),
      title: map['title'] ?? 'Reminder',
      notes: map['notes'] ?? (map['description'] ?? ''),
      scheduledTime: parseDate(map['scheduledTime'] ?? map['scheduledDateTime']),
      repeat: (map['repeat'] ?? map['repeatType'] ?? 'daily').toString().toLowerCase(),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: parseNullableDate(map['completedAt']),
      notificationEnabled: map['notificationEnabled'] ?? true,
      notificationId: (map['notificationId'] as num?)?.toInt() ?? (id.hashCode.abs() % 100000),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
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
    bool? notificationEnabled,
    int? notificationId,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
