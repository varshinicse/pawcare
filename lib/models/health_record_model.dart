import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String petId;
  final String type; // "vaccination", "prescription", "surgery", "lab_report", "vet_note"
  final String title;
  final String description;
  final DateTime date;
  final String veterinarianName;
  final double weightKg;
  final double temperatureCelsius;
  final String docUrl;

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
  });

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
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map, String docId) {
    return HealthRecord(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petId: map['petId'] ?? '',
      type: map['type'] ?? 'prescription',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      veterinarianName: map['veterinarianName'] ?? 'Dr. Ramesh Kumar',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble() ?? 38.5,
      docUrl: map['docUrl'] ?? '',
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
    );
  }
}
