import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/pet_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/interactive_motion/jumping_card.dart';
import '../../../widgets/interactive_motion/staggered_entrance.dart';
import '../../../widgets/pet_background_wrapper.dart';

class SleepHydrationScreen extends StatefulWidget {
  final Pet pet;
  final bool initialIsSleep;

  const SleepHydrationScreen({
    super.key,
    required this.pet,
    this.initialIsSleep = true,
  });

  @override
  State<SleepHydrationScreen> createState() => _SleepHydrationScreenState();
}

class _SleepHydrationScreenState extends State<SleepHydrationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _waterBowlsCount = 4; // Default water bowls today

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIsSleep ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Sleep & Hydration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.canopy,
          labelColor: AppColors.canopy,
          unselectedLabelColor: AppColors.softTaupe,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.bedtime_rounded, size: 20), text: 'Sleep Tracking'),
            Tab(icon: Icon(Icons.water_drop_rounded, size: 20), text: 'Hydration Intake'),
          ],
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cozy_cat_cuddle.jpg',
        imageOpacity: 0.12,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSleepTab(),
            _buildHydrationTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sleep Hero Banner
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.bedtime_rounded, color: AppColors.buttercreamAccent, size: 30),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SLEEP RECORDED',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.buttercreamAccent,
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
                                '12.4',
                                style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hours / Day',
                                style: AppTypography.labelLarge.copyWith(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Normal Range for Canines: 12 - 14 hrs',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

          // 2. Sleep Quality Stages Breakdown
          StaggeredEntrance(
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sleep Stages & Quality', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSleepStagePill('Deep Sleep', '5.2 hrs', AppColors.canopy),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSleepStagePill('REM Sleep', '4.1 hrs', AppColors.pistachioSecondary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSleepStagePill('Light Naps', '3.1 hrs', AppColors.buttercreamAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Sleep History
          StaggeredEntrance(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Sleep Logs', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                _buildSleepLogTile('Night Rest', 'Undisturbed sleep from 10:30 PM to 6:45 AM', '8.2 hrs', DateTime.now().subtract(const Duration(hours: 12))),
                const SizedBox(height: 8),
                _buildSleepLogTile('Post-Walk Afternoon Nap', 'Cool rest by the living room mat', '2.5 hrs', DateTime.now().subtract(const Duration(hours: 24))),
                const SizedBox(height: 8),
                _buildSleepLogTile('Evening Power Snooze', 'Rest before evening play', '1.7 hrs', DateTime.now().subtract(const Duration(days: 2))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTab() {
    final dailyGoalBowls = 6;
    final progress = (_waterBowlsCount / dailyGoalBowls).clamp(0.0, 1.0);
    final mlIntake = _waterBowlsCount * 300;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hydration Hero Card
          StaggeredEntrance(
            index: 0,
            child: JumpingCard(
              enableFloating: true,
              floatAmplitude: 2.2,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D6E6E), // Deep Teal
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D6E6E).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.water_drop_rounded, color: Colors.cyanAccent, size: 30),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TODAY'S WATER INTAKE",
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.cyanAccent,
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
                                '$mlIntake',
                                style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'mL ($_waterBowlsCount / $dailyGoalBowls bowls)',
                                style: AppTypography.labelLarge.copyWith(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            progress >= 1.0 ? 'Optimal hydration level! 💧' : '${(dailyGoalBowls - _waterBowlsCount)} bowls remaining to goal',
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
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

          // 2. Quick Add Water Action
          StaggeredEntrance(
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Log Fresh Water Bowl (300mL)', style: AppTypography.displaySmall.copyWith(fontSize: 15)),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _waterBowlsCount++;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged 1 fresh water bowl 💧 Good job!'),
                              backgroundColor: Color(0xFF0D6E6E),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('+1 Bowl'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6E6E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.creamSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStagePill(String title, String duration, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(duration, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.canopy, fontSize: 13)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.softTaupe, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSleepLogTile(String title, String subtitle, String duration, DateTime date) {
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
              color: AppColors.buttercreamAccent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bedtime_rounded, color: AppColors.buttercreamDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
                Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 9.5, color: AppColors.softTaupe)),
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
