import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_design_tokens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/animated_paw_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/paw_buttons.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/pet_background_wrapper.dart';
import 'add_pet_screen.dart';
import 'pet_profile_hub_screen.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete ${pet.name}?'),
        content: Text('Are you sure you want to remove ${pet.name}\'s profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () async {
              Navigator.of(dContext).pop();
              await Provider.of<PetProvider>(context, listen: false).deletePet(pet.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pet.name}\'s profile removed.'),
                    backgroundColor: AppColors.alertCoral,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final allPets = petProvider.pets;
    final activePet = petProvider.activePet;

    final filteredPets = allPets.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.breed.toLowerCase().contains(q) ||
          p.species.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('My Pets 🐾'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PawIconButton(
              icon: Icons.add,
              tooltip: 'Add New Pet',
              backgroundColor: AppColors.primaryTerracotta,
              iconColor: Colors.white,
              size: 38,
              iconSize: 20,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPetScreen()),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTerracotta,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Pet', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
        },
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_dog_friends.jpg',
        imageOpacity: 0.12,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                  boxShadow: AppShadows.softSm,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search pets by name, breed, species...',
                    hintStyle: AppTypography.bodySmall,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: const Icon(Icons.search_rounded, color: AppColors.softTaupe),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.softTaupe),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Registered Pets (${filteredPets.length})',
                    style: AppTypography.displaySmall.copyWith(fontSize: 18),
                  ),
                  if (activePet != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pistachioLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.pistachioDark),
                          const SizedBox(width: 4),
                          Text(
                            'Active: ${activePet.name}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.pistachioDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // PET LIST OR SKELETON OR EMPTY STATE
              if (petProvider.isLoading)
                const ListSkeleton(count: 3)
              else if (allPets.isEmpty)
                EmptyStateWidget(
                  title: 'No pets registered yet',
                  description: 'Add your first pet to unlock daily schedules, health tracking, care history, and reminders!',
                  buttonText: 'Add Your First Pet',
                  onButtonPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddPetScreen()),
                    );
                  },
                )
              else if (filteredPets.isEmpty)
                EmptyStateWidget(
                  title: 'No matching pets',
                  description: 'We couldn\'t find any pets matching "$_searchQuery". Try searching for another name or breed.',
                  icon: Icons.search_off_rounded,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final pet = filteredPets[index];
                    final isActive = activePet?.id == pet.id;
                    return _buildPetCard(context, pet, isActive, petProvider);
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(
    BuildContext context,
    Pet pet,
    bool isActive,
    PetProvider petProvider,
  ) {
    return AnimatedPawCard(
      onTap: () {
        petProvider.selectPet(pet);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetProfileHubScreen(pet: pet)),
        );
      },
      isSelected: isActive,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pet Photo Avatar
          PetAvatar(
            species: pet.species,
            avatarAsset: pet.avatarAsset,
            size: 62,
            isActive: isActive,
            showBadge: isActive,
            heroTag: 'pet_avatar_${pet.id}',
          ),
          const SizedBox(width: 14),

          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        pet.name,
                        style: AppTypography.displaySmall.copyWith(fontSize: 17),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.pistachioLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.pistachioDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${pet.breed} • ${pet.species.toUpperCase()}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildChip('${pet.age} yrs'),
                    const SizedBox(width: 6),
                    _buildChip('${pet.weightKg} kg'),
                    const SizedBox(width: 6),
                    _buildChip(pet.gender),
                  ],
                ),
              ],
            ),
          ),

          // Card Action Buttons
          Column(
            children: [
              IconButton(
                tooltip: 'Edit Pet',
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.softTaupe),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddPetScreen(petToEdit: pet)),
                  );
                },
              ),
              IconButton(
                tooltip: 'Delete Pet',
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.alertCoral),
                onPressed: () => _confirmDelete(context, pet),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.inkText,
        ),
      ),
    );
  }
}

