import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/pet_model.dart';
import '../../../providers/health_record_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/interactive_motion/jumping_card.dart';
import '../../../widgets/interactive_motion/staggered_entrance.dart';
import '../../../widgets/pet_background_wrapper.dart';
import '../add_edit_health_record_screen.dart';

class HeartRateHistoryScreen extends StatefulWidget {
  final Pet pet;

  const HeartRateHistoryScreen({super.key, required this.pet});

  @override
  State<HeartRateHistoryScreen> createState() => _HeartRateHistoryScreenState();
}

class _HeartRateHistoryScreenState extends State<HeartRateHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hrProvider = Provider.of<HealthRecordProvider>(context);
    final petRecords = hrProvider.getRecordsForPet(widget.pet.id);

    // Filter heart rate records or default readings
    final hrLogs = petRecords.where((r) => r.type.toLowerCase() == 'heart_rate' || r.type.toLowerCase() == 'vitals').toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Heart Rate History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            tooltip: 'Add Log',
            onPressed: () => _navigateToAddHeartLog(context),
          ),
        ],
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/dog_avatar_bruno.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Pulse / Average BPM Hero Card
              StaggeredEntrance(
                index: 0,
                child: JumpingCard(
                  enableFloating: true,
                  floatAmplitude: 2.5,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryTerracotta,
                          AppColors.primaryTerracotta.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTerracotta.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.favorite_rounded, color: Colors.white, size: 34),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT HEART RATE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '84',
                                    style: AppTypography.displayMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'BPM (Normal)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Resting range: 70 - 120 BPM',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Time Horizon Tabs (Daily, Weekly, Monthly)
              StaggeredEntrance(
                index: 1,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryTerracotta,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.softTaupe,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Weekly'),
                      Tab(text: 'Monthly'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Fluctuation Graph Card
              StaggeredEntrance(
                index: 2,
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
                          Text('BPM Fluctuations', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pistachioSecondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Steady Rhythm 💚', style: TextStyle(color: AppColors.pistachioDark, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChartBars(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('6 AM', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                          Text('9 AM', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                          Text('12 PM', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                          Text('3 PM', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                          Text('6 PM', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                          Text('9 PM', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Previous Logs List
              StaggeredEntrance(
                index: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recorded Readings', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                    TextButton.icon(
                      onPressed: () => _navigateToAddHeartLog(context),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTerracotta),
                      label: const Text('Add Log', style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (hrLogs.isEmpty)
                _buildSampleReadingList()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hrLogs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, index) {
                    final log = hrLogs[index];
                    return _buildLogTile(log.title, log.description, log.date, '84 BPM');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartBars() {
    final heights = [45.0, 70.0, 85.0, 60.0, 95.0, 75.0];
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(heights.length, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: heights[i],
                decoration: BoxDecoration(
                  color: (i == 4) ? AppColors.alertCoral : AppColors.canopy.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSampleReadingList() {
    return Column(
      children: [
        _buildLogTile('Morning Vet Vitals', 'Resting checkup before feeding', DateTime.now().subtract(const Duration(hours: 4)), '82 BPM'),
        const SizedBox(height: 8),
        _buildLogTile('Post-Play Check', 'After 30 mins fetch session', DateTime.now().subtract(const Duration(days: 1)), '112 BPM'),
        const SizedBox(height: 8),
        _buildLogTile('Routine Sleep Check', 'During deep sleep rhythm', DateTime.now().subtract(const Duration(days: 2)), '74 BPM'),
      ],
    );
  }

  Widget _buildLogTile(String title, String subtitle, DateTime date, String bpm) {
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
              color: AppColors.alertCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.alertCoral, size: 20),
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
              bpm,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.canopy, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddHeartLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditHealthRecordScreen(
          petId: widget.pet.id,
          initialType: 'heart_rate',
        ),
      ),
    );
  }
}
