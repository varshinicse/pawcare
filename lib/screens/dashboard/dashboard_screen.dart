import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/activity_tracker_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/care_task_row.dart';
import '../../widgets/interactive_motion/glassmorphic_container.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/interactive_motion/staggered_entrance.dart';
import '../../widgets/jungle_hero_card.dart';
import '../../widgets/paw_loading_indicator.dart';
import '../../widgets/pet_background_wrapper.dart';
import '../../widgets/pet_switcher_pill.dart';
import '../../widgets/stat_metric_card.dart';
import '../clinical/clinical_hub_screen.dart';
import '../customers/customers_list_screen.dart';
import '../notifications/notifications_screen.dart';
import '../pet_profile/my_pets_screen.dart';
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
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_dog_friends.jpg',
        imageOpacity: 0.12,
        child: SafeArea(
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
                              // 1. Jungle Canopy Hero Card with Staggered Entrance
                              StaggeredEntrance(
                                index: 0,
                                child: JungleHeroCard(
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
                              ),
                              const SizedBox(height: 20),

                              // 2. Today's Care Trail Checklist
                              StaggeredEntrance(
                                index: 1,
                                child: _buildCareTrailSection(context, reminderProvider, activePet, completedCount, totalCount, progress),
                              ),
                              const SizedBox(height: 20),

                              // 3. PawCare AI Insight Banner
                              StaggeredEntrance(
                                index: 2,
                                child: _buildAiInsightCard(context, activePet),
                              ),
                              const SizedBox(height: 20),

                              // 4. At A Glance (Health Snapshot Grid)
                              StaggeredEntrance(
                                index: 3,
                                child: _buildHealthSnapshotSection(context, activePet),
                              ),
                              const SizedBox(height: 20),

                              // 5. Quick Service Actions Row
                              StaggeredEntrance(
                                index: 4,
                                child: _buildQuickActions(context),
                              ),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
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
              JumpingCard(
                enableFloating: true,
                floatAmplitude: 2.0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTerracotta,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTerracotta.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
                ),
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
                  completedCount == totalCount && totalCount > 0 ? 'All Complete 🌟' : 'On track 🐾',
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
                return Dismissible(
                  key: Key('task_${task.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: AppColors.pistachioSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.pistachioDark, size: 24),
                  ),
                  onDismissed: (_) {
                    reminderProvider.toggleReminderComplete(task, activePet.name);
                  },
                  child: InkWell(
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
    return JumpingCard(
      enableFloating: true,
      floatAmplitude: 3.0,
      borderRadius: BorderRadius.circular(24),
      glowColor: AppColors.buttercreamAccent,
      child: Container(
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
                color: AppColors.buttercreamDark.withValues(alpha: 0.85),
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
      ),
    );
  }

  Widget _buildHealthSnapshotSection(BuildContext context, Pet activePet) {
    final healthProvider = Provider.of<HealthRecordProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final activityProvider = Provider.of<ActivityTrackerProvider>(context);

    // Dynamic temperature from health records or default normal range
    final petRecords = healthProvider.getRecordsForPet(activePet.id);
    String tempDisplay = '38.4°C';
    String tempNote = 'Normal range';
    if (petRecords.isNotEmpty) {
      final latestRec = petRecords.first;
      if (latestRec.temperatureCelsius > 0) {
        tempDisplay = '${latestRec.temperatureCelsius.toStringAsFixed(1)}°C';
      }
      if (latestRec.type.isNotEmpty) {
        tempNote = latestRec.type;
      }
    }

    // Dynamic activity from logs
    final petLogs = activityProvider.getLogsForPet(activePet.id);
    final totalMinutes = petLogs.fold<double>(0.0, (sum, log) => sum + log.durationMinutes);
    final activityDisplay = totalMinutes > 0 ? '${totalMinutes.toStringAsFixed(0)} mins' : '45 mins';
    final activityNote = petLogs.isNotEmpty ? '${petLogs.first.type} recorded' : 'Active today';

    // Dynamic next visit from upcoming appointments
    final upcoming = appointmentProvider.upcomingAppointments.where((a) => a.petId == activePet.id || a.petName.toLowerCase() == activePet.name.toLowerCase()).toList();
    String nextVisitDisplay = 'Routine';
    String nextVisitNote = 'Checkup due';
    if (upcoming.isNotEmpty) {
      final next = upcoming.first;
      final diffDays = next.dateTime.difference(DateTime.now()).inDays;
      nextVisitDisplay = diffDays <= 0 ? 'Today' : diffDays == 1 ? 'Tomorrow' : 'In $diffDays days';
      nextVisitNote = next.serviceCategory;
    }

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
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            JumpingCard(
              enableFloating: true,
              floatAmplitude: 2.5,
              borderRadius: BorderRadius.circular(16),
              child: StatMetricCard(
                icon: Icons.scale_rounded,
                label: 'Weight',
                value: '${activePet.weightKg.toStringAsFixed(1)} kg',
                note: 'Healthy range',
                iconColor: AppColors.primaryTerracotta,
                onTap: () {
                  if (widget.onSwitchTab != null) widget.onSwitchTab!(1);
                },
              ),
            ),
            JumpingCard(
              enableFloating: true,
              floatAmplitude: 2.5,
              borderRadius: BorderRadius.circular(16),
              child: StatMetricCard(
                icon: Icons.thermostat_rounded,
                label: 'Vitals',
                value: tempDisplay,
                note: tempNote,
                iconColor: AppColors.pistachioSecondary,
                onTap: () {
                  if (widget.onSwitchTab != null) widget.onSwitchTab!(1);
                },
              ),
            ),
            JumpingCard(
              enableFloating: true,
              floatAmplitude: 2.5,
              borderRadius: BorderRadius.circular(16),
              child: StatMetricCard(
                icon: Icons.directions_run_rounded,
                label: 'Activity',
                value: activityDisplay,
                note: activityNote,
                iconColor: AppColors.canopy,
                onTap: () {
                  if (widget.onSwitchTab != null) widget.onSwitchTab!(1);
                },
              ),
            ),
            JumpingCard(
              enableFloating: true,
              floatAmplitude: 2.5,
              borderRadius: BorderRadius.circular(16),
              child: StatMetricCard(
                icon: Icons.event_note_rounded,
                label: 'Next visit',
                value: nextVisitDisplay,
                note: nextVisitNote,
                iconColor: AppColors.primaryTerracotta,
                onTap: () {
                  if (widget.onSwitchTab != null) widget.onSwitchTab!(2);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      borderRadius: BorderRadius.circular(22),
      opacity: 0.75,
      child: Row(
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
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isAlert = false,
  }) {
    return JumpingCard(
      enableFloating: false,
      scaleOnTap: 0.92,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isAlert ? AppColors.alertLight : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAlert ? AppColors.alertCoral.withValues(alpha: 0.35) : AppColors.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
