import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionListing {
  final String id;
  final String petName;
  final String species;
  final String breed;
  final String age;
  final String location;
  final String description;
  final String shelterName;
  final String contactPhone;
  final bool isAdopted;

  AdoptionListing({
    required this.id,
    required this.petName,
    required this.species,
    required this.breed,
    required this.age,
    required this.location,
    required this.description,
    required this.shelterName,
    required this.contactPhone,
    this.isAdopted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petName': petName,
      'species': species,
      'breed': breed,
      'age': age,
      'location': location,
      'description': description,
      'shelterName': shelterName,
      'contactPhone': contactPhone,
      'isAdopted': isAdopted,
    };
  }

  factory AdoptionListing.fromMap(Map<String, dynamic> map, String docId) {
    return AdoptionListing(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      petName: map['petName'] ?? 'Pet',
      species: map['species'] ?? 'dog',
      breed: map['breed'] ?? 'Mixed',
      age: map['age'] ?? '1 year',
      location: map['location'] ?? 'Shelter',
      description: map['description'] ?? '',
      shelterName: map['shelterName'] ?? 'NGO Shelter',
      contactPhone: map['contactPhone'] ?? '',
      isAdopted: map['isAdopted'] ?? false,
    );
  }

  AdoptionListing copyWith({
    String? id,
    String? petName,
    String? species,
    String? breed,
    String? age,
    String? location,
    String? description,
    String? shelterName,
    String? contactPhone,
    bool? isAdopted,
  }) {
    return AdoptionListing(
      id: id ?? this.id,
      petName: petName ?? this.petName,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      location: location ?? this.location,
      description: description ?? this.description,
      shelterName: shelterName ?? this.shelterName,
      contactPhone: contactPhone ?? this.contactPhone,
      isAdopted: isAdopted ?? this.isAdopted,
    );
  }
}
