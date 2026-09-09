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
  String? get activePetId => _activePet?.id;
  bool get isLoading => _isLoading;

  PetProvider() {
    loadPets();
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void selectPetById(String id) {
    final pet = getPetById(id);
    if (pet != null) {
      selectPet(pet);
    }
  }

  Future<void> loadPets() async {
    _isLoading = true;
    notifyListeners();

    _pets = await _firestoreService.getPetsOnce('default_user');
    if (_pets.isNotEmpty) {
      final savedActiveId = await _firestoreService.loadActivePetId();
      final matched = _pets.where((p) => p.id == savedActiveId).toList();
      _activePet = matched.isNotEmpty ? matched.first : _pets.first;
    } else {
      _activePet = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectPet(Pet pet) {
    _activePet = pet;
    notifyListeners();
    _firestoreService.saveActivePetId(pet.id);
  }

  Future<void> addPet(Pet pet) async {
    _isLoading = true;
    notifyListeners();

    await _firestoreService.addPet(pet);
    _pets.add(pet);
    _activePet = pet;
    await _firestoreService.saveActivePetId(pet.id);

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

  Future<void> deletePet(String petId) async {
    _isLoading = true;
    notifyListeners();

    await _firestoreService.deletePet(petId);
    _pets.removeWhere((p) => p.id == petId);
    if (_activePet?.id == petId) {
      _activePet = _pets.isNotEmpty ? _pets.first : null;
      if (_activePet != null) {
        await _firestoreService.saveActivePetId(_activePet!.id);
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
