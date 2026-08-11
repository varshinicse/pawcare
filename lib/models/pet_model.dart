import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species; // "dog", "cat", etc.
  final String breed;
  final double age; // years
  final double weightKg;
  final String foodHabits;
  final List<String> medicalHistory;
  final String avatarAsset;
  final DateTime createdAt;

  // New Enterprise Ecosystem Fields
  final String gender;
  final DateTime birthdate;
  final String color;
  final List<String> allergies;
  final String insurance;
  final String microchipNumber;
  final String qrCode;
  final String emergencyContact;
  final List<String> gallery;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weightKg,
    required this.foodHabits,
    required this.medicalHistory,
    required this.avatarAsset,
    required this.createdAt,
    this.gender = 'Male',
    DateTime? birthdate,
    this.color = 'Golden',
    this.allergies = const [],
    this.insurance = 'None',
    this.microchipNumber = 'UNSET-0000',
    this.qrCode = '',
    this.emergencyContact = '+919876543210',
    this.gallery = const [],
  }) : birthdate = birthdate ?? DateTime.now().subtract(const Duration(days: 365));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weightKg': weightKg,
      'foodHabits': foodHabits,
      'medicalHistory': medicalHistory,
      'avatarAsset': avatarAsset,
      'createdAt': Timestamp.fromDate(createdAt),
      'gender': gender,
      'birthdate': Timestamp.fromDate(birthdate),
      'color': color,
      'allergies': allergies,
      'insurance': insurance,
      'microchipNumber': microchipNumber,
      'qrCode': qrCode,
      'emergencyContact': emergencyContact,
      'gallery': gallery,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    DateTime parsedBirthdate;
    if (map['birthdate'] is Timestamp) {
      parsedBirthdate = (map['birthdate'] as Timestamp).toDate();
    } else if (map['birthdate'] is String) {
      parsedBirthdate = DateTime.tryParse(map['birthdate']) ?? DateTime.now();
    } else {
      parsedBirthdate = DateTime.now().subtract(const Duration(days: 365));
    }

    return Pet(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? 'Pet',
      species: map['species'] ?? 'dog',
      breed: map['breed'] ?? 'Mixed',
      age: (map['age'] as num?)?.toDouble() ?? 1.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 5.0,
      foodHabits: map['foodHabits'] ?? '',
      medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
      avatarAsset: map['avatarAsset'] ?? 'dog_hero',
      createdAt: parsedCreatedAt,
      gender: map['gender'] ?? 'Male',
      birthdate: parsedBirthdate,
      color: map['color'] ?? 'Golden',
      allergies: List<String>.from(map['allergies'] ?? []),
      insurance: map['insurance'] ?? 'None',
      microchipNumber: map['microchipNumber'] ?? 'UNSET-0000',
      qrCode: map['qrCode'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '+919876543210',
      gallery: List<String>.from(map['gallery'] ?? []),
    );
  }

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    double? age,
    double? weightKg,
    String? foodHabits,
    List<String>? medicalHistory,
    String? avatarAsset,
    DateTime? createdAt,
    String? gender,
    DateTime? birthdate,
    String? color,
    List<String>? allergies,
    String? insurance,
    String? microchipNumber,
    String? qrCode,
    String? emergencyContact,
    List<String>? gallery,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      foodHabits: foodHabits ?? this.foodHabits,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      createdAt: createdAt ?? this.createdAt,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      color: color ?? this.color,
      allergies: allergies ?? this.allergies,
      insurance: insurance ?? this.insurance,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      qrCode: qrCode ?? this.qrCode,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      gallery: gallery ?? this.gallery,
    );
  }
}
