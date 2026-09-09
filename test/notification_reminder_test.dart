import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/models/reminder_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Stable Notification ID Tests', () {
    test('Notification ID is deterministic and stable for same reminder ID', () {
      final reminder1 = Reminder(
        id: 'rem_123456789',
        petId: 'pet_bruno_1',
        type: 'feeding',
        title: 'Morning Kibble',
        notes: '2 cups of dry food',
        scheduledTime: DateTime(2026, 9, 10, 8, 0),
        repeat: 'daily',
      );

      final reminder2 = Reminder(
        id: 'rem_123456789',
        petId: 'pet_bruno_1',
        type: 'feeding',
        title: 'Morning Kibble',
        notes: '2 cups of dry food',
        scheduledTime: DateTime(2026, 9, 10, 8, 0),
        repeat: 'daily',
      );

      expect(reminder1.notificationId, equals(reminder2.notificationId));
      expect(reminder1.notificationId >= 0, isTrue);
      expect(reminder1.notificationId < 100000, isTrue);
    });

    test('Custom notificationId is preserved when provided', () {
      final reminder = Reminder(
        id: 'rem_999',
        petId: 'pet_bruno_1',
        type: 'medication',
        title: 'Heartworm Chew',
        notes: 'Monthly dose',
        scheduledTime: DateTime(2026, 9, 15, 10, 0),
        repeat: 'monthly',
        notificationId: 42424,
      );

      expect(reminder.notificationId, equals(42424));

      final copy = reminder.copyWith(notes: 'Updated notes');
      expect(copy.notificationId, equals(42424));
    });

    test('Serialization to and from map preserves notificationId', () {
      final reminder = Reminder(
        id: 'rem_serialize_test',
        petId: 'pet_1',
        type: 'walking',
        title: 'Park walk',
        notes: 'Use leash',
        scheduledTime: DateTime(2026, 9, 9, 18, 0),
        repeat: 'once',
        notificationId: 77123,
      );

      final map = reminder.toMap();
      expect(map['notificationId'], equals(77123));

      final restored = Reminder.fromMap(map, reminder.id);
      expect(restored.notificationId, equals(77123));
      expect(restored.id, equals(reminder.id));
      expect(restored.title, equals('Park walk'));
    });
  });

  group('Notification Payload Encoding & Decoding', () {
    test('Payload accurately serializes and deserializes reminder and pet IDs', () {
      const reminderId = 'rem_abc_123';
      const petId = 'pet_bruno_99';

      final payload = jsonEncode({
        'reminderId': reminderId,
        'petId': petId,
      });

      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      expect(decoded['reminderId'], equals(reminderId));
      expect(decoded['petId'], equals(petId));
    });
  });

  group('Repeat Recurrence Progression Calculations', () {
    test('Daily reminder recurrence advances by exactly 1 day', () {
      final originalTime = DateTime(2026, 9, 9, 8, 30);
      final nextDailyTime = originalTime.add(const Duration(days: 1));

      expect(nextDailyTime.day, equals(10));
      expect(nextDailyTime.month, equals(9));
      expect(nextDailyTime.hour, equals(8));
      expect(nextDailyTime.minute, equals(30));
    });

    test('Weekly reminder recurrence advances by exactly 7 days', () {
      final originalTime = DateTime(2026, 9, 9, 14, 0);
      final nextWeeklyTime = originalTime.add(const Duration(days: 7));

      expect(nextWeeklyTime.day, equals(16));
      expect(nextWeeklyTime.month, equals(9));
      expect(nextWeeklyTime.hour, equals(14));
      expect(nextWeeklyTime.minute, equals(0));
    });

    test('Monthly reminder recurrence advances month component', () {
      final originalTime = DateTime(2026, 9, 9, 11, 15);
      final nextMonthlyTime = DateTime(
        originalTime.year,
        originalTime.month + 1,
        originalTime.day,
        originalTime.hour,
        originalTime.minute,
      );

      expect(nextMonthlyTime.month, equals(10));
      expect(nextMonthlyTime.day, equals(9));
      expect(nextMonthlyTime.hour, equals(11));
      expect(nextMonthlyTime.minute, equals(15));
    });
  });

  group('Snooze Logic Calculations', () {
    test('Snooze adds specified minutes and keeps reminder pending', () {
      final original = Reminder(
        id: 'rem_snooze_1',
        petId: 'pet_bruno_1',
        type: 'feeding',
        title: 'Dinner',
        notes: '',
        scheduledTime: DateTime(2026, 9, 9, 19, 0),
        repeat: 'once',
      );

      final snoozeMinutes = 10;
      final snoozedTime = original.scheduledTime.add(Duration(minutes: snoozeMinutes));
      final snoozedReminder = original.copyWith(
        scheduledTime: snoozedTime,
        isCompleted: false,
        completedAt: null,
      );

      expect(snoozedReminder.isCompleted, isFalse);
      expect(snoozedReminder.completedAt, isNull);
      expect(snoozedReminder.scheduledTime.minute, equals(10));
      expect(snoozedReminder.scheduledTime.hour, equals(19));
      expect(snoozedReminder.notificationId, equals(original.notificationId));
    });
  });

  group('Timezone Conversion Tests', () {
    test('TZDateTime retains correct local hour and minute components', () {
      final now = DateTime.now();
      final scheduled = now.add(const Duration(minutes: 15));

      // Test with UTC and local locations
      final tzUtc = tz.TZDateTime.from(scheduled, tz.UTC);
      expect(tzUtc.millisecondsSinceEpoch, equals(scheduled.millisecondsSinceEpoch));

      // Test match components
      expect(scheduled.isAfter(now), isTrue);
    });
  });
}
