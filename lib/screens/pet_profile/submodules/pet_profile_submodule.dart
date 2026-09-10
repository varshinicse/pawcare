import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/pet_model.dart';
import '../../../providers/pet_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';
import '../add_pet_screen.dart';

class PetProfileSubmodule extends StatelessWidget {
  final Pet pet;

  const PetProfileSubmodule({super.key, required this.pet});

  void _confirmDeletePet(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Delete ${pet.name}?'),
          content: Text(
            'Are you sure you want to remove ${pet.name}\'s profile? This will remove all associated profile data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
              onPressed: () async {
                final petProvider = Provider.of<PetProvider>(context, listen: false);
                await petProvider.deletePet(pet.id);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name}\'s profile has been removed.'),
                      backgroundColor: AppColors.alertCoral,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BASIC INFORMATION CARD
          _buildSectionHeader('Basic Information', Icons.badge_outlined),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
              children: [
                _buildInfoRow('Pet Name', pet.name),
                const Divider(height: 20),
                _buildInfoRow('Pet Type / Species', pet.species.toUpperCase()),
                const Divider(height: 20),
                _buildInfoRow('Breed', pet.breed),
                const Divider(height: 20),
                _buildInfoRow('Gender', pet.gender),
                const Divider(height: 20),
                _buildInfoRow('Date of Birth', DateHelpers.formatDateShort(pet.birthdate)),
                const Divider(height: 20),
                _buildInfoRow('Age', '${pet.age} Years'),
                const Divider(height: 20),
                _buildInfoRow('Weight', '${pet.weightKg} kg'),
                if (pet.color.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Color / Markings', pet.color),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. OWNER INFORMATION CARD
          _buildSectionHeader('Owner Information', Icons.person_outline_rounded),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
              children: [
                _buildInfoRow('Owner Name', pet.ownerName.isNotEmpty ? pet.ownerName : 'Pet Shop Owner'),
                const Divider(height: 20),
                _buildInfoRow('Phone Number', pet.ownerPhone.isNotEmpty ? pet.ownerPhone : pet.emergencyContact),
                const Divider(height: 20),
                _buildInfoRow('Email Address', pet.ownerEmail.isNotEmpty ? pet.ownerEmail : 'owner@pawcare.com'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. ADDITIONAL INFORMATION CARD
          _buildSectionHeader('Care & Dietary Preferences', Icons.restaurant_outlined),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/pet_feeding_routine.jpg',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Daily Meal & Diet Routine 🥣',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Food Preferences', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  pet.foodHabits.isNotEmpty ? pet.foodHabits : 'No specific food preferences specified.',
                  style: AppTypography.bodyMedium,
                ),
                const Divider(height: 24),

                Text('Allergies & Dietary Restrictions', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                const SizedBox(height: 8),
                if (pet.allergies.isEmpty)
                  Text('None reported', style: AppTypography.bodyMedium.copyWith(color: AppColors.inkText))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pet.allergies.map((allergy) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.alertLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.alertCoral.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.alertCoral),
                            const SizedBox(width: 4),
                            Text(
                              allergy,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.alertCoral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                if (pet.specialCareInstructions.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text('Special Care Instructions', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                  const SizedBox(height: 4),
                  Text(pet.specialCareInstructions, style: AppTypography.bodyMedium),
                ],

                if (pet.notes.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text('General Notes', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                  const SizedBox(height: 4),
                  Text(pet.notes, style: AppTypography.bodyMedium),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clayPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddPetScreen(petToEdit: pet)),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Profile'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alertCoral,
                    side: const BorderSide(color: AppColors.alertCoral),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _confirmDeletePet(context, pet),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete Pet'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.clayPrimary),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.displaySmall.copyWith(fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
        Text(value, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
