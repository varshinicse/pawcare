import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';

/// Comprehensive notification service supporting native scheduled notifications
/// on Android, iOS, macOS, Windows, and Linux with timezone awareness,
/// exact alarm fallback, background execution, and in-app foreground integration.
class NotificationService with WidgetsBindingObserver {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionsRequested = false;
  bool _isAppInForeground = true;

  // In-memory timers for immediate real-time in-app triggers when app is open
  final Map<String, Timer> _activeTimers = {};

  // Stream controller to notify UI of triggered reminders in real-time
  final StreamController<Reminder> _triggeredRemindersController =
      StreamController<Reminder>.broadcast();
  Stream<Reminder> get triggeredReminders =>
      _triggeredRemindersController.stream;

  // Stream controller for notification tap events (reminderId, petId)
  final StreamController<Map<String, String>> _notificationTapController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get notificationTaps =>
      _notificationTapController.stream;

  bool get isInitialized => _initialized;
  bool get isAppInForeground => _isAppInForeground;

  /// Initialize local notification system and timezone databases.
  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Initialize Timezone Database & map local timezone offset
      tz.initializeTimeZones();
      _configureLocalTimeZone();

      // 2. Register lifecycle observer to distinguish foreground vs background alerts
      WidgetsBinding.instance.addObserver(this);

      // 3. Platform Initialization Settings
      if (!kIsWeb) {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

        const DarwinInitializationSettings macOSSettings =
            DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

        const LinuxInitializationSettings linuxSettings =
            LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        );

