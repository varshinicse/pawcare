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

class TemperatureHistoryScreen extends StatefulWidget {
  final Pet pet;

  const TemperatureHistoryScreen({super.key, required this.pet});

  @override
  State<TemperatureHistoryScreen> createState() => _TemperatureHistoryScreenState();
}

class _TemperatureHistoryScreenState extends State<TemperatureHistoryScreen> {
  bool _isCelsius = true;

  @override
  Widget build(BuildContext context) {
    final hrProvider = Provider.of<HealthRecordProvider>(context);
    final petRecords = hrProvider.getRecordsForPet(widget.pet.id);

    final tempRecords = petRecords.where((r) => r.temperatureCelsius > 0).toList();
    final latestTemp = tempRecords.isNotEmpty ? tempRecords.first.temperatureCelsius : 38.4;
    final displayTemp = _isCelsius ? '${latestTemp.toStringAsFixed(1)}°C' : '${((latestTemp * 9 / 5) + 32).toStringAsFixed(1)}°F';

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Body Temperature'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            tooltip: 'Add Reading',
            onPressed: () => _navigateToAddTempLog(context),
          ),
        ],
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cute_puppy_pajamas.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 1. Current Temperature Banner
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
                          color: AppColors.pistachioSecondary.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.thermostat_rounded, color: AppColors.pistachioSecondary, size: 30),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LATEST BODY TEMPERATURE',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.pistachioSecondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayTemp,
                              style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pistachioSecondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Healthy Range: 38.3°C - 39.2°C (101°F - 102.5°F)',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Unit Switcher
                      InkWell(
                        onTap: () => setState(() => _isCelsius = !_isCelsius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isCelsius ? '°F' : '°C',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Temperature Stability Chart
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
                        Text('7-Day Trend', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.pistachioSecondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Normal (No Fever)', style: TextStyle(color: AppColors.pistachioDark, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTempGraph(),
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

            // 3. Historical Readings
            StaggeredEntrance(
              index: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Temperature Log History', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
                  TextButton.icon(
                    onPressed: () => _navigateToAddTempLog(context),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTerracotta),
                    label: const Text('Add Reading', style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (tempRecords.isEmpty)
              _buildSampleReadings()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tempRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final rec = tempRecords[index];
                  return _buildLogTile(rec.title, rec.description, rec.date, '${rec.temperatureCelsius.toStringAsFixed(1)}°C');
                },
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTempGraph() {
    final temps = [38.4, 38.5, 38.3, 38.6, 38.4, 38.5, 38.4];
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(temps.length, (i) {
          final heightPercent = (temps[i] - 37.5) / (39.5 - 37.5);
          final barHeight = (heightPercent * 80).clamp(20.0, 90.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${temps[i]}°', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.canopy)),
              const SizedBox(height: 4),
              Container(
                width: 22,
                height: barHeight,
                decoration: BoxDecoration(
                  color: AppColors.pistachioSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSampleReadings() {
    return Column(
      children: [
        _buildLogTile('Annual Wellness Exam', 'Routine checkup with Dr. Ramesh Kumar', DateTime.now().subtract(const Duration(days: 2)), '38.4°C'),
        const SizedBox(height: 8),
        _buildLogTile('Evening Thermal Scan', 'Home rectal checkup - Normal', DateTime.now().subtract(const Duration(days: 5)), '38.5°C'),
        const SizedBox(height: 8),
        _buildLogTile('Post-Grooming Check', 'Relaxed state after bath', DateTime.now().subtract(const Duration(days: 12)), '38.3°C'),
      ],
    );
  }

  Widget _buildLogTile(String title, String subtitle, DateTime date, String temp) {
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
              color: AppColors.pistachioSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.thermostat_rounded, color: AppColors.pistachioDark, size: 20),
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
              temp,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.canopy, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddTempLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditHealthRecordScreen(
          petId: widget.pet.id,
          initialType: 'temperature',
        ),
      ),
    );
  }
}
