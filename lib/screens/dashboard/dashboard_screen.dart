import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/care_task_row.dart';
import '../../widgets/jungle_hero_card.dart';
import '../../widgets/paw_loading_indicator.dart';
import '../../widgets/pet_switcher_pill.dart';
import '../../widgets/stat_metric_card.dart';
import '../clinical/clinical_hub_screen.dart';
import '../customers/customers_list_screen.dart';
import '../notifications/notifications_screen.dart';
import '../pet_profile/add_pet_screen.dart';
import '../pet_profile/my_pets_screen.dart';
import '../pet_profile/pet_profile_hub_screen.dart';
import '../reminders/add_reminder_screen.dart';
import '../reminders/reminder_detail_screen.dart';
import '../services/services_hub_screen.dart';
import '../vet/emergency_vet_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;

  const DashboardScreen({super.key, this.onSwitchTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
          reminderProvider.fetchRemindersForPet(activePet.id);
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final activePet = petProvider.activePet ??
        (petProvider.pets.isNotEmpty
            ? petProvider.pets.first
            : Pet(
                id: 'default',
                ownerId: 'default_user',
                name: 'Bruno',
                species: 'dog',
                breed: 'Golden Retriever',
                age: 2.5,
                weightKg: 28.5,
                foodHabits: 'Royal Canin High Protein - Twice daily',
                medicalHistory: ['Vaccinated'],
                avatarAsset: 'dog_hero',
                createdAt: DateTime.now(),
              ));



    final userName = authProvider.userName.isNotEmpty ? authProvider.userName : 'Pet Parent';
    final todayTasks = reminderProvider.todayReminders;
    final completedCount = todayTasks.where((t) => t.isCompleted).length;
    final totalCount = todayTasks.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand, Notification Bell & Live Pet Switcher Pill
            _buildStickyHeader(context),

            // Scrollable Content
            Expanded(
              child: petProvider.isLoading
                  ? const Center(child: PawLoadingIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (petProvider.activePet != null) {
                          await reminderProvider.fetchRemindersForPet(petProvider.activePet!.id);
                        }
                      },
                      color: AppColors.primaryTerracotta,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Jungle Canopy Hero Card
                            JungleHeroCard(
                              pet: activePet,
                              userName: userName,
                              onAddReminder: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                                );
                              },
                              onViewHealth: () {
                                if (widget.onSwitchTab != null) {
                                  widget.onSwitchTab!(1); // Health Tab
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ClinicalHubScreen()),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // 2. Today's Care Trail Checklist
                            _buildCareTrailSection(context, reminderProvider, activePet, completedCount, totalCount, progress),
                            const SizedBox(height: 20),

                            // 3. PawCare AI Insight Banner
                            _buildAiInsightCard(context, activePet),
                            const SizedBox(height: 20),

                            // 4. At A Glance (Health Snapshot Grid)
                            _buildHealthSnapshotSection(activePet),
                            const SizedBox(height: 20),

                            // 5. Quick Service Actions Row
                            _buildQuickActions(context),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamBase.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo + Title
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryTerracotta,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTerracotta.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAWCARE',
                    style: AppTypography.displaySmall.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.inkText,
                    ),
                  ),
                  Text(
                    'Grow happy. Live healthy.',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 9.5,
                      color: AppColors.softTaupe,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions: Notification Icon & Pet Switcher Pill
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.inkText),
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  side: const BorderSide(color: AppColors.dividerColor),
                ),
              ),
              const SizedBox(width: 8),
              const PetSwitcherPill(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCareTrailSection(
    BuildContext context,
    ReminderProvider reminderProvider,
    Pet activePet,
    int completedCount,
    int totalCount,
    double progress,
  ) {
    final tasks = reminderProvider.todayReminders;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S CARE TRAIL",
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryTerracotta,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completedCount of $totalCount tasks complete',
                    style: AppTypography.displaySmall.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mossLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  completedCount == totalCount && totalCount > 0 ? 'All Complete 🌟' : 'On track',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.pistachioDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.wb_sunny_outlined, size: 36, color: AppColors.softTaupe),
                    const SizedBox(height: 8),
                    Text('No reminders scheduled for today', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTerracotta),
                      label: Text('Add Routine Task', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryTerracotta)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final task = tasks[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReminderDetailScreen(singleReminder: task),
                      ),
                    );
                  },
                  child: CareTaskRow(
                    task: task,
                    onToggle: () {
                      reminderProvider.toggleReminderComplete(task, activePet.name);
                    },
                  ),
                );
              },
            ),

          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.creamSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pistachioSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(BuildContext context, Pet activePet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.buttercreamAccent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: AppColors.buttercreamDark, size: 22),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTerracotta,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PAWCARE AI',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.buttercreamDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'A little care goes a long way.',
            style: AppTypography.displaySmall.copyWith(
              fontSize: 19,
              color: AppColors.buttercreamDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${activePet.name}'s care history and diet habits make regular check-ins especially helpful. Keep fresh water and consistent meal times.",
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12.5,
              color: AppColors.buttercreamDark.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.onSwitchTab != null) {
                widget.onSwitchTab!(4); // AI Assistant Tab
              }
            },
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: const Text('Ask PawCare AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.canopy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: AppTypography.labelLarge.copyWith(fontSize: 12),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSnapshotSection(Pet activePet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AT A GLANCE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryTerracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Health snapshot', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
              ],
            ),
            TextButton(
              onPressed: () {
                if (widget.onSwitchTab != null) {
                  widget.onSwitchTab!(1); // Clinical/Health tab
                }
              },
              child: const Text('View records ➔', style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            StatMetricCard(
              icon: Icons.scale_rounded,
              label: 'Weight',
              value: '${activePet.weightKg} kg',
              note: 'Healthy range',
              iconColor: AppColors.primaryTerracotta,
            ),
            const StatMetricCard(
              icon: Icons.thermostat_rounded,
              label: 'Temperature',
              value: '38.4°C',
              note: 'Normal',
              iconColor: AppColors.pistachioSecondary,
            ),
            const StatMetricCard(
              icon: Icons.directions_run_rounded,
              label: 'Activity',
              value: '6,420',
              note: 'steps today',
              iconColor: AppColors.canopy,
            ),
            const StatMetricCard(
              icon: Icons.event_note_rounded,
              label: 'Next visit',
              value: '3 days',
              note: 'Routine booster',
              iconColor: AppColors.primaryTerracotta,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionPill(
            icon: Icons.pets_rounded,
            label: 'My Pets',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyPetsScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionPill(
            icon: Icons.people_alt_rounded,
            label: 'Customers',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomersListScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionPill(
            icon: Icons.medical_services_rounded,
            label: 'Services',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ServicesHubScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionPill(
            icon: Icons.local_hospital_rounded,
            label: 'Emergency',
            isAlert: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmergencyVetScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isAlert = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isAlert ? AppColors.alertLight : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAlert ? AppColors.alertCoral.withValues(alpha: 0.3) : AppColors.dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isAlert ? AppColors.alertCoral : AppColors.canopy,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isAlert ? AppColors.alertCoral : AppColors.inkText,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
