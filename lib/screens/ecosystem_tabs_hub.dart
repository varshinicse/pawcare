import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder_model.dart';
import '../providers/ecosystem_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/reminder_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'dashboard/dashboard_screen.dart';
import 'clinical/clinical_hub_screen.dart';
import 'ai_assistant/ai_hub_screen.dart';
import 'social/social_hub_screen.dart';
import 'shop/shop_hub_screen.dart';

class EcosystemTabsHub extends StatefulWidget {
  const EcosystemTabsHub({super.key});

  @override
  State<EcosystemTabsHub> createState() => _EcosystemTabsHubState();
}

class _EcosystemTabsHubState extends State<EcosystemTabsHub> {
  int _currentIndex = 0;
  StreamSubscription<Reminder>? _notificationSubscription;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ClinicalHubScreen(),
    AiHubScreen(),
    SocialHubScreen(),
    ShopHubScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // App-wide Real-Time Notification Stream Listener
    _notificationSubscription = NotificationService().triggeredReminders.listen((reminder) {
      if (mounted) {
        final petProvider = Provider.of<PetProvider>(context, listen: false);
        final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
        final activePet = petProvider.activePet;
        final petName = activePet?.name ?? 'your pet';

        // Refresh reminders list immediately so UI cards update
        if (activePet != null) {
          reminderProvider.fetchRemindersForPet(activePet.id);
        }

        // Show prominent real-time alert dialog across the application
        _showRealTimeReminderDialog(reminder, petName);
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _showRealTimeReminderDialog(Reminder reminder, String petName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: AppColors.creamBase,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.alertCoral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'PawCare Alert! ⏰',
                style: AppTypography.displaySmall.copyWith(fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Real-time reminder for $petName:',
                style: AppTypography.labelLarge.copyWith(color: AppColors.clayPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                reminder.title,
                style: AppTypography.displayMedium.copyWith(fontSize: 20, color: AppColors.inkText),
              ),
              if (reminder.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reminder.notes,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Snooze',
                style: AppTypography.labelLarge.copyWith(color: AppColors.softTaupe),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mossAccent,
              ),
              onPressed: () {
                final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                reminderProvider.toggleReminderComplete(reminder, petName);
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Awesome! Reminder "${reminder.title}" marked as done! 🎉'),
                    backgroundColor: AppColors.mossAccent,
                  ),
                );
              },
              child: const Text('Mark Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final cartCount = ecoProvider.cart.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.dividerColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.clayPrimary,
          unselectedItemColor: AppColors.softTaupe,
          selectedLabelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 10),
          unselectedLabelStyle: AppTypography.labelMedium.copyWith(fontSize: 10),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'DASHBOARD',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety_rounded),
              label: 'HEALTH CARD',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'AI CENTER',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.forum_rounded),
              label: 'SOCIAL',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(cartCount.toString()),
                isLabelVisible: cartCount > 0,
                backgroundColor: AppColors.alertCoral,
                child: const Icon(Icons.shopping_bag_rounded),
              ),
              label: 'SHOP',
            ),
          ],
        ),
      ),
    );
  }
}
