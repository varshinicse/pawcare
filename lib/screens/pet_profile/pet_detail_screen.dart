import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'add_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${pet.name}\'s Profile 🐾'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.clayPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddPetScreen(petToEdit: pet)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Pet Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.clayPrimary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: AppColors.clayLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        pet.species == 'cat' ? Icons.pets_rounded : Icons.pets_rounded,
                        size: 46,
                        color: AppColors.clayPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(pet.name, style: AppTypography.displayMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} • ${pet.species.toUpperCase()}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBox('AGE', '${pet.age} Yrs'),
                      Container(width: 1, height: 30, color: AppColors.dividerColor),
                      _buildStatBox('WEIGHT', '${pet.weightKg} Kg'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Food & Nutrition Section
            Text('Nutrition & Food Habits', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_rounded, color: AppColors.clayPrimary, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      pet.foodHabits.isNotEmpty
                          ? pet.foodHabits
                          : 'No food habit details added yet.',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Medical History
            Text('Medical History & Tags', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 10),
            if (pet.medicalHistory.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Text(
                  'No medical tags specified.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: pet.medicalHistory.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mossLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.mossAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.mossAccent),
                        const SizedBox(width: 6),
                        Text(
                          tag,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.mossAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 36),

            // Set as active pet button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<PetProvider>(context, listen: false).selectPet(pet);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.star_rounded, size: 20),
                label: Text('Set ${pet.name} as Active Dashboard Pet'),
              ),
            ),
            const SizedBox(height: 14),

            // Delete Pet button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.alertCoral,
                  side: const BorderSide(color: AppColors.alertCoral),
                ),
                onPressed: () => _confirmDeletePet(context, pet),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: Text('Delete ${pet.name}\'s Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePet(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Delete ${pet.name}?'),
          content: Text('Are you sure you want to remove ${pet.name}\'s profile? This action cannot be undone.'),
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
                      content: Text('${pet.name}\'s profile was deleted.'),
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

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.numericData.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
