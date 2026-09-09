import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/date_helpers.dart';
import 'care_history_provider.dart';

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

  /// Fetches reminders for a pet and automatically re-arms upcoming pending reminders
  Future<void> fetchRemindersForPet(String petId, [String? petName]) async {
    _isLoading = true;
    notifyListeners();

    _reminders = await _firestoreService.getRemindersOnce(petId);
    _isLoading = false;
    notifyListeners();

    // Re-arm pending future reminders so notifications survive app restart
    await rearmPendingReminders(petName ?? 'your pet');
  }

  /// Reconciles and schedules pending reminders with native OS
  Future<void> rearmPendingReminders([String petName = 'your pet']) async {
    final now = DateTime.now();
    for (final reminder in _reminders) {
      if (!reminder.isCompleted && reminder.notificationEnabled) {
        final isUpcoming = reminder.scheduledTime.isAfter(now);
        final isRepeating = reminder.repeat.toLowerCase() != 'once';
        if (isUpcoming || isRepeating) {
          await _notificationService.scheduleReminderNotification(
            reminder,
            petName,
          );
        }
      }
    }
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

  /// All overdue reminders
  List<Reminder> get overdueReminders {
    return _reminders.where((r) => DateHelpers.isOverdue(r.scheduledTime, r.isCompleted)).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Completed reminders history
  List<Reminder> get completedReminders {
    return _reminders.where((r) => r.isCompleted).toList()
      ..sort((a, b) => (b.completedAt ?? b.scheduledTime).compareTo(a.completedAt ?? a.scheduledTime));
  }

  Future<void> addReminder(Reminder reminder, String petName) async {
    final stableNotificationId = reminder.notificationId != 0
        ? reminder.notificationId
        : (reminder.id.hashCode.abs() % 100000);
    final safeReminder = reminder.copyWith(notificationId: stableNotificationId);

    await _firestoreService.addReminder(safeReminder);
    _reminders.add(safeReminder);
    notifyListeners();

    // Schedule local and native notification if enabled
    if (safeReminder.notificationEnabled) {
      await _notificationService.scheduleReminderNotification(safeReminder, petName);
    }
  }

  Future<void> updateReminder(Reminder reminder, String petName) async {
    await _firestoreService.updateReminder(reminder);
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
    }
    notifyListeners();

    await _notificationService.cancelReminderNotification(reminder.id, reminder.notificationId);
    if (!reminder.isCompleted && reminder.notificationEnabled) {
      await _notificationService.scheduleReminderNotification(reminder, petName);
    }
  }

  /// Snoozes a reminder by specified minutes without marking complete or recording Care History
  Future<void> snoozeReminder(
    Reminder reminder,
    int minutes,
    String petName,
  ) async {
    final newScheduledTime = DateTime.now().add(Duration(minutes: minutes));
    final snoozed = reminder.copyWith(
      scheduledTime: newScheduledTime,
      isCompleted: false,
      completedAt: null,
      updatedAt: DateTime.now(),
    );

    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = snoozed;
    }
    notifyListeners();

    await _firestoreService.updateReminder(snoozed);
    await _notificationService.cancelReminderNotification(reminder.id, reminder.notificationId);
    if (snoozed.notificationEnabled) {
      await _notificationService.scheduleReminderNotification(snoozed, petName);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final rem = _reminders.firstWhere((r) => r.id == reminderId, orElse: () => _reminders.first);
    final notifId = rem.notificationId;

    await _firestoreService.deleteReminder(reminderId);
    _reminders.removeWhere((r) => r.id == reminderId);
    notifyListeners();

    await _notificationService.cancelReminderNotification(reminderId, notifId);
  }

  /// Marks a reminder as complete or pending.
  /// Automatically writes to CareHistory via CareHistoryProvider and advances repeating reminders.
  Future<void> toggleReminderComplete(
    Reminder reminder,
    String petName, {
    CareHistoryProvider? careHistoryProvider,
  }) async {
    final newStatus = !reminder.isCompleted;

    if (newStatus) {
      _completedStreak++;
      _justCompletedAction = true;

      // 1. Auto-record to Care History
      if (careHistoryProvider != null) {
        await careHistoryProvider.recordReminderCompletion(reminder, petName);
      }

      // 2. Handle Repeat Recurrence if repeating
      final repeat = reminder.repeat.toLowerCase();
      if (repeat == 'daily' || repeat == 'weekly' || repeat == 'monthly') {
        DateTime nextTime;
        if (repeat == 'daily') {
          nextTime = reminder.scheduledTime.add(const Duration(days: 1));
        } else if (repeat == 'weekly') {
          nextTime = reminder.scheduledTime.add(const Duration(days: 7));
        } else {
          nextTime = DateTime(
            reminder.scheduledTime.year,
            reminder.scheduledTime.month + 1,
            reminder.scheduledTime.day,
            reminder.scheduledTime.hour,
            reminder.scheduledTime.minute,
          );
        }

        final advancedReminder = reminder.copyWith(
          scheduledTime: nextTime,
          isCompleted: false,
          completedAt: null,
          updatedAt: DateTime.now(),
        );

        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _reminders[index] = advancedReminder;
        }
        notifyListeners();

        await _firestoreService.updateReminder(advancedReminder);
        if (advancedReminder.notificationEnabled) {
          await _notificationService.cancelReminderNotification(reminder.id, reminder.notificationId);
          await _notificationService.scheduleReminderNotification(advancedReminder, petName);
        }
        return;
      }
    } else if (_completedStreak > 0) {
      _completedStreak--;
    }

    final updated = reminder.copyWith(
      isCompleted: newStatus,
      completedAt: newStatus ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = updated;
    }

    notifyListeners();
    await _firestoreService.toggleReminderComplete(reminder.id, newStatus);

    if (newStatus) {
      await _notificationService.cancelReminderNotification(reminder.id, reminder.notificationId);
    } else if (updated.notificationEnabled) {
      await _notificationService.scheduleReminderNotification(updated, petName);
    }
  }
}
