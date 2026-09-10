import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pet_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/pet_background_wrapper.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Pet pet;
  final String medicineName;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final String instructions;
  final String prescribingDoctor;
  final String status; // 'Active', 'Completed', 'Paused'
  final bool reminderActive;

  const MedicationDetailsScreen({
    super.key,
    required this.pet,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    this.instructions = 'Administer orally mixed with wet food after breakfast.',
    this.prescribingDoctor = 'Dr. Ramesh Kumar, BVSc',
    this.status = 'Active',
    this.reminderActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final totalDays = endDate.difference(startDate).inDays;
    final passedDays = DateTime.now().difference(startDate).inDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? (passedDays / totalDays).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Medication Prescription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cozy_cat_cuddle.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Medication Hero Card
              JumpingCard(
                enableFloating: true,
                floatAmplitude: 2.5,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.canopy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.canopy.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.pistachioSecondary.withValues(alpha: 0.25) : Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: isActive ? AppColors.pistachioSecondary : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (reminderActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.buttercreamAccent.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.alarm_on_rounded, color: AppColors.buttercreamAccent, size: 14),
                                  SizedBox(width: 4),
                                  Text('Auto Reminder', style: TextStyle(color: AppColors.buttercreamAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        medicineName,
                        style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prescribed to ${pet.name} (${pet.breed})',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pistachioSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Course Progress: ${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          Text('$passedDays / $totalDays Days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Schedule & Dosage Cards
              Text('Prescription Regimen', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.colorize_rounded, 'Prescribed Dosage', dosage),
                    const Divider(height: 16, color: AppColors.dividerColor),
                    _buildDetailRow(Icons.access_time_filled_rounded, 'Frequency Schedule', frequency),
                    const Divider(height: 16, color: AppColors.dividerColor),
                    _buildDetailRow(Icons.calendar_month_rounded, 'Start & End Date', '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'),
                    const Divider(height: 16, color: AppColors.dividerColor),
                    _buildDetailRow(Icons.person_pin_rounded, 'Prescribing Doctor', prescribingDoctor),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Administration Instructions
              Text('Doctor Instructions', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Text(
                  instructions,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.inkText, height: 1.45, fontSize: 13),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryTerracotta),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.softTaupe)),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
