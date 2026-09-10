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

class WeightTrackingScreen extends StatefulWidget {
  final Pet pet;

  const WeightTrackingScreen({super.key, required this.pet});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final hrProvider = Provider.of<HealthRecordProvider>(context);
    final petRecords = hrProvider.getRecordsForPet(widget.pet.id);

    final weightRecords = petRecords.where((r) => r.weightKg > 0).toList();
    final currentWeight = widget.pet.weightKg > 0 ? widget.pet.weightKg : (weightRecords.isNotEmpty ? weightRecords.first.weightKg : 28.5);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Weight & Body Condition'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            tooltip: 'Add Weight Entry',
            onPressed: () => _navigateToAddWeightLog(context),
          ),
        ],
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/pet_feeding_routine.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Current Weight Hero Card
            StaggeredEntrance(
              index: 0,
              child: JumpingCard(
                enableFloating: true,
                floatAmplitude: 2.5,
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
                          color: AppColors.buttercreamAccent.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.scale_rounded, color: AppColors.buttercreamAccent, size: 30),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT WEIGHT',
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
                                  currentWeight.toStringAsFixed(1),
                                  style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'KG',
                                  style: AppTypography.labelLarge.copyWith(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pistachioSecondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ideal Range for ${widget.pet.breed}: 27 - 32 kg',
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
            const SizedBox(height: 20),

            // 2. Growth & Weight Curve Progress Chart
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
                        Text('Weight Trajectory (6 Months)', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.mossLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Optimal Body Score 🌟', style: TextStyle(color: AppColors.pistachioDark, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWeightCurve(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Apr', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('May', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Jun', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Jul', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Aug', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                        Text('Sep', style: TextStyle(fontSize: 10, color: AppColors.softTaupe)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Weight Records List
            StaggeredEntrance(
              index: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Historical Weight Logs', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                  TextButton.icon(
                    onPressed: () => _navigateToAddWeightLog(context),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTerracotta),
                    label: const Text('Add Weight', style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (weightRecords.isEmpty)
              _buildSampleWeightLogs()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weightRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final rec = weightRecords[index];
                  return _buildWeightTile(rec.title, rec.description, rec.date, '${rec.weightKg.toStringAsFixed(1)} kg');
                },
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildWeightCurve() {
    final weights = [26.8, 27.2, 27.6, 28.0, 28.3, 28.5];
    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(weights.length, (i) {
          final barHeight = ((weights[i] - 25.0) / (30.0 - 25.0) * 80).clamp(25.0, 95.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${weights[i]}kg', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.canopy)),
              const SizedBox(height: 4),
              Container(
                width: 26,
                height: barHeight,
                decoration: BoxDecoration(
                  color: (i == weights.length - 1) ? AppColors.primaryTerracotta : AppColors.canopy.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSampleWeightLogs() {
    return Column(
      children: [
        _buildWeightTile('Current Month Weigh-in', 'Verified at PawCare Indiranagar Salon', DateTime.now().subtract(const Duration(days: 3)), '28.5 kg'),
        const SizedBox(height: 8),
        _buildWeightTile('Monthly Growth Check', 'Normal gradual muscle gain', DateTime.now().subtract(const Duration(days: 32)), '28.3 kg'),
        const SizedBox(height: 8),
        _buildWeightTile('Mid-Year Assessment', 'Diet adjustment to high protein kibbles', DateTime.now().subtract(const Duration(days: 64)), '28.0 kg'),
      ],
    );
  }

  Widget _buildWeightTile(String title, String subtitle, DateTime date, String weight) {
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
              color: AppColors.primaryTerracotta.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.scale_rounded, color: AppColors.primaryTerracotta, size: 20),
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
              weight,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.canopy, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddWeightLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditHealthRecordScreen(
          petId: widget.pet.id,
          initialType: 'weight',
        ),
      ),
    );
  }
}
