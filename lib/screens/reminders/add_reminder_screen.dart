import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../models/reminder_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminderToEdit;
  final String? targetPetId;

  const AddReminderScreen({
    super.key,
    this.reminderToEdit,
    this.targetPetId,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPetId;
  String _selectedCategory = 'feeding';
  String _selectedRepeat = 'daily';
  bool _notificationEnabled = true;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  final List<String> _repeatOptions = [
    'once',
    'daily',
    'weekly',
    'monthly',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.reminderToEdit;
    if (r != null) {
      _selectedPetId = r.petId;
      _titleController.text = r.title;
      _notesController.text = r.notes;
      _selectedCategory = r.type;
      _selectedRepeat = r.repeat.toLowerCase();
      _notificationEnabled = r.notificationEnabled;
      _selectedDate = r.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(r.scheduledTime);
    } else {
      _selectedPetId = widget.targetPetId;
      _selectedRepeat = 'daily';
      _notificationEnabled = true;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> _getCategoriesForSpecies(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return ['feeding', 'grooming', 'litter_cleaning', 'medication', 'bathing', 'custom_task'];
      case 'fish':
        return ['feeding', 'water_change', 'tank_cleaning', 'filter_cleaning', 'temperature_check', 'custom_task'];
      case 'bird':
        return ['feeding', 'cage_cleaning', 'water_replacement', 'health_check', 'custom_task'];
      case 'rabbit':
        return ['feeding', 'cage_cleaning', 'grooming', 'health_check', 'custom_task'];
      case 'dog':
      default:
        return ['feeding', 'walking', 'grooming', 'medication', 'vaccination', 'bathing', 'custom_task'];
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);

    // Resolve target pet
    final petId = _selectedPetId ?? petProvider.activePet?.id ?? 'pet_bruno_1';
    final targetPet = petProvider.getPetById(petId) ?? petProvider.activePet;
    final petName = targetPet?.name ?? 'your pet';

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (widget.reminderToEdit != null) {
      final updated = widget.reminderToEdit!.copyWith(
        petId: petId,
        type: _selectedCategory,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        scheduledTime: scheduledDateTime,
        repeat: _selectedRepeat,
        notificationEnabled: _notificationEnabled,
        updatedAt: DateTime.now(),
      );
      await reminderProvider.updateReminder(updated, petName);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder "${updated.title}" updated! ⏰'),
            backgroundColor: AppColors.mossAccent,
          ),
        );
      }
    } else {
      final newReminder = Reminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
        petId: petId,
        type: _selectedCategory,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        scheduledTime: scheduledDateTime,
        repeat: _selectedRepeat,
        notificationEnabled: _notificationEnabled,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await reminderProvider.addReminder(newReminder, petName);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder "${newReminder.title}" scheduled for $petName! ⏰'),
            backgroundColor: AppColors.mossAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final allPets = petProvider.pets;

    _selectedPetId ??= widget.targetPetId ?? petProvider.activePet?.id ?? (allPets.isNotEmpty ? allPets.first.id : null);
    final selectedPet = allPets.firstWhere(
      (p) => p.id == _selectedPetId,
      orElse: () => petProvider.activePet ?? (allPets.isNotEmpty ? allPets.first : Pet(
        id: 'default',
        ownerId: 'default',
        name: 'Bruno',
        species: 'dog',
        breed: 'Golden Retriever',
        age: 2,
        weightKg: 28,
        foodHabits: '',
        medicalHistory: [],
        avatarAsset: 'dog_hero',
        createdAt: DateTime.now(),
      )),
    );

    final availableCategories = _getCategoriesForSpecies(selectedPet.species);
    if (!availableCategories.contains(_selectedCategory)) {
      _selectedCategory = availableCategories.first;
    }

    final isEditing = widget.reminderToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder ⏰' : 'New Reminder ⏰'),
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
              // 1. SELECT PET (if more than 1 pet exists)
              if (allPets.length > 1) ...[
                Text('FOR WHICH PET?', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedPetId,
                      items: allPets.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Row(
                            children: [
                              const Icon(Icons.pets_rounded, size: 18, color: AppColors.clayPrimary),
                              const SizedBox(width: 10),
                              Text('${p.name} (${p.species.toUpperCase()})', style: AppTypography.bodyMedium),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPetId = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 2. TASK CATEGORY
              Text(
                'TASK CATEGORY (${selectedPet.species.toUpperCase()})',
                style: AppTypography.labelMedium.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableCategories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  final formatted = cat.replaceAll('_', ' ').toUpperCase();
                  return ChoiceChip(
                    label: Text(formatted),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
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

              const SizedBox(height: 20),

              // 3. TITLE
              Text('REMINDER TITLE *', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Evening Meal, Probiotic Tablet, Tank Water Change',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a reminder title' : null,
              ),

              const SizedBox(height: 18),

              // 4. DATE & TIME PICKERS
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DATE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
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
                                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.clayPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  DateHelpers.formatDateShort(_selectedDate),
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
                        Text('TIME', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickTime,
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
                                const Icon(Icons.access_time_rounded, size: 18, color: AppColors.clayPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 5. REPEAT TYPE
              Text('REPEAT SCHEDULE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 8),
              Row(
                children: _repeatOptions.map((opt) {
                  final isSel = _selectedRepeat == opt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(opt.toUpperCase()),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedRepeat = opt);
                      },
                      selectedColor: AppColors.clayPrimary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.inkText,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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

              const SizedBox(height: 20),

              // 6. NOTIFICATION TOGGLE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _notificationEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                          color: _notificationEnabled ? AppColors.clayPrimary : AppColors.softTaupe,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Device Notification', style: AppTypography.labelLarge),
                            Text(
                              _notificationEnabled ? 'Alert on scheduled time' : 'Silent, in-app only',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _notificationEnabled,
                      activeTrackColor: AppColors.clayPrimary,
                      onChanged: (val) => setState(() => _notificationEnabled = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 7. NOTES / DESCRIPTION
              Text('NOTES / INSTRUCTIONS (OPTIONAL)', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. 1 chewable tablet after breakfast, give with warm water',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 8. SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clayPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  onPressed: _saveReminder,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    isEditing ? 'Save Reminder Changes' : 'Schedule Reminder',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
