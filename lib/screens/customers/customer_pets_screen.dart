import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../pet_profile/add_pet_screen.dart';
import '../pet_profile/pet_profile_hub_screen.dart';

class CustomerPetsScreen extends StatelessWidget {
  final Customer customer;
  final List<Pet>? pets;

  const CustomerPetsScreen({
    super.key,
    required this.customer,
    this.pets,
  });

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final displayPets = pets ??
        petProvider.pets
            .where((p) => customer.registeredPetIds.contains(p.id))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text("${customer.name}'s Pets 🐾"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Pet for Customer',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPetScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: displayPets.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets_rounded, size: 48, color: AppColors.softTaupe),
                    const SizedBox(height: 12),
                    Text('No pets registered yet for ${customer.name}', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddPetScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Pet'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTerracotta),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: displayPets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, index) {
                  final pet = displayPets[index];
                  final isBruno = pet.name.toLowerCase() == 'bruno';

                  return InkWell(
                    onTap: () {
                      petProvider.selectPet(pet);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PetProfileHubScreen(pet: pet)),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.canopy.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: isBruno
                                ? Image.asset(
                                    'assets/images/bruno-jungle.jpg',
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildAvatarFallback(pet),
                                  )
                                : _buildAvatarFallback(pet),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(pet.name, style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.mossLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Active Care',
                                        style: AppTypography.labelSmall.copyWith(color: AppColors.pistachioDark, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${pet.species.toUpperCase()} • ${pet.breed}', style: AppTypography.bodySmall),
                                const SizedBox(height: 4),
                                Text('Weight: ${pet.weightKg} kg • Age: ${pet.age} yrs', style: AppTypography.labelSmall.copyWith(color: AppColors.softTaupe)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.softTaupe),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAvatarFallback(Pet pet) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.pistachioSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        pet.name.isNotEmpty ? pet.name[0].toUpperCase() : 'P',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pistachioDark),
      ),
    );
  }
}
