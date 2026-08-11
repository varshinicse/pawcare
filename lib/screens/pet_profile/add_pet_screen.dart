import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/constants.dart';

class AddPetScreen extends StatefulWidget {
  final Pet? petToEdit;

  const AddPetScreen({super.key, this.petToEdit});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _foodHabitsController = TextEditingController();
  final _customTagController = TextEditingController();

  String _species = 'dog';
  String _selectedBreed = 'Golden Retriever';
  List<String> _medicalHistoryTags = [];

  @override
  void initState() {
    super.initState();
    if (widget.petToEdit != null) {
      final pet = widget.petToEdit!;
      _nameController.text = pet.name;
      _ageController.text = pet.age.toString();
      _weightController.text = pet.weightKg.toString();
      _foodHabitsController.text = pet.foodHabits;
      _species = pet.species;
      _selectedBreed = pet.breed;
      _medicalHistoryTags = List.from(pet.medicalHistory);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _foodHabitsController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _addMedicalTag(String tag) {
    if (tag.trim().isNotEmpty && !_medicalHistoryTags.contains(tag.trim())) {
      setState(() {
        _medicalHistoryTags.add(tag.trim());
        _customTagController.clear();
      });
    }
  }

  void _removeMedicalTag(String tag) {
    setState(() {
      _medicalHistoryTags.remove(tag);
    });
  }

  void _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final petProvider = Provider.of<PetProvider>(context, listen: false);

    final newPet = Pet(
      id: widget.petToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: 'default_user',
      name: _nameController.text.trim(),
      species: _species,
      breed: _selectedBreed,
      age: double.tryParse(_ageController.text) ?? 1.0,
      weightKg: double.tryParse(_weightController.text) ?? 5.0,
      foodHabits: _foodHabitsController.text.trim(),
      medicalHistory: _medicalHistoryTags,
      avatarAsset: _species == 'cat' ? 'cat_hero' : 'dog_hero',
      createdAt: widget.petToEdit?.createdAt ?? DateTime.now(),
    );

    if (widget.petToEdit != null) {
      await petProvider.updatePet(newPet);
    } else {
      await petProvider.addPet(newPet);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final breedsList = _species == 'dog' ? AppConstants.dogBreeds : AppConstants.catBreeds;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(widget.petToEdit == null ? 'Add New Pet 🐾' : 'Edit Pet Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Species Toggle
              Text('Pet Species', style: AppTypography.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _species = 'dog';
                          _selectedBreed = AppConstants.dogBreeds.first;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _species == 'dog' ? AppColors.clayPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _species == 'dog' ? AppColors.clayPrimary : AppColors.dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets_rounded,
                              color: _species == 'dog' ? Colors.white : AppColors.inkText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dog 🐶',
                              style: AppTypography.labelLarge.copyWith(
                                color: _species == 'dog' ? Colors.white : AppColors.inkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _species = 'cat';
                          _selectedBreed = AppConstants.catBreeds.first;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _species == 'cat' ? AppColors.clayPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _species == 'cat' ? AppColors.clayPrimary : AppColors.dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets_rounded,
                              color: _species == 'cat' ? Colors.white : AppColors.inkText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cat 🐱',
                              style: AppTypography.labelLarge.copyWith(
                                color: _species == 'cat' ? Colors.white : AppColors.inkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pet Name
              Text('Pet Name', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Bruno or Luna'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter pet name' : null,
              ),

              const SizedBox(height: 20),

              // Breed Dropdown
              Text('Breed', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: breedsList.contains(_selectedBreed) ? _selectedBreed : breedsList.first,
                decoration: const InputDecoration(),
                items: breedsList.map((breed) {
                  return DropdownMenuItem(
                    value: breed,
                    child: Text(breed, style: AppTypography.bodyMedium),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBreed = val);
                },
              ),

              const SizedBox(height: 20),

              // Age & Weight Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age (Years)', style: AppTypography.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(hintText: 'e.g. 2.5'),
                          validator: (val) => val == null || val.isEmpty ? 'Enter age' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weight (Kg)', style: AppTypography.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(hintText: 'e.g. 14.2'),
                          validator: (val) => val == null || val.isEmpty ? 'Enter weight' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Food Habits
              Text('Food Habits & Portion Size', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _foodHabitsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Royal Canin 1.5 cups twice daily at 8 AM and 7 PM',
                ),
              ),

              const SizedBox(height: 24),

              // Medical History (Chip-based Input)
              Text('Medical History & Tags', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              Text(
                'Tap standard tags or type custom medical observations below:',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.commonMedicalTags.map((tag) {
                  final isSelected = _medicalHistoryTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: AppColors.clayPrimary,
                    checkmarkColor: Colors.white,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.inkText,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _addMedicalTag(tag);
                      } else {
                        _removeMedicalTag(tag);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customTagController,
                      decoration: const InputDecoration(
                        hintText: 'Add custom note (e.g. Sensitive ears)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _addMedicalTag(_customTagController.text),
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.clayPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _savePet,
                  child: Text(widget.petToEdit == null ? 'Save Pet Profile 🐾' : 'Update Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
