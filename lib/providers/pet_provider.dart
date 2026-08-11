import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../services/firestore_service.dart';

class PetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Pet> _pets = [];
  Pet? _activePet;
  bool _isLoading = false;

  List<Pet> get pets => _pets;
  Pet? get activePet => _activePet;
  bool get isLoading => _isLoading;

  PetProvider() {
    loadPets();
  }

  Future<void> loadPets() async {
    _isLoading = true;
    notifyListeners();

    _pets = await _firestoreService.getPetsOnce('default_user');
    if (_pets.isNotEmpty) {
      _activePet = _pets.first;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectPet(Pet pet) {
    _activePet = pet;
    notifyListeners();
  }

  Future<void> addPet(Pet pet) async {
    _isLoading = true;
    notifyListeners();

    await _firestoreService.addPet(pet);
    _pets.add(pet);
    _activePet = pet;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePet(Pet pet) async {
    await _firestoreService.updatePet(pet);
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
      if (_activePet?.id == pet.id) {
        _activePet = pet;
      }
    }
    notifyListeners();
  }
}
