import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String petId;
  final String type; // "Vaccination", "Vet Visit", "Medication", "Weight", "General Health", "Other" (or lowercase variants)
  final String title;
  final String description;
  final DateTime date;
  final String veterinarianName;
  final double weightKg;
  final double temperatureCelsius;
  final String docUrl;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthRecord({
    required this.id,
    required this.petId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.veterinarianName = 'Dr. Ramesh Kumar',
    this.weightKg = 0.0,
    this.temperatureCelsius = 38.5,
    this.docUrl = '',
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get recordType => type;
  String get veterinarian => veterinarianName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'veterinarianName': veterinarianName,
      'weightKg': weightKg,
      'temperatureCelsius': temperatureCelsius,
      'docUrl': docUrl,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return HealthRecord(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      type: map['type'] ?? (map['recordType'] ?? 'General Health'),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: parseDate(map['date']),
      veterinarianName: map['veterinarianName'] ?? (map['veterinarian'] ?? 'Dr. Ramesh Kumar'),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble() ?? 38.5,
      docUrl: map['docUrl'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  HealthRecord copyWith({
    String? id,
    String? petId,
    String? type,
    String? title,
    String? description,
    DateTime? date,
    String? veterinarianName,
    double? weightKg,
    double? temperatureCelsius,
    String? docUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      weightKg: weightKg ?? this.weightKg,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      docUrl: docUrl ?? this.docUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
