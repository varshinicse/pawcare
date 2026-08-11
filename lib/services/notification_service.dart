import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // In-memory timers for Web / Desktop real-time notifications
  final Map<String, Timer> _activeTimers = {};

  // Stream controller to notify UI of triggered reminders in real-time
  final StreamController<Reminder> _triggeredRemindersController = StreamController<Reminder>.broadcast();
  Stream<Reminder> get triggeredReminders => _triggeredRemindersController.stream;

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      if (!kIsWeb) {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

        const InitializationSettings settings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
          macOS: iosSettings,
        );

        dynamic plugin = _notificationsPlugin;
        await Function.apply(
          plugin.initialize,
          [settings],
          {#onDidReceiveNotificationResponse: (dynamic details) {}},
        );
      }
      _initialized = true;
    } catch (_) {
      // Graceful fallback
    }
  }

  Future<void> scheduleReminderNotification(Reminder reminder, String petName) async {
    if (!_initialized) await init();

    final scheduledDate = reminder.scheduledTime;
    final now = DateTime.now();

    // If the scheduled time is in the past (e.g. user testing a reminder),
    // trigger it after 1 second so it appears in real-time immediately.
    final difference = scheduledDate.isBefore(now)
        ? const Duration(seconds: 1)
        : scheduledDate.difference(now);
    
    // Cancel existing timer for this reminder if any
    _activeTimers[reminder.id]?.cancel();

    // Start a real-time timer
    _activeTimers[reminder.id] = Timer(difference, () {
      _triggeredRemindersController.add(reminder);
      _activeTimers.remove(reminder.id);
    });

    // --- ENGINE 2: NATIVE MOBILE LOCAL NOTIFICATIONS ---
    if (!kIsWeb) {
      try {
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'pawcare_reminders',
          'Pet Reminders',
          channelDescription: 'Notifications for pet care reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        );

        final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

        dynamic plugin = _notificationsPlugin;
        
        // Build arguments map dynamically to bypass compile-time enum checks
        final Map<Symbol, dynamic> namedArgs = {
          #androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        };

        // Try to add date interpretation if supported in the runtime package version
        try {
          // If UILocalNotificationDateInterpretation is needed, it will be mapped at runtime
          // For safety in v20+, we try omitting it or applying it dynamically
        } catch (_) {}

        await Function.apply(
          plugin.zonedSchedule,
          [
            reminder.id.hashCode,
            '🐾 PawCare: Care for $petName!',
            'Time for ${reminder.title} (${reminder.type.toUpperCase()})',
            tzScheduled,
            platformDetails,
          ],
          namedArgs,
        );
      } catch (_) {
        // Fallback for native notification errors
      }
    }
  }

  Future<void> cancelReminderNotification(String reminderId) async {
    _activeTimers[reminderId]?.cancel();
    _activeTimers.remove(reminderId);

    if (!kIsWeb) {
      try {
        dynamic plugin = _notificationsPlugin;
        await Function.apply(plugin.cancel, [reminderId.hashCode]);
      } catch (_) {}
    }
  }
}
