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
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/ecosystem_tabs_hub.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/reminders/add_reminder_screen.dart';
import 'screens/pet_profile/add_pet_screen.dart';
import 'screens/vet/emergency_vet_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

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

  // Initialize local notifications
  try {
    await NotificationService().init();
  } catch (_) {}

  runApp(const PawCareApp());
}

class PawCareApp extends StatelessWidget {
  const PawCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => ActivityTrackerProvider()),
        ChangeNotifierProvider(create: (_) => EcosystemProvider()),
      ],
      child: MaterialApp(
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
          '/emergency-vet': (context) => const EmergencyVetScreen(),
        },
      ),
    );
  }
}
