import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/activity_log_model.dart';
import '../../../models/pet_model.dart';
import '../../../providers/activity_tracker_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/interactive_motion/jumping_card.dart';
import '../../../widgets/interactive_motion/staggered_entrance.dart';
import '../../../widgets/pet_background_wrapper.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Pet pet;

  const ActivityDetailsScreen({super.key, required this.pet});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final _durationController = TextEditingController();
  String _selectedActivityType = 'walk';

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _showLogActivityDialog(BuildContext context, ActivityTrackerProvider activityProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Log Pet Activity', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Activity Type:', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedActivityType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'walk', child: Text('Daily Walk 🦮')),
                      DropdownMenuItem(value: 'play', child: Text('Play / Fetch 🎾')),
                      DropdownMenuItem(value: 'running', child: Text('Running 🏃')),
                      DropdownMenuItem(value: 'training', child: Text('Agility / Training 🏆')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => _selectedActivityType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text('Duration (Minutes):', style: AppTypography.labelMedium),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 45',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canopy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final minutes = double.tryParse(_durationController.text.trim()) ?? 30.0;
                    final log = ActivityLog(
                      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
                      petId: widget.pet.id,
                      type: _selectedActivityType,
                      durationMinutes: minutes,
                      date: DateTime.now(),
                      caloriesBurned: minutes * 2.8,
                      details: 'Active session with ${widget.pet.name}',
                    );
                    activityProvider.addActivityLog(log);
                    _durationController.clear();
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Activity logged successfully! 🐾 Keep moving!'),
                        backgroundColor: AppColors.pistachioSecondary,
                      ),
                    );
                  },
                  child: const Text('Save Activity'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityTrackerProvider>(context);
    final petLogs = activityProvider.getLogsForPet(widget.pet.id);
    final totalMinsToday = petLogs.fold<double>(0.0, (sum, l) => sum + l.durationMinutes);
    final displayMins = totalMinsToday > 0 ? totalMinsToday : 55.0;
    const goalMins = 60.0;
    final progress = (displayMins / goalMins).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Activity & Exercise'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            tooltip: 'Log Activity',
            onPressed: () => _showLogActivityDialog(context, activityProvider),
          ),
        ],
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/dog_beach_play.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 1. Daily Activity Ring Card
            StaggeredEntrance(
              index: 0,
              child: JumpingCard(
                enableFloating: true,
                floatAmplitude: 2.2,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.canopy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.canopy.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pistachioSecondary),
                            ),
                          ),
                          const Icon(Icons.directions_run_rounded, color: Colors.white, size: 28),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TODAY'S ACTIVE TIME",
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.pistachioSecondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${displayMins.toInt()}',
                                  style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ ${goalMins.toInt()} mins',
                                  style: AppTypography.labelLarge.copyWith(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              progress >= 1.0 ? 'Daily goal achieved! 🌟' : '${(goalMins - displayMins).toInt()} mins left to goal',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Weekly Activity Breakdown
            StaggeredEntrance(
              index: 1,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
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
                        Text('Weekly Active Minutes', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.mossLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('High Energy ⚡', style: TextStyle(color: AppColors.pistachioDark, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyActivityBars(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Mon', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Tue', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Wed', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Thu', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Fri', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Sat', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Sun', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Activity Logs History
            StaggeredEntrance(
              index: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Exercise Sessions', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                  TextButton.icon(
                    onPressed: () => _showLogActivityDialog(context, activityProvider),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTerracotta),
                    label: const Text('Log Activity', style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (petLogs.isEmpty)
              _buildSampleActivityLogs()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: petLogs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final log = petLogs[index];
                  return _buildActivityTile(log.type.toUpperCase(), log.details, log.date, '${log.durationMinutes.toInt()} mins');
                },
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildWeeklyActivityBars() {
    final mins = [45.0, 60.0, 50.0, 75.0, 40.0, 80.0, 55.0];
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(mins.length, (i) {
          final barHeight = (mins[i] / 90.0 * 85).clamp(20.0, 85.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${mins[i].toInt()}m', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.canopy)),
              const SizedBox(height: 4),
              Container(
                width: 22,
                height: barHeight,
                decoration: BoxDecoration(
                  color: (i == mins.length - 1) ? AppColors.pistachioSecondary : AppColors.canopy.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSampleActivityLogs() {
    return Column(
      children: [
        _buildActivityTile('WALK 🦮', 'Brisk 3.2km walk in Indiranagar park', DateTime.now().subtract(const Duration(hours: 3)), '35 mins'),
        const SizedBox(height: 8),
        _buildActivityTile('PLAY / FETCH 🎾', 'High intensity ball retrieving session', DateTime.now().subtract(const Duration(hours: 7)), '20 mins'),
        const SizedBox(height: 8),
        _buildActivityTile('LEASH STROLL 🦮', 'Gentle cooldown stroll around neighborhood', DateTime.now().subtract(const Duration(days: 1)), '30 mins'),
      ],
    );
  }

  Widget _buildActivityTile(String title, String subtitle, DateTime date, String duration) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.canopy.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_run_rounded, color: AppColors.canopy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
                Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date), style: const TextStyle(fontSize: 9.5, color: AppColors.softTaupe)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.creamSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              duration,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.canopy, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
