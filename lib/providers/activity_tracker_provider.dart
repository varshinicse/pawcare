import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';

class ActivityTrackerProvider with ChangeNotifier {
  final List<ActivityLog> _logs = [
    ActivityLog(
      id: 'log_1',
      petId: 'pet_bruno_1',
      type: 'walk',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      durationMinutes: 45.0,
      caloriesBurned: 120.0,
      details: 'Evening jog path around Bellandur lake.',
    ),
    ActivityLog(
      id: 'log_2',
      petId: 'pet_bruno_1',
      type: 'sleep',
      date: DateTime.now().subtract(const Duration(days: 1)),
      durationMinutes: 480.0,
      caloriesBurned: 180.0,
      details: 'Deep overnight rest sleep.',
    ),
    ActivityLog(
      id: 'log_3',
      petId: 'pet_bruno_1',
      type: 'play',
      date: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 30.0,
      caloriesBurned: 95.0,
      details: 'Ball retrieval and tug of war game.',
    ),
  ];

  List<ActivityLog> get logs => _logs;

  List<ActivityLog> getLogsForPet(String petId) {
    return _logs.where((l) => l.petId == petId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void addActivityLog(ActivityLog log) {
    _logs.add(log);
    notifyListeners();
  }

  double getWeeklyTotalMinutes(String petId, String type) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _logs
        .where((l) => l.petId == petId && l.type == type && l.date.isAfter(weekAgo))
        .fold<double>(0.0, (sum, item) => sum + item.durationMinutes);
  }
}
