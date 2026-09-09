import 'package:flutter/material.dart';
import '../models/care_history_model.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';

class CareHistoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CareHistory> _history = [];
  bool _isLoading = false;
  String? _loadedPetId;

  List<CareHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get loadedPetId => _loadedPetId;

  Future<void> fetchHistoryForPet(String petId) async {
    _isLoading = true;
    _loadedPetId = petId;
    notifyListeners();

    _history = await _firestoreService.getCareHistoryOnce(petId);
    _history.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    _isLoading = false;
    notifyListeners();
  }

  List<CareHistory> getHistoryForPet(String petId) {
    return _history.where((c) => c.petId == petId).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> addCareHistory(CareHistory record) async {
    await _firestoreService.addCareHistory(record);
    if (_loadedPetId == null || _loadedPetId == record.petId) {
      _history.insert(0, record);
      _history.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      notifyListeners();
    }
  }

  Future<void> deleteCareHistory(String historyId) async {
    await _firestoreService.deleteCareHistory(historyId);
    _history.removeWhere((c) => c.id == historyId);
    notifyListeners();
  }

  /// Automatically records completion from a Reminder.
  /// Deduplicates to prevent duplicate history if tapped repeatedly.
  Future<void> recordReminderCompletion(Reminder reminder, String petName) async {
    final now = DateTime.now();

    // Check for recent duplicate (same reminderId completed within the last 60 seconds)
    final isDuplicate = _history.any((item) =>
        item.reminderId == reminder.id &&
        now.difference(item.completedAt).inSeconds.abs() < 60);

    if (isDuplicate) return;

    final historyItem = CareHistory(
      id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
      petId: reminder.petId,
      reminderId: reminder.id,
      activityType: reminder.type,
      title: reminder.title,
      description: reminder.notes.isNotEmpty
          ? reminder.notes
          : 'Completed scheduled ${reminder.type} for $petName.',
      completedAt: now,
      createdAt: now,
    );

    await addCareHistory(historyItem);
  }
}
