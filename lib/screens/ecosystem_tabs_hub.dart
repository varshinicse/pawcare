import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder_model.dart';
import '../providers/care_history_provider.dart';
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
  bool _isDialogOpen = false;

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

        if (activePet != null) {
          reminderProvider.fetchRemindersForPet(activePet.id);
        }

        _showRealTimeReminderDialog(reminder, petName);
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showRealTimeReminderDialog(Reminder reminder, String petName) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

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
                style: AppTypography.labelLarge.copyWith(color: AppColors.primaryTerracotta),
              ),
              const SizedBox(height: 10),
              Text(
                reminder.title,
                style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.inkText),
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
            PopupMenuButton<int>(
              tooltip: 'Choose Snooze duration',
              onSelected: (int minutes) async {
                final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                await reminderProvider.snoozeReminder(reminder, minutes, petName);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Snoozed "${reminder.title}" for $minutes minutes ⏰'),
                      backgroundColor: AppColors.primaryTerracotta,
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 5,
                  child: Text('Snooze 5 mins ⏱️'),
                ),
                const PopupMenuItem<int>(
                  value: 10,
                  child: Text('Snooze 10 mins ⏱️'),
                ),
                const PopupMenuItem<int>(
                  value: 30,
                  child: Text('Snooze 30 mins ⏱️'),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.snooze_rounded, size: 18, color: AppColors.softTaupe),
                    const SizedBox(width: 4),
                    Text(
                      'Snooze ▼',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.softTaupe),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pistachioSecondary,
                foregroundColor: AppColors.pistachioDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                final careHistoryProvider = Provider.of<CareHistoryProvider>(context, listen: false);
                await reminderProvider.toggleReminderComplete(
                  reminder,
                  petName,
                  careHistoryProvider: careHistoryProvider,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Awesome! Reminder "${reminder.title}" marked as done! 🎉'),
                      backgroundColor: AppColors.pistachioSecondary,
                    ),
                  );
                }
              },
              child: const Text('Mark Done'),
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final cartCount = ecoProvider.cart.length;

    final List<Widget> screens = [
      DashboardScreen(onSwitchTab: _switchTab),
      const ClinicalHubScreen(),
      const AiHubScreen(),
      const SocialHubScreen(),
      const ShopHubScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.canopy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.canopy.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavPill(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: _currentIndex == 0,
            ),
            _buildNavPill(
              index: 1,
              icon: Icons.favorite_rounded,
              label: 'Health',
              isSelected: _currentIndex == 1,
            ),
            _buildNavPill(
              index: 2,
              icon: Icons.auto_awesome_rounded,
              label: 'AI Center',
              isSelected: _currentIndex == 2,
            ),
            _buildNavPill(
              index: 3,
              icon: Icons.people_alt_rounded,
              label: 'Social',
              isSelected: _currentIndex == 3,
            ),
            _buildNavPill(
              index: 4,
              icon: Icons.shopping_bag_rounded,
              label: 'Shop',
              isSelected: _currentIndex == 4,
              badgeCount: cartCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavPill({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: () => _switchTab(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTerracotta : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badgeCount > 0
                ? Badge(
                    label: Text(badgeCount.toString()),
                    backgroundColor: AppColors.alertCoral,
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
                  ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
