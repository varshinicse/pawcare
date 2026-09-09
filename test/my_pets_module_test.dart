import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petcare/models/pet_model.dart';
import 'package:petcare/models/health_record_model.dart';
import 'package:petcare/models/reminder_model.dart';
import 'package:petcare/models/care_history_model.dart';
import 'package:petcare/providers/care_history_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MY PETS Module End-to-End Logic Tests', () {
    test('Pet Model supports full profile and identity fields', () {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'owner_123',
        name: 'Bruno',
        species: 'dog',
        breed: 'Golden Retriever',
        age: 3.0,
        weightKg: 28.5,
        foodHabits: 'Royal Canin High Protein',
        medicalHistory: ['Fully Vaccinated'],
        avatarAsset: 'dog_hero',
        createdAt: DateTime.now(),
        ownerName: 'Varshini',
        ownerPhone: '+91 98765 43210',
        ownerEmail: 'varshini@example.com',
        allergies: ['Chicken', 'Flea drops'],
        specialCareInstructions: 'Needs gentle brush on undercoat',
        notes: 'Friendly with other dogs',
      );

      expect(pet.id, equals('pet_001'));
      expect(pet.ownerName, equals('Varshini'));
      expect(pet.allergies, contains('Chicken'));
      expect(pet.specialCareInstructions, contains('gentle brush'));

      final map = pet.toMap();
      expect(map['id'], equals('pet_001'));
      expect(map['ownerName'], equals('Varshini'));
      expect(map['allergies'], contains('Chicken'));

      final restored = Pet.fromMap(map, 'pet_001');
      expect(restored.name, equals('Bruno'));
      expect(restored.ownerPhone, equals('+91 98765 43210'));
    });

    test('Health Record connects to petId and preserves clinical details', () {
      final record = HealthRecord(
        id: 'hr_001',
        petId: 'pet_001',
        type: 'Vaccination',
        title: 'Rabies Annual Booster',
        description: 'Completed annual rabies vaccination without adverse reactions',
        date: DateTime.now(),
        veterinarianName: 'Dr. Ramesh Kumar',
        weightKg: 28.5,
        notes: 'Next booster due in 12 months',
      );

      expect(record.petId, equals('pet_001'));
      expect(record.recordType, equals('Vaccination'));
      expect(record.veterinarian, equals('Dr. Ramesh Kumar'));

      final map = record.toMap();
      final restored = HealthRecord.fromMap(map, 'hr_001');
      expect(restored.title, equals('Rabies Annual Booster'));
      expect(restored.weightKg, equals(28.5));
    });

    test('Automated Care History creation on Reminder completion', () async {
      final careHistoryProvider = CareHistoryProvider();

      final reminder = Reminder(
        id: 'rem_001',
        petId: 'pet_001',
        type: 'medication',
        title: 'Heartworm Chewable',
        notes: 'Given with morning food',
        scheduledTime: DateTime.now(),
        repeat: 'monthly',
        isCompleted: false,
      );

      // Record completion
      await careHistoryProvider.recordReminderCompletion(reminder, 'Bruno');

      final petHistory = careHistoryProvider.getHistoryForPet('pet_001');
      expect(petHistory.length, equals(1));
      expect(petHistory.first.reminderId, equals('rem_001'));
      expect(petHistory.first.activityType, equals('medication'));
      expect(petHistory.first.title, equals('Heartworm Chewable'));

      // Test duplicate prevention (calling complete again immediately)
      await careHistoryProvider.recordReminderCompletion(reminder, 'Bruno');
      final dedupedHistory = careHistoryProvider.getHistoryForPet('pet_001');
      expect(dedupedHistory.length, equals(1)); // Still 1! No duplicates!
    });

    test('Multi-pet isolation: Care history isolates strictly to matching petId', () async {
      final ch1 = CareHistory(
        id: 'ch_101',
        petId: 'pet_001',
        activityType: 'grooming',
        title: 'Bruno Brushing',
        completedAt: DateTime.now(),
      );

      final ch2 = CareHistory(
        id: 'ch_102',
        petId: 'pet_002',
        activityType: 'feeding',
        title: 'Luna Salmon Dinner',
        completedAt: DateTime.now(),
      );

      final careHistoryProvider = CareHistoryProvider();
      await careHistoryProvider.addCareHistory(ch1);
      await careHistoryProvider.addCareHistory(ch2);

      final brunoHistory = careHistoryProvider.getHistoryForPet('pet_001');
      final lunaHistory = careHistoryProvider.getHistoryForPet('pet_002');

      expect(brunoHistory.length, equals(1));
      expect(brunoHistory.first.title, equals('Bruno Brushing'));

      expect(lunaHistory.length, equals(1));
      expect(lunaHistory.first.title, equals('Luna Salmon Dinner'));
    });
  });
}
