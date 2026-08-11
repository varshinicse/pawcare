import 'package:flutter/material.dart';
import '../models/health_record_model.dart';
import '../services/firestore_service.dart';

class HealthRecordProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<HealthRecord> _records = [];
  bool _isLoading = false;

  List<HealthRecord> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> fetchRecordsForPet(String petId) async {
    _isLoading = true;
    notifyListeners();

    _records = await _firestoreService.getHealthRecordsOnce(petId);
    _records.sort((a, b) => b.date.compareTo(a.date));

    _isLoading = false;
    notifyListeners();
  }

  List<HealthRecord> getRecordsForPet(String petId) {
    return _records.where((r) => r.petId == petId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addRecord(HealthRecord record) async {
    await _firestoreService.addHealthRecord(record);
    _records.insert(0, record);
    notifyListeners();
  }

  /// Simulates generating a PDF Health Card and triggers a notification/alert download in UI
  Future<String> generatePdfHealthCard(String petName) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return 'PawCare_HealthCard_$petName.pdf';
  }
}
