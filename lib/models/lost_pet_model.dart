import 'package:cloud_firestore/cloud_firestore.dart';

class LostPetAlert {
  final String id;
  final String petName;
  final String species;
  final String breed;
  final String lastSeenLocation;
  final DateTime dateLost;
  final String rewardAmount;
  final String contactNumber;
  final String lastSeenCoordinates;

  LostPetAlert({
    required this.id,
    required this.petName,
    required this.species,
    required this.breed,
    required this.lastSeenLocation,
    required this.dateLost,
    this.rewardAmount = 'None',
    required this.contactNumber,
    this.lastSeenCoordinates = '12.9716, 77.5946',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petName': petName,
      'species': species,
      'breed': breed,
      'lastSeenLocation': lastSeenLocation,
      'dateLost': Timestamp.fromDate(dateLost),
      'rewardAmount': rewardAmount,
      'contactNumber': contactNumber,
      'lastSeenCoordinates': lastSeenCoordinates,
    };
  }

  factory LostPetAlert.fromMap(Map<String, dynamic> map, String docId) {
    return LostPetAlert(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petName: map['petName'] ?? 'Pet',
      species: map['species'] ?? 'dog',
      breed: map['breed'] ?? 'Mixed',
      lastSeenLocation: map['lastSeenLocation'] ?? 'Unknown',
      dateLost: map['dateLost'] is Timestamp
          ? (map['dateLost'] as Timestamp).toDate()
          : DateTime.tryParse(map['dateLost'] ?? '') ?? DateTime.now(),
      rewardAmount: map['rewardAmount'] ?? 'None',
      contactNumber: map['contactNumber'] ?? '',
      lastSeenCoordinates: map['lastSeenCoordinates'] ?? '12.9716, 77.5946',
    );
  }

  LostPetAlert copyWith({
    String? id,
    String? petName,
    String? species,
    String? breed,
    String? lastSeenLocation,
    DateTime? dateLost,
    String? rewardAmount,
    String? contactNumber,
    String? lastSeenCoordinates,
  }) {
    return LostPetAlert(
      id: id ?? this.id,
      petName: petName ?? this.petName,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      dateLost: dateLost ?? this.dateLost,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      contactNumber: contactNumber ?? this.contactNumber,
      lastSeenCoordinates: lastSeenCoordinates ?? this.lastSeenCoordinates,
    );
  }
}
