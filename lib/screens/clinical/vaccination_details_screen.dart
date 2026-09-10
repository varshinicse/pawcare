import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pet_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/pet_background_wrapper.dart';

class VaccinationDetailsScreen extends StatelessWidget {
  final Pet pet;
  final String vaccineName;
  final DateTime dateAdministered;
  final DateTime nextDueDate;
  final String status; // 'completed', 'upcoming', 'overdue'
  final String veterinarian;
  final String clinic;
  final String batchNumber;
  final String notes;

  const VaccinationDetailsScreen({
    super.key,
    required this.pet,
    required this.vaccineName,
    required this.dateAdministered,
    required this.nextDueDate,
    required this.status,
    this.veterinarian = 'Dr. Ramesh Kumar, BVSc',
    this.clinic = 'PawCare Indiranagar Super Clinic',
    this.batchNumber = 'DHPP-VET-88291',
    this.notes = 'Core immunization vaccine administered subcutaneously. No adverse reaction observed during 15-min post-vaccination monitoring.',
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toLowerCase() == 'completed';
    final isOverdue = status.toLowerCase() == 'overdue';

    final badgeColor = isCompleted
        ? AppColors.pistachioSecondary
        : (isOverdue ? AppColors.alertCoral : AppColors.buttercreamDark);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Vaccination Certificate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/vet_clinical_service.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Certificate Card Banner
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
                              color: badgeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const Icon(Icons.verified_rounded, color: AppColors.pistachioSecondary, size: 28),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vaccineName,
                        style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Patient: ${pet.name} (${pet.breed})',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Administered On', style: TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(DateFormat('MMM dd, yyyy').format(dateAdministered), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Next Due Booster', style: TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(DateFormat('MMM dd, yyyy').format(nextDueDate), style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Clinical Administration Details
              Text('Clinical Information', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
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
                    _buildDetailRow(Icons.person_pin_rounded, 'Administering Veterinarian', veterinarian),
                    const Divider(height: 16, color: AppColors.dividerColor),
                    _buildDetailRow(Icons.local_hospital_rounded, 'Clinic / Center', clinic),
                    const Divider(height: 16, color: AppColors.dividerColor),
                    _buildDetailRow(Icons.qr_code_2_rounded, 'Batch / Serial No.', batchNumber),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Veterinary Observation & Notes
              Text('Doctor Notes & Observation', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Text(
                  notes,
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
        Icon(icon, size: 20, color: AppColors.canopy),
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
