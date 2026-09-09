import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/health_record_provider.dart';
import 'providers/activity_tracker_provider.dart';
import 'providers/ecosystem_provider.dart';
import 'providers/care_history_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/ecosystem_tabs_hub.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/reminders/add_reminder_screen.dart';
import 'screens/pet_profile/add_pet_screen.dart';
import 'screens/pet_profile/my_pets_screen.dart';
import 'screens/pet_profile/pet_profile_hub_screen.dart';
import 'screens/vet/emergency_vet_screen.dart';
import 'screens/customers/customers_list_screen.dart';
import 'screens/services/services_hub_screen.dart';
import 'screens/services/care_schedule_screen.dart';
import 'screens/shop/cart_screen.dart';
import 'screens/shop/orders_list_screen.dart';
import 'screens/social/adoption_listings_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

/// Global navigator key to allow background notification taps to navigate cleanly
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Gracefully handle if Firebase isn't pre-configured; app uses local persistence fallback
  }

  // Initialize native local notification service with timezone awareness & permissions
  try {
    final notifService = NotificationService();
    await notifService.init();
    await notifService.requestPermissions();
  } catch (e) {
    debugPrint('Notification init error on startup: $e');
  }

  runApp(const PawCareApp());
}

class PawCareApp extends StatefulWidget {
  const PawCareApp({super.key});

  @override
  State<PawCareApp> createState() => _PawCareAppState();
}

class _PawCareAppState extends State<PawCareApp> {
  StreamSubscription? _tapSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for notification tap events from system tray
    _tapSubscription = NotificationService().notificationTaps.listen((payload) {
      if (!mounted) return;
      final petId = payload['petId'];
      final navContext = appNavigatorKey.currentContext;

      if (navContext != null && navContext.mounted && petId != null && petId.isNotEmpty) {
        try {
          final petProvider = Provider.of<PetProvider>(navContext, listen: false);
          petProvider.selectPetById(petId);
        } catch (_) {}
      }

      if (appNavigatorKey.currentState != null) {
        appNavigatorKey.currentState!.pushNamed('/notifications');
      }
    });
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => CareHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ActivityTrackerProvider()),
        ChangeNotifierProvider(create: (_) => EcosystemProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/hub': (context) => const EcosystemTabsHub(),
          '/notifications': (context) => const NotificationsScreen(),
          '/add-reminder': (context) => const AddReminderScreen(),
          '/add-pet': (context) => const AddPetScreen(),
          '/my-pets': (context) => const MyPetsScreen(),
          '/pet-hub': (context) => const PetProfileHubScreen(),
          '/emergency-vet': (context) => const EmergencyVetScreen(),
          '/customers': (context) => const CustomersListScreen(),
          '/services': (context) => const ServicesHubScreen(),
          '/care-schedule': (context) => const CareScheduleScreen(),
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => const OrdersListScreen(),
          '/adoptions': (context) => const AdoptionListingsScreen(),
        },
      ),
    );
  }
}
