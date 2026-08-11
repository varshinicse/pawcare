import 'package:flutter/material.dart';

import '../../../models/pet_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class PetSelectorHeader extends StatelessWidget {
  final List<Pet> pets;
  final Pet? activePet;
  final Function(Pet) onSelectPet;
  final VoidCallback onAddPetPressed;

  const PetSelectorHeader({
    super.key,
    required this.pets,
    required this.activePet,
    required this.onSelectPet,
    required this.onAddPetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: pets.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == pets.length) {
            return _buildAddPetChip();
          }

          final pet = pets[index];
          final isSelected = activePet?.id == pet.id;

          return GestureDetector(
            onTap: () => onSelectPet(pet),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.clayPrimary : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isSelected ? AppColors.clayPrimary : AppColors.dividerColor,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.clayPrimary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.creamSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      pet.species.toLowerCase() == 'cat'
                          ? Icons.pets_rounded
                          : Icons.pets_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.clayPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pet.name,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddPetChip() {
    return GestureDetector(
      onTap: onAddPetPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.creamSurface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.dividerColor, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_rounded, size: 18, color: AppColors.inkText),
            const SizedBox(width: 6),
            Text(
              'Add Pet',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.inkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
