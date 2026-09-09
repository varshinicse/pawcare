import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Floating pill pet switcher widget modeled after the PawCare companion shell
class PetSwitcherPill extends StatelessWidget {
  final VoidCallback? onAddPetTap;

  const PetSwitcherPill({super.key, this.onAddPetTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        final pets = petProvider.pets;
        final active = petProvider.activePet ?? (pets.isNotEmpty ? pets.first : null);

        if (pets.isEmpty || active == null) {
          return InkWell(
            onTap: onAddPetTap ?? () => Navigator.pushNamed(context, '/add-pet'),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.canopy.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primaryTerracotta),
                  const SizedBox(width: 6),
                  Text('Add Pet', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryTerracotta, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        return InkWell(
          onTap: () => _showPetSelectionSheet(context, petProvider),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.canopy.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPetAvatar(active, isSelected: true),
                const SizedBox(width: 8),
                Text(
                  active.name,
                  style: AppTypography.labelLarge.copyWith(fontSize: 13, color: AppColors.inkText),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.softTaupe),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetAvatar(Pet pet, {bool isSelected = false}) {
    final isBruno = pet.name.toLowerCase() == 'bruno';
    if (isBruno) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/bruno-jungle.jpg',
          width: 26,
          height: 26,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitial(pet),
        ),
      );
    }

    return _buildFallbackInitial(pet);
  }

  Widget _buildFallbackInitial(Pet pet) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColors.pistachioSecondary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        pet.name.isNotEmpty ? pet.name[0].toUpperCase() : 'P',
        style: const TextStyle(
          color: AppColors.pistachioDark,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPetSelectionSheet(BuildContext context, PetProvider petProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Active Pet', style: AppTypography.displaySmall),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Switching pets updates your Care Trail, Health, and Reminders in real time.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: petProvider.pets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, index) {
                    final pet = petProvider.pets[index];
                    final isSelected = petProvider.activePet?.id == pet.id;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? AppColors.pistachioSecondary : AppColors.dividerColor,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      tileColor: isSelected ? AppColors.mossLight : Colors.transparent,
                      leading: _buildPetAvatar(pet, isSelected: isSelected),
                      title: Text(pet.name, style: AppTypography.labelLarge),
                      subtitle: Text('${pet.breed} • ${pet.age} yrs', style: AppTypography.bodySmall),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen)
                          : null,
                      onTap: () {
                        petProvider.selectPet(pet);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/add-pet');
                    },
                    icon: const Icon(Icons.add_rounded, color: AppColors.primaryTerracotta),
                    label: Text('Add New Pet Profile', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryTerracotta)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primaryTerracotta),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
