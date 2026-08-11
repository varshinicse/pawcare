import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/models/pet_model.dart';
import 'package:petcare/services/recommendation_engine.dart';

void main() {
  group('RecommendationEngine Rule Evaluation Tests', () {
    test('Golden Retriever joint rule test', () {
      final pet = Pet(
        id: '1',
        ownerId: 'u1',
        name: 'Bruno',
        species: 'dog',
        breed: 'Golden Retriever',
        age: 3.0,
        weightKg: 30.0,
        foodHabits: 'Kibble',
        medicalHistory: [],
        avatarAsset: 'dog_hero',
        createdAt: DateTime.now(),
      );

      final rec = RecommendationEngine.getSuggestion(pet);
      expect(rec.ruleId, equals('rule_retriever_joint'));
      expect(rec.category, equals('grooming'));
    });

    test('Labrador diet rule test', () {
      final pet = Pet(
        id: '2',
        ownerId: 'u1',
        name: 'Max',
        species: 'dog',
        breed: 'Labrador Retriever',
        age: 2.0,
        weightKg: 28.0,
        foodHabits: 'Double kibble',
        medicalHistory: [],
        avatarAsset: 'dog_hero',
        createdAt: DateTime.now(),
      );

      final rec = RecommendationEngine.getSuggestion(pet);
      expect(rec.ruleId, equals('rule_lab_diet'));
      expect(rec.category, equals('diet'));
    });

    test('Puppy vaccination rule test for young canine', () {
      final pet = Pet(
        id: '3',
        ownerId: 'u1',
        name: 'Charlie',
        species: 'dog',
        breed: 'Beagle',
        age: 0.4,
        weightKg: 4.5,
        foodHabits: 'Puppy formula',
        medicalHistory: [],
        avatarAsset: 'dog_hero',
        createdAt: DateTime.now(),
      );

      final rec = RecommendationEngine.getSuggestion(pet);
      expect(rec.ruleId, equals('rule_puppy_vax'));
      expect(rec.category, equals('vaccination'));
    });

    test('Senior bloodwork rule test for pet older than 7 years', () {
      final pet = Pet(
        id: '4',
        ownerId: 'u1',
        name: 'Rocky',
        species: 'dog',
        breed: 'Poodle',
        age: 9.0,
        weightKg: 12.0,
        foodHabits: 'Senior kibble',
        medicalHistory: [],
        avatarAsset: 'dog_hero',
        createdAt: DateTime.now(),
      );

      final rec = RecommendationEngine.getSuggestion(pet);
      expect(rec.ruleId, equals('rule_senior_bloodwork'));
      expect(rec.category, equals('checkup'));
    });
  });
}
