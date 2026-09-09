import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
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
          IconButton(
            tooltip: 'Add New Pet',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.clayPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPetScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.clayPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Pet', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
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
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search pets by name, breed, species...',
                  hintStyle: AppTypography.bodySmall,
                  border: InputBorder.none,
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
                      color: AppColors.mossLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.mossAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Active: ${activePet.name}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.mossAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // PET LIST OR EMPTY STATE
            if (petProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (allPets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: AppColors.clayLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets_rounded, size: 36, color: AppColors.clayPrimary),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No pets registered yet.',
                      style: AppTypography.displaySmall.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first pet to get started with Profile, Health, Care History, and Reminders!',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.clayPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddPetScreen()),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Your First Pet'),
                    ),
                  ],
                ),
              )
            else if (filteredPets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: AppColors.softTaupe),
                    const SizedBox(height: 12),
                    Text(
                      'No pets match "$_searchQuery"',
                      style: AppTypography.displaySmall.copyWith(fontSize: 16),
                    ),
                  ],
                ),
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
    );
  }

  Widget _buildPetCard(
    BuildContext context,
    Pet pet,
    bool isActive,
    PetProvider petProvider,
  ) {
    return GestureDetector(
      onTap: () {
        petProvider.selectPet(pet);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetProfileHubScreen(pet: pet)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isActive ? AppColors.clayPrimary : AppColors.dividerColor,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.clayPrimary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pet Photo Avatar
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.clayLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getSpeciesIcon(pet.species),
                      size: 32,
                      color: AppColors.clayPrimary,
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.mossAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

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
                            color: AppColors.mossLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.mossAccent,
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
                  const SizedBox(height: 6),
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
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.inkText,
        ),
      ),
    );
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return Icons.pets_rounded;
      case 'fish':
        return Icons.water_drop_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      case 'dog':
      default:
        return Icons.pets_rounded;
    }
  }
}
