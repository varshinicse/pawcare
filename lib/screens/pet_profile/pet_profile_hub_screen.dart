import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'submodules/pet_profile_submodule.dart';
import 'submodules/pet_health_submodule.dart';
import 'submodules/pet_care_history_submodule.dart';
import 'submodules/pet_reminders_submodule.dart';

class PetProfileHubScreen extends StatefulWidget {
  final Pet? pet;
  final int initialTabIndex;

  const PetProfileHubScreen({
    super.key,
    this.pet,
    this.initialTabIndex = 0,
  });

  @override
  State<PetProfileHubScreen> createState() => _PetProfileHubScreenState();
}

class _PetProfileHubScreenState extends State<PetProfileHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _selectedPet = widget.pet;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPetSwitchDialog(BuildContext context, List<Pet> allPets, Pet currentPet) {
    showDialog(
      context: context,
      builder: (dContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Row(
            children: const [
              Icon(Icons.pets_rounded, color: AppColors.clayPrimary),
              SizedBox(width: 10),
              Text('Switch Active Pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: allPets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = allPets[index];
                final isSelected = p.id == currentPet.id;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.clayPrimary : AppColors.creamSurface,
                    child: Icon(
                      _getSpeciesIcon(p.species),
                      color: isSelected ? Colors.white : AppColors.clayPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.clayPrimary : AppColors.inkText,
                    ),
                  ),
                  subtitle: Text('${p.breed} • ${p.species.toUpperCase()}'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.clayPrimary)
                      : null,
                  onTap: () {
                    Navigator.of(dContext).pop();
                    Provider.of<PetProvider>(context, listen: false).selectPet(p);
                    setState(() {
                      _selectedPet = p;
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final allPets = petProvider.pets;

    // Resolve current active pet from Provider or widget parameter
    Pet? currentPet;
    if (_selectedPet != null) {
      currentPet = petProvider.getPetById(_selectedPet!.id) ?? petProvider.activePet;
    } else {
      currentPet = petProvider.activePet;
    }

    // Fallback if pets exist but none resolved
    if (currentPet == null && allPets.isNotEmpty) {
      currentPet = allPets.first;
    }

    if (currentPet == null) {
      return Scaffold(
        backgroundColor: AppColors.creamBase,
        appBar: AppBar(title: const Text('Pet Profile Hub 🐾')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pets_rounded, size: 64, color: AppColors.softTaupe),
              const SizedBox(height: 16),
              const Text('No pets registered yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/add-pet'),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Pet'),
              ),
            ],
          ),
        ),
      );
    }

    final activePet = currentPet;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${activePet.name}\'s Hub 🐾'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (allPets.length > 1)
            IconButton(
              tooltip: 'Switch Pet',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.clayLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.clayPrimary, size: 20),
              ),
              onPressed: () => _showPetSwitchDialog(context, allPets, activePet),
            ),
        ],
      ),
      body: Column(
        children: [
          // TOP PET IDENTITY BANNER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.clayPrimary.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pet Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.clayLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getSpeciesIcon(activePet.species),
                        size: 32,
                        color: AppColors.clayPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                activePet.name,
                                style: AppTypography.displaySmall.copyWith(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mossLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.mossAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${activePet.breed} • ${activePet.species.toUpperCase()}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('${activePet.age} yrs', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                            const Text(' • '),
                            Text('${activePet.weightKg} kg', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                            const Text(' • '),
                            Text(activePet.gender, style: AppTypography.labelSmall.copyWith(color: AppColors.softTaupe)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick switch icon
                  if (allPets.length > 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.clayPrimary),
                      onPressed: () => _showPetSwitchDialog(context, allPets, activePet),
                    ),
                ],
              ),
            ),
          ),

          // SUBMODULE NAVIGATION TAB BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.clayPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.inkText,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Health'),
                Tab(text: 'Care History'),
                Tab(text: 'Reminders'),
              ],
            ),
          ),

          // SUBMODULE VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PetProfileSubmodule(pet: activePet),
                PetHealthSubmodule(pet: activePet),
                PetCareHistorySubmodule(pet: activePet),
                PetRemindersSubmodule(pet: activePet),
              ],
            ),
          ),
        ],
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
