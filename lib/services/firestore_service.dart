import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../models/health_record_model.dart';
import '../models/post_model.dart';
import '../models/adoption_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/care_history_model.dart';
import '../firebase_options.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _isMock {
    try {
      return DefaultFirebaseOptions.currentPlatform.apiKey.contains('Mock');
    } catch (_) {
      return true;
    }
  }

  // --- SharedPreferences Keys ---
  static const String _prefsPetsKey = 'pawcare_mock_pets';
  static const String _prefsRemindersKey = 'pawcare_mock_reminders';
  static const String _prefsHealthRecordsKey = 'pawcare_mock_health_records';
  static const String _prefsPostsKey = 'pawcare_mock_posts';
  static const String _prefsAdoptionsKey = 'pawcare_mock_adoptions';
  static const String _prefsOrdersKey = 'pawcare_mock_orders';
  static const String _prefsCartKey = 'pawcare_mock_cart';
  static const String _prefsActivePetIdKey = 'pawcare_active_pet_id';
  static const String _prefsCareHistoryKey = 'pawcare_mock_care_history';

  // --- Default Static Mock Seeds ---
  final List<Pet> _defaultMockPets = [
    Pet(
      id: 'pet_bruno_1',
      ownerId: 'default_user',
      name: 'Bruno',
      species: 'dog',
      breed: 'Golden Retriever',
      age: 2.5,
      weightKg: 28.5,
      foodHabits: 'Royal Canin High Protein - Twice daily (8 AM, 7 PM)',
      medicalHistory: ['Fully Vaccinated', 'Deworming Up-to-Date', 'Sensitive Stomach'],
      avatarAsset: 'dog_hero',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    Pet(
      id: 'pet_luna_2',
      ownerId: 'default_user',
      name: 'Luna',
      species: 'cat',
      breed: 'Persian',
      age: 1.2,
      weightKg: 4.1,
      foodHabits: 'Whiskas Wet Salmon pate + Dry Kibble',
      medicalHistory: ['Neutered / Spayed', 'Ear Infection Prone'],
      avatarAsset: 'cat_hero',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  final List<Reminder> _defaultMockReminders = [
    Reminder(
      id: 'rem_1',
      petId: 'pet_bruno_1',
      type: 'feeding',
      title: 'Morning Breakfast & Kibble',
      notes: '1.5 cups dry kibble + fresh warm water',
      scheduledTime: DateTime.now().copyWith(hour: 8, minute: 30),
      repeat: 'daily',
      isCompleted: true,
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Reminder(
      id: 'rem_2',
      petId: 'pet_bruno_1',
      type: 'medication',
      title: 'Probiotic Supplement',
      notes: '1 chewable tablet after breakfast for digestive care',
      scheduledTime: DateTime.now().copyWith(hour: 10, minute: 0),
      repeat: 'daily',
      isCompleted: false,
    ),
    Reminder(
      id: 'rem_3',
      petId: 'pet_bruno_1',
      type: 'grooming',
      title: 'Evening Coat Brushing',
      notes: 'Undercoat comb session to prevent hair matting',
      scheduledTime: DateTime.now().copyWith(hour: 18, minute: 0),
      repeat: 'daily',
      isCompleted: false,
    ),
    Reminder(
      id: 'rem_4',
      petId: 'pet_bruno_1',
      type: 'vaccination',
      title: 'Annual Rabies Booster',
      notes: 'Apollo Pet Clinic - Dr. Ramesh',
      scheduledTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
      repeat: 'once',
      isCompleted: false,
    ),
    Reminder(
      id: 'rem_5',
      petId: 'pet_bruno_1',
      type: 'checkup',
      title: 'Routine Dental Inspection',
      notes: 'Check rear molars and tartar build up',
      scheduledTime: DateTime.now().add(const Duration(days: 5, hours: 4)),
      repeat: 'once',
      isCompleted: false,
    ),
  ];

  final List<HealthRecord> _defaultMockHealthRecords = [
    HealthRecord(
      id: 'hr_1',
      petId: 'pet_bruno_1',
      type: 'vaccination',
      title: 'DHPP booster vaccine',
      description: 'Annual core 5-in-1 vaccine completed. Next booster due in 1 year.',
      date: DateTime.now().subtract(const Duration(days: 90)),
      veterinarianName: 'Dr. Ramesh Kumar',
      weightKg: 27.2,
      temperatureCelsius: 38.6,
    ),
    HealthRecord(
      id: 'hr_2',
      petId: 'pet_bruno_1',
      type: 'prescription',
      title: 'Deworming & Tick pill',
      description: 'Oral chewable tablet for tick/flea treatment. Follow monthly schedule.',
      date: DateTime.now().subtract(const Duration(days: 15)),
      veterinarianName: 'Dr. Ramesh Kumar',
      weightKg: 28.4,
      temperatureCelsius: 38.4,
    ),
  ];

  final List<CommunityPost> _defaultMockPosts = [
    CommunityPost(
      id: 'post_1',
      ownerName: 'Varshini',
      ownerAvatar: 'V',
      imagePath: 'assets/images/dog_beach_play.jpg',
      caption: 'Bruno enjoys his morning splash on the beach! 🐾🌊☀️',
      likes: 18,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      comments: ['Cute golden!', 'Look at that happy face!', 'Amazing energy!'],
    ),
    CommunityPost(
      id: 'post_2',
      ownerName: 'Dr. Ramesh Kumar',
      ownerAvatar: 'R',
      imagePath: 'assets/images/cat_dog_friends.jpg',
      caption: 'Quick tip: Early socialization between kittens and puppies builds lifelong best friends like these two! 🐱🐶',
      likes: 42,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      comments: ['Super helpful, doc!', 'Such a heartwarming photo.', 'Best buddies!'],
    ),
    CommunityPost(
      id: 'post_3',
      ownerName: 'PawCare Nutrition Team',
      ownerAvatar: 'N',
      imagePath: 'assets/images/pet_feeding_routine.jpg',
      caption: 'Healthy habits start with consistent portions! Measuring kibble prevents overfeeding and supports steady digestion all day long 🥣✨',
      likes: 29,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      comments: ['Great reminder!', 'Portion control made a huge difference for my pet.'],
    ),
  ];

  final List<AdoptionListing> _defaultMockAdoptions = [
    AdoptionListing(
      id: 'adopt_1',
      petName: 'Milo',
      species: 'dog',
      breed: 'Beagle puppy',
      age: '4 months',
      location: 'Koramangala Shelter, Bangalore',
      description: 'Super friendly, vaccines current, loves kids and treats.',
      shelterName: 'Paws Haven NGO',
      contactPhone: '+919876543210',
    ),
    AdoptionListing(
      id: 'adopt_2',
      petName: 'Bella',
      species: 'cat',
      breed: 'Domestic Shorthair',
      age: '1 year',
      location: 'Indiranagar Cat Rescue',
      description: 'Loves window seats and playing with string toys.',
      shelterName: 'Indie Rescue Bangalore',
      contactPhone: '+919876543211',
    ),
  ];

  final List<CareHistory> _defaultMockCareHistory = [
    CareHistory(
      id: 'ch_1',
      petId: 'pet_bruno_1',
      reminderId: 'rem_1',
      activityType: 'feeding',
      title: 'Morning Breakfast & Kibble',
      description: '1.5 cups dry kibble + fresh warm water consumed happily.',
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CareHistory(
      id: 'ch_2',
      petId: 'pet_bruno_1',
      reminderId: null,
      activityType: 'walking',
      title: 'Morning Park Walk',
      description: '30 min walk around the neighborhood. Very active and energetic.',
      completedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    CareHistory(
      id: 'ch_3',
      petId: 'pet_bruno_1',
      reminderId: null,
      activityType: 'grooming',
      title: 'Undercoat Brushing',
      description: 'Groomed coat thoroughly, shed hair removed.',
      completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    CareHistory(
      id: 'ch_4',
      petId: 'pet_luna_2',
      reminderId: null,
      activityType: 'feeding',
      title: 'Salmon Pate Meal',
      description: 'Whiskas wet salmon food finished completely.',
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    CareHistory(
      id: 'ch_5',
      petId: 'pet_luna_2',
      reminderId: null,
      activityType: 'litter_cleaning',
      title: 'Litter Box Cleaning',
      description: 'Litter scooped and refreshed with fresh clumping sand.',
      completedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // --- Serialization Helpers ---

  Future<List<Pet>> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsPetsKey);
    if (data == null) {
      final list = List<Pet>.from(_defaultMockPets);
      await _savePets(list);
      return list;
    }
    final List decoded = json.decode(data);
    return decoded.map((item) => Pet.fromMap(item, item['id'] ?? '')).toList();
  }

  Future<void> _savePets(List<Pet> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((p) {
      final map = p.toMap();
      map['createdAt'] = p.createdAt.toIso8601String();
      map['birthdate'] = p.birthdate.toIso8601String();
      return map;
    }).toList();
    await prefs.setString(_prefsPetsKey, json.encode(serialized));
  }

  Future<List<Reminder>> _loadReminders(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsRemindersKey);
    final List<Reminder> allReminders;
    if (data == null) {
      allReminders = List<Reminder>.from(_defaultMockReminders);
      await _saveReminders(allReminders);
    } else {
      final List decoded = json.decode(data);
      allReminders = decoded.map((item) => Reminder.fromMap(item, item['id'] ?? '')).toList();
    }
    return petId.isEmpty ? allReminders : allReminders.where((r) => r.petId == petId).toList();
  }

  Future<void> _saveReminders(List<Reminder> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((r) {
      final map = r.toMap();
      map['scheduledTime'] = r.scheduledTime.toIso8601String();
      map['completedAt'] = r.completedAt?.toIso8601String();
      map['createdAt'] = r.createdAt.toIso8601String();
      map['updatedAt'] = r.updatedAt.toIso8601String();
      return map;
    }).toList();
    await prefs.setString(_prefsRemindersKey, json.encode(serialized));
  }

  Future<List<HealthRecord>> _loadAllHealthRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsHealthRecordsKey);
    if (data == null) {
      final list = List<HealthRecord>.from(_defaultMockHealthRecords);
      await _saveHealthRecords(list);
      return list;
    }
    final List decoded = json.decode(data);
    return decoded.map((item) => HealthRecord.fromMap(item, item['id'] ?? '')).toList();
  }

  Future<void> _saveHealthRecords(List<HealthRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((hr) {
      final map = hr.toMap();
      map['date'] = hr.date.toIso8601String();
      map['createdAt'] = hr.createdAt.toIso8601String();
      map['updatedAt'] = hr.updatedAt.toIso8601String();
      return map;
    }).toList();
    await prefs.setString(_prefsHealthRecordsKey, json.encode(serialized));
  }

  Future<List<CareHistory>> _loadCareHistory(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsCareHistoryKey);
    final List<CareHistory> allHistory;
    if (data == null) {
      allHistory = List<CareHistory>.from(_defaultMockCareHistory);
      await _saveCareHistory(allHistory);
    } else {
      final List decoded = json.decode(data);
      allHistory = decoded.map((item) => CareHistory.fromMap(item, item['id'] ?? '')).toList();
    }
    return petId.isEmpty ? allHistory : allHistory.where((c) => c.petId == petId).toList();
  }

  Future<void> _saveCareHistory(List<CareHistory> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((c) {
      final map = c.toMap();
      map['completedAt'] = c.completedAt.toIso8601String();
      map['createdAt'] = c.createdAt.toIso8601String();
      return map;
    }).toList();
    await prefs.setString(_prefsCareHistoryKey, json.encode(serialized));
  }

  Future<List<CommunityPost>> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsPostsKey);
    if (data == null) {
      final list = List<CommunityPost>.from(_defaultMockPosts);
      await _savePosts(list);
      return list;
    }
    final List decoded = json.decode(data);
    return decoded.map((item) => CommunityPost.fromMap(item, item['id'] ?? '')).toList();
  }

  Future<void> _savePosts(List<CommunityPost> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((p) {
      final map = p.toMap();
      map['createdAt'] = p.createdAt.toIso8601String();
      return map;
    }).toList();
    await prefs.setString(_prefsPostsKey, json.encode(serialized));
  }

  Future<List<AdoptionListing>> _loadAdoptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsAdoptionsKey);
    if (data == null) {
      final list = List<AdoptionListing>.from(_defaultMockAdoptions);
      await _saveAdoptions(list);
      return list;
    }
    final List decoded = json.decode(data);
    return decoded.map((item) => AdoptionListing.fromMap(item, item['id'] ?? '')).toList();
  }

  Future<void> _saveAdoptions(List<AdoptionListing> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((a) => a.toMap()).toList();
    await prefs.setString(_prefsAdoptionsKey, json.encode(serialized));
  }

  Future<List<OrderRecord>> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsOrdersKey);
    if (data == null) {
      return [];
    }
    final List decoded = json.decode(data);
    return decoded.map((item) => OrderRecord.fromMap(item, item['id'] ?? '')).toList();
  }

  Future<void> _saveOrders(List<OrderRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((ord) {
      final map = ord.toMap();
      map['orderDate'] = ord.orderDate.toIso8601String();
      return map;
    }).toList();
    await prefs.setString(_prefsOrdersKey, json.encode(serialized));
  }

  Future<List<MarketplaceProduct>> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsCartKey);
    if (data == null) {
      return [];
    }
    final List decoded = json.decode(data);
    return decoded.map((item) => MarketplaceProduct.fromMap(item, item['id'] ?? '')).toList();
  }

  Future<void> _saveCart(List<MarketplaceProduct> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((item) => item.toMap()).toList();
    await prefs.setString(_prefsCartKey, json.encode(serialized));
  }

  // --- PET CRUD ---

  Stream<List<Pet>> getPetsStream(String ownerId) {
    if (_isMock) {
      return Stream.fromFuture(_loadPets());
    }
    try {
      final db = _db;
      if (db == null) return Stream.fromFuture(_loadPets());
      return db
          .collection('pets')
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return _defaultMockPets;
            return snapshot.docs.map((doc) => Pet.fromMap(doc.data(), doc.id)).toList();
          });
    } catch (_) {
      return Stream.fromFuture(_loadPets());
    }
  }

  Future<List<Pet>> getPetsOnce(String ownerId) async {
    if (_isMock) {
      return _loadPets();
    }
    try {
      final db = _db;
      if (db == null) return _loadPets();
      final snapshot = await db.collection('pets').get();
      if (snapshot.docs.isEmpty) return _loadPets();
      return snapshot.docs.map((doc) => Pet.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return _loadPets();
    }
  }

  Future<void> addPet(Pet pet) async {
    if (_isMock) {
      final list = await _loadPets();
      list.add(pet);
      await _savePets(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadPets();
        list.add(pet);
        await _savePets(list);
        return;
      }
      final docRef = db.collection('pets').doc();
      final newPet = pet.copyWith(id: docRef.id);
      await docRef.set(newPet.toMap());
    } catch (_) {
      final list = await _loadPets();
      list.add(pet);
      await _savePets(list);
    }
  }

  Future<void> updatePet(Pet pet) async {
    if (_isMock) {
      final list = await _loadPets();
      final index = list.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        list[index] = pet;
        await _savePets(list);
      }
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadPets();
        final index = list.indexWhere((p) => p.id == pet.id);
        if (index != -1) {
          list[index] = pet;
          await _savePets(list);
        }
        return;
      }
      await db.collection('pets').doc(pet.id).update(pet.toMap());
    } catch (_) {
      final list = await _loadPets();
      final index = list.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        list[index] = pet;
        await _savePets(list);
      }
    }
  }

  Future<void> deletePet(String petId) async {
    if (_isMock) {
      final list = await _loadPets();
      list.removeWhere((p) => p.id == petId);
      await _savePets(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadPets();
        list.removeWhere((p) => p.id == petId);
        await _savePets(list);
        return;
      }
      await db.collection('pets').doc(petId).delete();
    } catch (_) {
      final list = await _loadPets();
      list.removeWhere((p) => p.id == petId);
      await _savePets(list);
    }
  }

  Future<void> saveActivePetId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsActivePetIdKey, id);
  }

  Future<String?> loadActivePetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsActivePetIdKey);
  }

  // --- REMINDER CRUD ---

  Stream<List<Reminder>> getRemindersStream(String petId) {
    if (_isMock) {
      return Stream.fromFuture(_loadReminders(petId));
    }
    try {
      final db = _db;
      if (db == null) return Stream.fromFuture(_loadReminders(petId));
      return db
          .collection('reminders')
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs
                .map((doc) => Reminder.fromMap(doc.data(), doc.id))
                .where((r) => petId.isEmpty || r.petId == petId)
                .toList();
            return list.isEmpty ? _defaultMockReminders.where((r) => petId.isEmpty || r.petId == petId).toList() : list;
          });
    } catch (_) {
      return Stream.fromFuture(_loadReminders(petId));
    }
  }

  Future<List<Reminder>> getRemindersOnce(String petId) async {
    if (_isMock) {
      return _loadReminders(petId);
    }
    try {
      final db = _db;
      if (db == null) return _loadReminders(petId);
      final snapshot = await db.collection('reminders').get();
      final list = snapshot.docs
          .map((doc) => Reminder.fromMap(doc.data(), doc.id))
          .where((r) => petId.isEmpty || r.petId == petId)
          .toList();
      return list.isEmpty ? _loadReminders(petId) : list;
    } catch (_) {
      return _loadReminders(petId);
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    if (_isMock) {
      final list = await _loadReminders('');
      list.add(reminder);
      await _saveReminders(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadReminders('');
        list.add(reminder);
        await _saveReminders(list);
        return;
      }
      final docRef = db.collection('reminders').doc();
      final newReminder = reminder.copyWith(id: docRef.id);
      await docRef.set(newReminder.toMap());
    } catch (_) {
      final list = await _loadReminders('');
      list.add(reminder);
      await _saveReminders(list);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (_isMock) {
      final list = await _loadReminders('');
      final index = list.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        list[index] = reminder;
        await _saveReminders(list);
      }
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadReminders('');
        final index = list.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          list[index] = reminder;
          await _saveReminders(list);
        }
        return;
      }
      await db.collection('reminders').doc(reminder.id).update(reminder.toMap());
    } catch (_) {
      final list = await _loadReminders('');
      final index = list.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        list[index] = reminder;
        await _saveReminders(list);
      }
    }
  }

  Future<void> toggleReminderComplete(String reminderId, bool isCompleted) async {
    if (_isMock) {
      final list = await _loadReminders('');
      final index = list.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        list[index] = list[index].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        await _saveReminders(list);
      }
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadReminders('');
        final index = list.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          list[index] = list[index].copyWith(
            isCompleted: isCompleted,
            completedAt: isCompleted ? DateTime.now() : null,
          );
          await _saveReminders(list);
        }
        return;
      }
      await db.collection('reminders').doc(reminderId).update({
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? Timestamp.now() : null,
      });
    } catch (_) {
      final list = await _loadReminders('');
      final index = list.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        list[index] = list[index].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        await _saveReminders(list);
      }
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    if (_isMock) {
      final list = await _loadReminders('');
      list.removeWhere((r) => r.id == reminderId);
      await _saveReminders(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadReminders('');
        list.removeWhere((r) => r.id == reminderId);
        await _saveReminders(list);
        return;
      }
      await db.collection('reminders').doc(reminderId).delete();
    } catch (_) {
      final list = await _loadReminders('');
      list.removeWhere((r) => r.id == reminderId);
      await _saveReminders(list);
    }
  }

  // --- HEALTH RECORDS CRUD ---

  Future<List<HealthRecord>> getHealthRecordsOnce(String petId) async {
    if (_isMock) {
      final all = await _loadAllHealthRecords();
      return all.where((hr) => hr.petId == petId).toList();
    }
    try {
      final db = _db;
      if (db == null) {
        final all = await _loadAllHealthRecords();
        return all.where((hr) => hr.petId == petId).toList();
      }
      final snapshot = await db.collection('health_records').where('petId', isEqualTo: petId).get();
      return snapshot.docs.map((doc) => HealthRecord.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      final all = await _loadAllHealthRecords();
      return all.where((hr) => hr.petId == petId).toList();
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    if (_isMock) {
      final list = await _loadAllHealthRecords();
      list.add(record);
      await _saveHealthRecords(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadAllHealthRecords();
        list.add(record);
        await _saveHealthRecords(list);
        return;
      }
      final docRef = db.collection('health_records').doc();
      final newRecord = record.copyWith(id: docRef.id);
      await docRef.set(newRecord.toMap());
    } catch (_) {
      final list = await _loadAllHealthRecords();
      list.add(record);
      await _saveHealthRecords(list);
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    if (_isMock) {
      final list = await _loadAllHealthRecords();
      final index = list.indexWhere((h) => h.id == record.id);
      if (index != -1) {
        list[index] = record;
        await _saveHealthRecords(list);
      }
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadAllHealthRecords();
        final index = list.indexWhere((h) => h.id == record.id);
        if (index != -1) {
          list[index] = record;
          await _saveHealthRecords(list);
        }
        return;
      }
      await db.collection('health_records').doc(record.id).update(record.toMap());
    } catch (_) {
      final list = await _loadAllHealthRecords();
      final index = list.indexWhere((h) => h.id == record.id);
      if (index != -1) {
        list[index] = record;
        await _saveHealthRecords(list);
      }
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    if (_isMock) {
      final list = await _loadAllHealthRecords();
      list.removeWhere((h) => h.id == recordId);
      await _saveHealthRecords(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadAllHealthRecords();
        list.removeWhere((h) => h.id == recordId);
        await _saveHealthRecords(list);
        return;
      }
      await db.collection('health_records').doc(recordId).delete();
    } catch (_) {
      final list = await _loadAllHealthRecords();
      list.removeWhere((h) => h.id == recordId);
      await _saveHealthRecords(list);
    }
  }

  // --- CARE HISTORY CRUD ---

  Stream<List<CareHistory>> getCareHistoryStream(String petId) {
    if (_isMock) {
      return Stream.fromFuture(_loadCareHistory(petId));
    }
    try {
      final db = _db;
      if (db == null) return Stream.fromFuture(_loadCareHistory(petId));
      return db
          .collection('care_history')
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs
                .map((doc) => CareHistory.fromMap(doc.data(), doc.id))
                .where((c) => petId.isEmpty || c.petId == petId)
                .toList();
            return list.isEmpty
                ? _defaultMockCareHistory.where((c) => petId.isEmpty || c.petId == petId).toList()
                : list;
          });
    } catch (_) {
      return Stream.fromFuture(_loadCareHistory(petId));
    }
  }

  Future<List<CareHistory>> getCareHistoryOnce(String petId) async {
    if (_isMock) {
      final list = await _loadCareHistory(petId);
      list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return list;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadCareHistory(petId);
        list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        return list;
      }
      final snapshot = await db.collection('care_history').where('petId', isEqualTo: petId).get();
      if (snapshot.docs.isEmpty) {
        final list = await _loadCareHistory(petId);
        list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        return list;
      }
      final list = snapshot.docs.map((doc) => CareHistory.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return list;
    } catch (_) {
      final list = await _loadCareHistory(petId);
      list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return list;
    }
  }

  Future<void> addCareHistory(CareHistory record) async {
    if (_isMock) {
      final list = await _loadCareHistory('');
      list.insert(0, record);
      await _saveCareHistory(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadCareHistory('');
        list.insert(0, record);
        await _saveCareHistory(list);
        return;
      }
      final docRef = db.collection('care_history').doc();
      final newRecord = record.copyWith(id: docRef.id);
      await docRef.set(newRecord.toMap());
    } catch (_) {
      final list = await _loadCareHistory('');
      list.insert(0, record);
      await _saveCareHistory(list);
    }
  }

  Future<void> deleteCareHistory(String historyId) async {
    if (_isMock) {
      final list = await _loadCareHistory('');
      list.removeWhere((c) => c.id == historyId);
      await _saveCareHistory(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadCareHistory('');
        list.removeWhere((c) => c.id == historyId);
        await _saveCareHistory(list);
        return;
      }
      await db.collection('care_history').doc(historyId).delete();
    } catch (_) {
      final list = await _loadCareHistory('');
      list.removeWhere((c) => c.id == historyId);
      await _saveCareHistory(list);
    }
  }

  // --- SOCIAL POSTS CRUD ---

  Future<List<CommunityPost>> getPostsOnce() async {
    if (_isMock) {
      return _loadPosts();
    }
    try {
      final db = _db;
      if (db == null) return _loadPosts();
      final snapshot = await db.collection('posts').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => CommunityPost.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return _loadPosts();
    }
  }

  Future<void> addPost(CommunityPost post) async {
    if (_isMock) {
      final list = await _loadPosts();
      list.insert(0, post);
      await _savePosts(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadPosts();
        list.insert(0, post);
        await _savePosts(list);
        return;
      }
      final docRef = db.collection('posts').doc();
      final newPost = post.copyWith(id: docRef.id);
      await docRef.set(newPost.toMap());
    } catch (_) {
      final list = await _loadPosts();
      list.insert(0, post);
      await _savePosts(list);
    }
  }

  Future<void> updatePost(CommunityPost post) async {
    if (_isMock) {
      final list = await _loadPosts();
      final index = list.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        list[index] = post;
        await _savePosts(list);
      }
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadPosts();
        final index = list.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          list[index] = post;
          await _savePosts(list);
        }
        return;
      }
      await db.collection('posts').doc(post.id).update(post.toMap());
    } catch (_) {
      final list = await _loadPosts();
      final index = list.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        list[index] = post;
        await _savePosts(list);
      }
    }
  }

  // --- ADOPTION CRUD ---

  Future<List<AdoptionListing>> getAdoptionsOnce() async {
    if (_isMock) {
      return _loadAdoptions();
    }
    try {
      final db = _db;
      if (db == null) return _loadAdoptions();
      final snapshot = await db.collection('adoptions').get();
      return snapshot.docs.map((doc) => AdoptionListing.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return _loadAdoptions();
    }
  }

  Future<void> addAdoptionListing(AdoptionListing listing) async {
    if (_isMock) {
      final list = await _loadAdoptions();
      list.insert(0, listing);
      await _saveAdoptions(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadAdoptions();
        list.insert(0, listing);
        await _saveAdoptions(list);
        return;
      }
      final docRef = db.collection('adoptions').doc();
      final newListing = listing.copyWith(id: docRef.id);
      await docRef.set(newListing.toMap());
    } catch (_) {
      final list = await _loadAdoptions();
      list.insert(0, listing);
      await _saveAdoptions(list);
    }
  }

  // --- ORDER CRUD ---

  Future<List<OrderRecord>> getOrdersOnce() async {
    if (_isMock) {
      return _loadOrders();
    }
    try {
      final db = _db;
      if (db == null) return _loadOrders();
      final snapshot = await db.collection('orders').get();
      return snapshot.docs.map((doc) => OrderRecord.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return _loadOrders();
    }
  }

  Future<void> addOrder(OrderRecord order) async {
    if (_isMock) {
      final list = await _loadOrders();
      list.insert(0, order);
      await _saveOrders(list);
      return;
    }
    try {
      final db = _db;
      if (db == null) {
        final list = await _loadOrders();
        list.insert(0, order);
        await _saveOrders(list);
        return;
      }
      final docRef = db.collection('orders').doc();
      final newOrder = order.copyWith(id: docRef.id);
      await docRef.set(newOrder.toMap());
    } catch (_) {
      final list = await _loadOrders();
      list.insert(0, order);
      await _saveOrders(list);
    }
  }

  // --- CART CRUD ---

  Future<List<MarketplaceProduct>> getCartOnce() async {
    return _loadCart();
  }

  Future<void> saveCart(List<MarketplaceProduct> items) async {
    await _saveCart(items);
  }
}
