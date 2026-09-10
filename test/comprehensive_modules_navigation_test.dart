import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:petcare/models/appointment_model.dart';
import 'package:petcare/models/customer_model.dart';
import 'package:petcare/models/pet_model.dart';
import 'package:petcare/models/service_item_model.dart';
import 'package:petcare/models/post_model.dart';
import 'package:petcare/models/adoption_model.dart';
import 'package:petcare/models/product_model.dart';
import 'package:petcare/providers/appointment_provider.dart';
import 'package:petcare/providers/auth_provider.dart';
import 'package:petcare/providers/care_history_provider.dart';
import 'package:petcare/providers/customer_provider.dart';
import 'package:petcare/providers/ecosystem_provider.dart';
import 'package:petcare/providers/health_record_provider.dart';
import 'package:petcare/providers/pet_provider.dart';
import 'package:petcare/providers/reminder_provider.dart';
import 'package:petcare/screens/customers/customer_details_screen.dart';
import 'package:petcare/screens/customers/customer_pets_screen.dart';
import 'package:petcare/screens/customers/customers_list_screen.dart';
import 'package:petcare/screens/services/appointment_details_screen.dart';
import 'package:petcare/screens/services/appointments_list_screen.dart';
import 'package:petcare/screens/services/care_schedule_screen.dart';
import 'package:petcare/screens/services/service_details_screen.dart';
import 'package:petcare/screens/services/services_list_screen.dart';
import 'package:petcare/screens/shop/cart_screen.dart';
import 'package:petcare/screens/shop/orders_list_screen.dart';
import 'package:petcare/screens/shop/product_detail_screen.dart';
import 'package:petcare/screens/social/adoption_details_screen.dart';
import 'package:petcare/screens/social/adoption_listings_screen.dart';
import 'package:petcare/screens/social/create_post_screen.dart';
import 'package:petcare/screens/social/post_details_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final samplePet = Pet(
    id: 'test_bruno_1',
    ownerId: 'owner_1',
    name: 'Bruno',
    species: 'dog',
    breed: 'Golden Retriever',
    age: 3.0,
    weightKg: 29.0,
    foodHabits: 'Dry kibbles twice a day',
    medicalHistory: ['Vaccinated DHPP'],
    avatarAsset: 'dog_hero',
    createdAt: DateTime.now(),
  );

  final sampleCustomer = Customer(
    id: 'cust_1',
    name: 'Varshini Parani',
    email: 'varshini@example.com',
    phone: '+91 98765 43210',
    address: 'Indiranagar, Bangalore',
    registeredPetIds: [samplePet.id],
    joinedDate: DateTime.now(),
  );

  final sampleService = ServiceItem.defaultCatalog.first;

  final sampleAppointment = ServiceAppointment(
    id: 'apt_test_1',
    serviceTitle: 'Full Spa Grooming',
    serviceCategory: 'Grooming',
    petId: samplePet.id,
    petName: samplePet.name,
    dateTime: DateTime.now().add(const Duration(days: 2)),
    price: 1299.0,
    status: 'Confirmed',
    clinicName: 'PawCare Indiranagar Salon',
    notes: 'Please be gentle with paws',
  );

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => CareHistoryProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => EcosystemProvider()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Module 2: Customers Workflow Tests', () {
    testWidgets('CustomersListScreen renders customer records and search bar', (tester) async {
      await tester.pumpWidget(createTestWidget(const CustomersListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pet Parents & Customers 👥'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('CustomerDetailsScreen renders profile, stats and pets button', (tester) async {
      await tester.pumpWidget(createTestWidget(CustomerDetailsScreen(customer: sampleCustomer)));
      await tester.pumpAndSettle();

      expect(find.text('Varshini Parani'), findsAtLeastNWidgets(1));
      expect(find.text('varshini@example.com'), findsOneWidget);
      expect(find.text('View Pets Flow'), findsOneWidget);
    });

    testWidgets('CustomerPetsScreen renders list of pets belonging to customer', (tester) async {
      await tester.pumpWidget(createTestWidget(CustomerPetsScreen(customer: sampleCustomer, pets: [samplePet])));
      await tester.pumpAndSettle();

      expect(find.text('Bruno'), findsOneWidget);
      expect(find.text('DOG • Golden Retriever'), findsOneWidget);
    });
  });

  group('Module 4: Care & Services Workflow Tests', () {
    testWidgets('ServicesListScreen renders services catalog with filters', (tester) async {
      await tester.pumpWidget(createTestWidget(const ServicesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Care & Services 🛁'), findsOneWidget);
      expect(find.text('Full Spa Grooming & Hydro-Bath'), findsOneWidget);
      expect(find.text('Grooming'), findsAtLeastNWidgets(1));
    });

    testWidgets('ServiceDetailsScreen renders description and booking CTA', (tester) async {
      await tester.pumpWidget(createTestWidget(ServiceDetailsScreen(service: sampleService)));
      await tester.pumpAndSettle();

      expect(find.text(sampleService.title), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);
      expect(find.text("What's Included"), findsOneWidget);
    });

    testWidgets('AppointmentsListScreen renders scheduled appointments', (tester) async {
      await tester.pumpWidget(createTestWidget(const AppointmentsListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('My Appointments 📅'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('AppointmentDetailsScreen renders details with reschedule button', (tester) async {
      await tester.pumpWidget(createTestWidget(AppointmentDetailsScreen(appointment: sampleAppointment)));
      await tester.pumpAndSettle();

      expect(find.text(sampleAppointment.serviceTitle), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);
      expect(find.text('Cancel Booking'), findsOneWidget);
    });

    testWidgets('CareScheduleScreen renders calendar schedule view', (tester) async {
      await tester.pumpWidget(createTestWidget(const CareScheduleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Care Schedule Calendar 📅'), findsOneWidget);
    });
  });

  group('Module 5: Social & Community Workflow Tests', () {
    testWidgets('CreatePostScreen renders category chips, pet tag and caption input', (tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePostScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Share a Pet Moment 📸'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('YOUR STORY'), findsOneWidget);
    });

    testWidgets('PostDetailsScreen renders full post with comment input', (tester) async {
      final post = CommunityPost(
        id: 'p_1',
        ownerName: 'Varshini',
        ownerAvatar: 'V',
        imagePath: '',
        caption: 'Bruno learned a new trick today!',
        likes: 12,
        createdAt: DateTime.now(),
        comments: ['Such a smart dog! 🐾'],
      );

      await tester.pumpWidget(createTestWidget(PostDetailsScreen(post: post)));
      await tester.pumpAndSettle();

      expect(find.text('Community Post 💬'), findsOneWidget);
      expect(find.text('Bruno learned a new trick today!'), findsOneWidget);
      expect(find.text('Such a smart dog! 🐾'), findsOneWidget);
    });

    testWidgets('AdoptionListingsScreen renders rescued pets list', (tester) async {
      await tester.pumpWidget(createTestWidget(const AdoptionListingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Adopt a Pet 🏡🐾'), findsOneWidget);
    });

    testWidgets('AdoptionDetailsScreen renders pet story and Apply CTA', (tester) async {
      final listing = AdoptionListing(
        id: 'ad_1',
        petName: 'Milo',
        species: 'dog',
        breed: 'Beagle puppy',
        age: '4 months',
        location: 'Koramangala, Bangalore',
        description: 'Playful and vaccinated.',
        shelterName: 'Koramangala Shelter',
        contactPhone: '+91 98765 43210',
      );

      await tester.pumpWidget(createTestWidget(AdoptionDetailsScreen(listing: listing)));
      await tester.pumpAndSettle();

      expect(find.text("Milo's Story 🐾"), findsOneWidget);
      expect(find.text('Apply to Adopt Milo 🐾'), findsOneWidget);
    });
  });

  group('Module 6: Shop & E-Commerce Workflow Tests', () {
    final sampleProduct = MarketplaceProduct(
      id: 'prod_test_1',
      title: 'Royal Canin Adult Dog Food (3kg)',
      category: 'food',
      description: 'Complete nutrition for adult dogs.',
      price: 1899.0,
      imagePath: 'assets/rc_golden.png',
      rating: 4.8,
    );

    testWidgets('ProductDetailScreen renders buy now and add to cart buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(ProductDetailScreen(product: sampleProduct)));
      await tester.pumpAndSettle();

      expect(find.text('Royal Canin Adult Dog Food (3kg)'), findsAtLeastNWidgets(1));
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
    });

    testWidgets('CartScreen renders empty cart state when no items', (tester) async {
      await tester.pumpWidget(createTestWidget(const CartScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Start Shopping'), findsOneWidget);
    });

    testWidgets('OrdersListScreen renders orders history view', (tester) async {
      await tester.pumpWidget(createTestWidget(const OrdersListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('My Orders 📦'), findsOneWidget);
    });
  });
}
