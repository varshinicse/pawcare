import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/floating_pill_nav_bar.dart';
import '../../widgets/paw_loading_indicator.dart';
import '../notifications/notifications_screen.dart';
import '../pet_profile/add_pet_screen.dart';
import '../pet_profile/pet_detail_screen.dart';
import '../reminders/add_reminder_screen.dart';
import '../reminders/reminder_detail_screen.dart';
import '../vet/emergency_vet_screen.dart';
import 'widgets/ai_suggestion_card.dart';
import 'widgets/greeting_hero.dart';
import 'widgets/mascot_app_bar.dart';
import 'widgets/pet_selector_header.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/today_timeline.dart';
import 'widgets/upcoming_events_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  StreamSubscription? _notificationSubscription;
  late PetProvider _petProvider;
  VoidCallback? _petProviderListener;
  String? _lastActivePetId;

  @override
  void initState() {
    super.initState();
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    _petProvider = Provider.of<PetProvider>(context, listen: false);

    _lastActivePetId = _petProvider.activePet?.id;
    if (_lastActivePetId != null) {
      reminderProvider.fetchRemindersForPet(_lastActivePetId!);
    }

    _petProviderListener = () {
      final activePet = _petProvider.activePet;
      if (activePet != null && activePet.id != _lastActivePetId) {
        _lastActivePetId = activePet.id;
        reminderProvider.fetchRemindersForPet(activePet.id);
      }
    };
    _petProvider.addListener(_petProviderListener!);

    _notificationSubscription = NotificationService().triggeredReminders.listen((reminder) {
      if (mounted) {
        final activePet = _petProvider.activePet;

        if (activePet != null && reminder.petId == activePet.id) {
          // Re-fetch lists to show task state changes immediately in dashboard UI
          reminderProvider.fetchRemindersForPet(activePet.id);
          _showRealTimeReminderDialog(reminder, activePet.name);
        }
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    if (_petProviderListener != null) {
      _petProvider.removeListener(_petProviderListener!);
    }
    super.dispose();
  }

  void _showRealTimeReminderDialog(dynamic reminder, String petName) {
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
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'PawCare Reminder! 🐾',
                style: AppTypography.displaySmall.copyWith(fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'It\'s time to care for $petName!',
                style: AppTypography.labelLarge.copyWith(color: AppColors.clayPrimary),
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
                    content: Text('Awesome! $petName\'s task marked as done! 🎉'),
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

  void _onNavTabTapped(int index) {
    if (index == 1) {
      // My Pets tab
      final activePet = Provider.of<PetProvider>(context, listen: false).activePet;
      if (activePet != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: activePet)),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddPetScreen()),
        );
      }
    } else if (index == 2) {
      // Reminders tab
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReminderDetailScreen()),
      );
    } else if (index == 3) {
      // Emergency Vet tab
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EmergencyVetScreen()),
      );
    } else {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final activePet = petProvider.activePet;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: MascotAppBar(
        ownerName: authProvider.userName,
        onNotificationTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
      ),
      body: petProvider.isLoading
          ? const PawLoadingIndicator()
          : SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Pet Selector Header (Chips)
                        PetSelectorHeader(
                          pets: petProvider.pets,
                          activePet: activePet,
                          onSelectPet: (pet) {
                            petProvider.selectPet(pet);
                            reminderProvider.fetchRemindersForPet(pet.id);
                          },
                          onAddPetPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddPetScreen()),
                            );
                          },
                        ),

                         const SizedBox(height: 10),

                        // Dynamic Active Alert Tracker
                        if (reminderProvider.todayReminders.any((r) => !r.isCompleted)) ...[
                          Builder(
                            builder: (context) {
                              final nextReminder = reminderProvider.todayReminders.firstWhere((r) => !r.isCompleted);
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.alertLight,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.alertCoral.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alarm_on_rounded, color: AppColors.alertCoral, size: 28),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ACTIVE ALERT TRACKER ⏰',
                                            style: AppTypography.labelMedium.copyWith(
                                              color: AppColors.alertCoral,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '"${nextReminder.title}" scheduled',
                                            style: AppTypography.labelLarge.copyWith(fontSize: 14),
                                          ),
                                          Text(
                                            'Alert time: ${TimeOfDay.fromDateTime(nextReminder.scheduledTime).format(context)} today',
                                            style: AppTypography.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 3. Today's Timeline (Horizontally Scrollable Pill Cards)
                        TodayTimeline(
                          reminders: reminderProvider.todayReminders,
                          onToggleComplete: (reminder) {
                            reminderProvider.toggleReminderComplete(
                              reminder,
                              activePet?.name ?? 'Bruno',
                            );
                          },
                          onAddReminder: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // 4. AI Suggestion Card
                        AiSuggestionCard(activePet: activePet),

                        const SizedBox(height: 24),

                        // 5. Upcoming 7 Days Events List
                        UpcomingEventsList(
                          upcomingReminders: reminderProvider.upcomingReminders,
                        ),

                        const SizedBox(height: 24),

                        // 6. Quick Actions Row
                        QuickActionsRow(
                          onAddReminder: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                            );
                          },
                          onAddPet: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddPetScreen()),
                            );
                          },
                          onEmergencyVet: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EmergencyVetScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                         // 7. Interactive Health Progress & Water Intake Trackers
                         Container(
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(28),
                             border: Border.all(color: AppColors.dividerColor),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Text('Daily Vitals 🥤', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                                   Text('Goal: 1500ml', style: AppTypography.labelMedium.copyWith(color: AppColors.clayPrimary)),
                                 ],
                               ),
                               const SizedBox(height: 12),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text('Water Logged', style: AppTypography.bodySmall),
                                       Text('750 ml', style: AppTypography.numericData.copyWith(fontSize: 20)),
                                     ],
                                   ),
                                   ElevatedButton.icon(
                                     style: ElevatedButton.styleFrom(
                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                     ),
                                     onPressed: () {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(content: Text('+250ml Water Logged! 🥤')),
                                       );
                                     },
                                     icon: const Icon(Icons.add_rounded, size: 16),
                                     label: const Text('Add 250ml'),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
     );
  }
}
