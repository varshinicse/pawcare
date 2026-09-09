import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class AddPetScreen extends StatefulWidget {
  final Pet? petToEdit;

  const AddPetScreen({super.key, this.petToEdit});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _weightController;
  late final TextEditingController _colorController;

  // Owner Info Controllers
  late final TextEditingController _ownerNameController;
  late final TextEditingController _ownerPhoneController;
  late final TextEditingController _ownerEmailController;

  // Additional Info Controllers
  late final TextEditingController _foodHabitsController;
  late final TextEditingController _specialCareController;
  late final TextEditingController _notesController;
  final TextEditingController _allergyInputController = TextEditingController();

  String _species = 'dog';
  String _gender = 'Male';
  late DateTime _birthdate;
  List<String> _allergies = [];

  final List<String> _speciesList = [
    'dog',
    'cat',
    'fish',
    'bird',
    'rabbit',
    'reptile',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    final pet = widget.petToEdit;

    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? 'Golden Retriever');
    _weightController = TextEditingController(text: (pet?.weightKg != null && pet!.weightKg > 0) ? pet.weightKg.toString() : '5.0');
    _colorController = TextEditingController(text: pet?.color ?? '');

    _ownerNameController = TextEditingController(text: pet?.ownerName ?? 'Pet Shop Owner');
    _ownerPhoneController = TextEditingController(text: pet?.ownerPhone ?? '+91 98765 43210');
    _ownerEmailController = TextEditingController(text: pet?.ownerEmail ?? 'owner@pawcare.com');

    _foodHabitsController = TextEditingController(text: pet?.foodHabits ?? '');
    _specialCareController = TextEditingController(text: pet?.specialCareInstructions ?? '');
    _notesController = TextEditingController(text: pet?.notes ?? '');

    _species = pet?.species ?? 'dog';
    _gender = pet?.gender ?? 'Male';
    _birthdate = pet?.birthdate ?? DateTime.now().subtract(const Duration(days: 365));
    _allergies = List.from(pet?.allergies ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _foodHabitsController.dispose();
    _specialCareController.dispose();
    _notesController.dispose();
    _allergyInputController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  double _calculateAgeYears() {
    final days = DateTime.now().difference(_birthdate).inDays;
    final years = days / 365.25;
    return double.parse(years.toStringAsFixed(1));
  }

  void _addAllergy(String allergy) {
    final trimmed = allergy.trim();
    if (trimmed.isNotEmpty && !_allergies.contains(trimmed)) {
      setState(() {
        _allergies.add(trimmed);
        _allergyInputController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
  }

  void _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final isEditing = widget.petToEdit != null;

    final petId = isEditing
        ? widget.petToEdit!.id
        : 'pet_${DateTime.now().millisecondsSinceEpoch}';

    final age = _calculateAgeYears();
    final weight = double.tryParse(_weightController.text.trim()) ?? 5.0;

    final savedPet = Pet(
      id: petId,
      ownerId: 'default_user',
      name: _nameController.text.trim(),
      species: _species,
      breed: _breedController.text.trim().isNotEmpty ? _breedController.text.trim() : 'Mixed',
      age: age,
      weightKg: weight,
      foodHabits: _foodHabitsController.text.trim(),
      medicalHistory: widget.petToEdit?.medicalHistory ?? [],
      avatarAsset: '${_species}_hero',
      createdAt: widget.petToEdit?.createdAt ?? DateTime.now(),
      gender: _gender,
      birthdate: _birthdate,
      color: _colorController.text.trim(),
      allergies: _allergies,
      ownerName: _ownerNameController.text.trim().isNotEmpty ? _ownerNameController.text.trim() : 'Pet Shop Owner',
      ownerPhone: _ownerPhoneController.text.trim(),
      ownerEmail: _ownerEmailController.text.trim(),
      specialCareInstructions: _specialCareController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (isEditing) {
      await petProvider.updatePet(savedPet);
    } else {
      await petProvider.addPet(savedPet);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Pet profile updated! 🐾' : '${savedPet.name} added to My Pets! 🐾'),
          backgroundColor: AppColors.mossAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.petToEdit != null;
    final age = _calculateAgeYears();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit ${widget.petToEdit!.name} 🐾' : 'Add New Pet 🐾'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: BASIC INFORMATION
              _buildSectionTitle('1. BASIC INFORMATION', Icons.pets_rounded),
              const SizedBox(height: 14),

              // Species selector chips
              Text('PET TYPE / SPECIES', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _speciesList.map((s) {
                  final isSel = _species == s;
                  return ChoiceChip(
                    label: Text(s.toUpperCase()),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _species = s);
                    },
                    selectedColor: AppColors.clayPrimary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSel ? AppColors.clayPrimary : AppColors.dividerColor,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Pet Name
              Text('PET NAME *', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Bruno, Luna, Nemo, Charlie',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your pet\'s name' : null,
              ),

              const SizedBox(height: 16),

              // Breed & Color row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BREED / SUBTYPE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _breedController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Golden Retriever',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.dividerColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COLOR / MARKINGS', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _colorController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Golden, Tricolor',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.dividerColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Gender Selector
              Text('GENDER', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female'].map((g) {
                  final isSel = _gender == g;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(g),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _gender = g);
                      },
                      selectedColor: AppColors.clayPrimary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.inkText,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSel ? AppColors.clayPrimary : AppColors.dividerColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Date of Birth & Weight
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DATE OF BIRTH', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickBirthdate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.dividerColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.cake_rounded, size: 18, color: AppColors.clayPrimary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${DateHelpers.formatDateShort(_birthdate)} ($age yrs)',
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WEIGHT (KG)', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'e.g. 28.5',
                            filled: true,
                            fillColor: Colors.white,
                            suffixText: 'kg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.dividerColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // SECTION 2: OWNER INFORMATION
              _buildSectionTitle('2. OWNER INFORMATION', Icons.person_outline_rounded),
              const SizedBox(height: 14),

              Text('OWNER NAME', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ownerNameController,
                decoration: InputDecoration(
                  hintText: 'Pet Shop Owner / Varshini',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PHONE NUMBER', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ownerPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+91 98765 43210',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.dividerColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EMAIL ADDRESS', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ownerEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'owner@pawcare.com',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.dividerColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // SECTION 3: ADDITIONAL INFORMATION
              _buildSectionTitle('3. CARE & DIETARY PREFERENCES', Icons.medical_services_outlined),
              const SizedBox(height: 14),

              // Food Preferences
              Text('FOOD PREFERENCES & HABITS', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _foodHabitsController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Royal Canin Maxi Puppy - Twice daily (8 AM, 7 PM)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Allergies Tag Input
              Text('ALLERGIES & RESTRICTIONS', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyInputController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Chicken, Grain, Flea Drops',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.dividerColor),
                        ),
                      ),
                      onSubmitted: _addAllergy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clayPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _addAllergy(_allergyInputController.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
              if (_allergies.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergies.map((allergy) {
                    return Chip(
                      label: Text(allergy),
                      backgroundColor: AppColors.alertLight,
                      labelStyle: const TextStyle(color: AppColors.alertCoral, fontWeight: FontWeight.bold, fontSize: 12),
                      deleteIconColor: AppColors.alertCoral,
                      onDeleted: () => _removeAllergy(allergy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.alertCoral.withValues(alpha: 0.3)),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 16),

              // Special Care Instructions
              Text('SPECIAL CARE INSTRUCTIONS', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _specialCareController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Needs eye drops after bath, sensitive paws, brush undercoat daily',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              Text('GENERAL NOTES', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Any additional personality traits or behavior notes',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clayPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _savePet,
                  icon: const Icon(Icons.check_rounded, size: 22),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Register Pet',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.clayPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.displaySmall.copyWith(
            fontSize: 15,
            letterSpacing: 0.8,
            color: AppColors.clayPrimary,
          ),
        ),
      ],
    );
  }
}
