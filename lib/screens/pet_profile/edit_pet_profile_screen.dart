import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class EditPetProfileScreen extends StatefulWidget {
  final Pet pet;

  const EditPetProfileScreen({super.key, required this.pet});

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _foodHabitsController;
  late TextEditingController _medicalHistoryController;
  late String _selectedSpecies;

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _nameController = TextEditingController(text: p.name);
    _breedController = TextEditingController(text: p.breed);
    _ageController = TextEditingController(text: p.age.toString());
    _weightController = TextEditingController(text: p.weightKg.toString());
    _foodHabitsController = TextEditingController(text: p.foodHabits);
    _medicalHistoryController = TextEditingController(text: p.medicalHistory.join(', '));
    _selectedSpecies = p.species;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _foodHabitsController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final age = double.tryParse(_ageController.text.trim()) ?? widget.pet.age;
    final weight = double.tryParse(_weightController.text.trim()) ?? widget.pet.weightKg;
    final medical = _medicalHistoryController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updated = widget.pet.copyWith(
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      breed: _breedController.text.trim(),
      age: age,
      weightKg: weight,
      foodHabits: _foodHabitsController.text.trim(),
      medicalHistory: medical,
    );

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    await petProvider.updatePet(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${updated.name}'s profile updated! 🐾"),
          backgroundColor: AppColors.pistachioSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text("Edit ${widget.pet.name}'s Profile 🐾"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Species Selector
                Text('Species', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: ['dog', 'cat', 'rabbit', 'bird'].map((species) {
                    final isSelected = _selectedSpecies.toLowerCase() == species;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(species.toUpperCase()),
                        selected: isSelected,
                        selectedColor: AppColors.primaryTerracotta,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.inkText,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSpecies = species);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Pet Name *', prefixIcon: Icon(Icons.pets_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter pet name' : null,
                ),
                const SizedBox(height: 14),

                // Breed
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(labelText: 'Breed *', prefixIcon: Icon(Icons.category_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter breed' : null,
                ),
                const SizedBox(height: 14),

                // Age & Weight
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Age (Years) *', prefixIcon: Icon(Icons.cake_rounded)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter age' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Weight (kg) *', prefixIcon: Icon(Icons.scale_rounded)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter weight' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Food Habits
                TextFormField(
                  controller: _foodHabitsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Food Habits & Routine Diet',
                    prefixIcon: Icon(Icons.restaurant_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                // Medical History
                TextFormField(
                  controller: _medicalHistoryController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Medical History & Allergies (comma-separated)',
                    prefixIcon: Icon(Icons.healing_rounded),
                    hintText: 'e.g. Vaccinated, Sensitive Stomach, Neutered',
                  ),
                ),
                const SizedBox(height: 28),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _saveProfile,
                    child: const Text('Save Profile Updates 🐾'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
