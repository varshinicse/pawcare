import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/date_helpers.dart';

class ReminderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  int _completedStreak = 5; // Local streak counter per design requirements
  bool _justCompletedAction = false; // Flag to trigger happy mascot animation & confetti

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  int get completedStreak => _completedStreak;
  bool get justCompletedAction => _justCompletedAction;

  void resetCompletionActionFlag() {
    _justCompletedAction = false;
  }

  Future<void> fetchRemindersForPet(String petId) async {
    _isLoading = true;
    notifyListeners();

    _reminders = await _firestoreService.getRemindersOnce(petId);
    _isLoading = false;
    notifyListeners();
  }

  /// Reminders due today (for horizontal timeline)
  List<Reminder> get todayReminders {
    return _reminders.where((r) => DateHelpers.isToday(r.scheduledTime)).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Reminders for upcoming 7 days (excluding today)
  List<Reminder> get upcomingReminders {
    return _reminders.where((r) => DateHelpers.isUpcomingWithin7Days(r.scheduledTime)).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Checks if any reminder for today is overdue
  bool get hasOverdueReminders {
    return _reminders.any((r) => DateHelpers.isOverdue(r.scheduledTime, r.isCompleted));
  }

  Future<void> addReminder(Reminder reminder, String petName) async {
    await _firestoreService.addReminder(reminder);
    _reminders.add(reminder);
    notifyListeners();

    // Schedule local notification
    await _notificationService.scheduleReminderNotification(reminder, petName);
  }

  Future<void> toggleReminderComplete(Reminder reminder, String petName) async {
    final newStatus = !reminder.isCompleted;

    if (newStatus) {
      _completedStreak++;
      _justCompletedAction = true;
    } else if (_completedStreak > 0) {
      _completedStreak--;
    }

    final updated = reminder.copyWith(
      isCompleted: newStatus,
      completedAt: newStatus ? DateTime.now() : null,
    );

    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = updated;
    }

    notifyListeners();
    await _firestoreService.toggleReminderComplete(reminder.id, newStatus);
  }
}