        const InitializationSettings settings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
          macOS: macOSSettings,
          linux: linuxSettings,
        );

        await _notificationsPlugin.initialize(
          settings: settings,
          onDidReceiveNotificationResponse: _handleNotificationResponse,
        );

        // 4. Create standard Android Notification Channel
        await _createAndroidNotificationChannel();

        // 5. Check if the app was launched by tapping a notification
        final launchDetails =
            await _notificationsPlugin.getNotificationAppLaunchDetails();
        if (launchDetails != null &&
            launchDetails.didNotificationLaunchApp &&
            launchDetails.notificationResponse != null) {
          _handleNotificationResponse(launchDetails.notificationResponse!);
        }
      }

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = (state == AppLifecycleState.resumed);
  }

  /// Configures tz.local using device offset to prevent UTC time skew
  void _configureLocalTimeZone() {
    try {
      final now = DateTime.now();
      final offsetMs = now.timeZoneOffset.inMilliseconds;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offsetMs) {
          tz.setLocalLocation(loc);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error matching local timezone location: $e');
    }
  }

  /// Sets up high-importance Android channel for Pet Reminders
  Future<void> _createAndroidNotificationChannel() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return;

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'pawcare_reminders',
        'Pet Reminders',
        description:
            'Notifications for pet feeding, medication, walks, and care tasks',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('Error creating Android notification channel: $e');
    }
  }

  /// Request permissions across Android (13+ notifications & exact alarms), iOS, and macOS.
  Future<bool> requestPermissions() async {
    if (_permissionsRequested) return true;
    _permissionsRequested = true;

    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        // Request POST_NOTIFICATIONS (Android 13+)
        await androidPlugin?.requestNotificationsPermission();

        // Request SCHEDULE_EXACT_ALARM (Android 12+)
        await androidPlugin?.requestExactAlarmsPermission();
        return true;
      } else if (Platform.isIOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      } else if (Platform.isMacOS) {
        final macPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();
        final granted = await macPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Notification permissions request error: $e');
    }

    return false;
  }

  /// Schedule a pet reminder notification both in-memory (for foreground)
  /// and natively with OS exact alarm (for background/terminated state).
  Future<void> scheduleReminderNotification(
    Reminder reminder,
    String petName,
  ) async {
    if (!reminder.notificationEnabled) {
      await cancelReminderNotification(reminder.id, reminder.notificationId);
      return;
    }

    if (!_initialized) {
      await init();
    }

    final now = DateTime.now();
    DateTime scheduledDate = reminder.scheduledTime;

    // Handle past scheduled times for repeating reminders
    final repeat = reminder.repeat.toLowerCase();
    if (scheduledDate.isBefore(now)) {
      if (repeat == 'daily') {
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      } else if (repeat == 'weekly') {
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }
      } else if (repeat == 'monthly') {
        while (scheduledDate.isBefore(now)) {
          scheduledDate = DateTime(
            scheduledDate.year,
            scheduledDate.month + 1,
            scheduledDate.day,
            scheduledDate.hour,
            scheduledDate.minute,
          );
        }
      }
    }

    // --- 1. FOREGROUND IN-APP TIMER ---
    _activeTimers[reminder.id]?.cancel();

    final timeDifference = scheduledDate.difference(now);
    final inAppDelay = timeDifference.isNegative
        ? const Duration(seconds: 1)
        : timeDifference;

    _activeTimers[reminder.id] = Timer(inAppDelay, () {
      _triggeredRemindersController.add(reminder);
      _activeTimers.remove(reminder.id);

      // If the user has the app open in foreground when the alert fires,
      // cancel the native OS notification tray icon so there is no duplicate alert.
      if (_isAppInForeground && !kIsWeb) {
        _notificationsPlugin.cancel(id: reminder.notificationId);
      }
    });

    // --- 2. NATIVE SCHEDULED OS NOTIFICATION ---
    if (!kIsWeb) {
      // Don't schedule one-time reminders that are far in the past
      if (repeat == 'once' &&
          scheduledDate.isBefore(now.subtract(const Duration(minutes: 1)))) {
        return;
      }

      try {
        final payload = jsonEncode({
          'reminderId': reminder.id,
          'petId': reminder.petId,
        });

        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'pawcare_reminders',
          'Pet Reminders',
          channelDescription:
              'Notifications for pet feeding, medication, walks, and care tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.reminder,
          ticker: 'Pet Care Reminder',
        );

        const DarwinNotificationDetails darwinDetails =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'pawcare_reminders',
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

        DateTimeComponents? matchComponents;
        if (repeat == 'daily') {
          matchComponents = DateTimeComponents.time;
        } else if (repeat == 'weekly') {
          matchComponents = DateTimeComponents.dayOfWeekAndTime;
        } else if (repeat == 'monthly') {
          matchComponents = DateTimeComponents.dayOfMonthAndTime;
        }

        // Try scheduling with exact alarm first
        try {
          await _notificationsPlugin.zonedSchedule(
            id: reminder.notificationId,
            title: 'PawCare Reminder 🐾',
            body: 'Time for ${reminder.title} for $petName!',
            scheduledDate: tzScheduled,
            notificationDetails: platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: matchComponents,
            payload: payload,
          );
        } catch (exactAlarmException) {
          // Graceful fallback for Android 12/14 if exact alarms are disallowed
          debugPrint(
            'Exact alarm scheduling fallback: $exactAlarmException. Using inexactAllowWhileIdle.',
          );
          await _notificationsPlugin.zonedSchedule(
            id: reminder.notificationId,
            title: 'PawCare Reminder 🐾',
            body: 'Time for ${reminder.title} for $petName!',
            scheduledDate: tzScheduled,
            notificationDetails: platformDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: matchComponents,
            payload: payload,
          );
        }
      } catch (e) {
        debugPrint('Error in native reminder zonedSchedule: $e');
      }
    }
  }

  /// Cancels an existing scheduled notification and its in-memory timer
  Future<void> cancelReminderNotification(
    String reminderId, [
    int? notificationId,
  ]) async {
    _activeTimers[reminderId]?.cancel();
    _activeTimers.remove(reminderId);

    if (!kIsWeb) {
      try {
        final idToCancel =
            notificationId ?? (reminderId.hashCode.abs() % 100000);
        await _notificationsPlugin.cancel(id: idToCancel);
      } catch (e) {
        debugPrint('Error canceling notification: $e');
      }
    }
  }

  /// Reschedules an existing reminder
  Future<void> rescheduleReminderNotification(
    Reminder reminder,
    String petName,
  ) async {
    await cancelReminderNotification(reminder.id, reminder.notificationId);
    await scheduleReminderNotification(reminder, petName);
  }

  /// Cancels all active reminders and notifications
  Future<void> cancelAllNotifications() async {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();

    if (!kIsWeb) {
      try {
        await _notificationsPlugin.cancelAll();
      } catch (e) {
        debugPrint('Error cancelling all notifications: $e');
      }
    }
  }

  /// Internal handler for user tapping a system notification
  void _handleNotificationResponse(NotificationResponse response) {
    final payloadStr = response.payload;
    if (payloadStr != null && payloadStr.isNotEmpty) {
      try {
        final dynamic data = jsonDecode(payloadStr);
        if (data is Map<String, dynamic>) {
          final reminderId = data['reminderId']?.toString() ?? '';
          final petId = data['petId']?.toString() ?? '';
          if (reminderId.isNotEmpty) {
            _notificationTapController.add({
              'reminderId': reminderId,
              'petId': petId,
            });
          }
        }
      } catch (e) {
        debugPrint('Error parsing notification response payload: $e');
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _triggeredRemindersController.close();
    _notificationTapController.close();
  }
}
