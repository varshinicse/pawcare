import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../notifications/notifications_screen.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'feeding';
  String _selectedRepeat = 'daily';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
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

    final activePet = petProvider.activePet;
    final petId = activePet?.id ?? 'pet_bruno_1';
    final petName = activePet?.name ?? 'Bruno';

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      type: _selectedType,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      scheduledTime: scheduledDateTime,
      repeat: _selectedRepeat,
      isCompleted: false,
    );

    await reminderProvider.addReminder(newReminder, petName);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder "${newReminder.title}" scheduled! 🐾'),
          backgroundColor: AppColors.mossAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('New Pet Reminder ⏰'),
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
              // Reminder Type Chips
              Text('Reminder Type', style: AppTypography.labelLarge),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.reminderTypes.map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type.toUpperCase()),
                        selected: isSelected,
                        selectedColor: AppColors.clayPrimary,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.inkText,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedType = type);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text('Reminder Title', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Evening Kibble or Rabies Shot',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 20),

              // Time & Date Picker Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time', style: AppTypography.labelLarge),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.dividerColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: AppColors.clayPrimary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedTime.format(context),
                                  style: AppTypography.numericData,
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
                        Text('Date', style: AppTypography.labelLarge),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.dividerColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: AppColors.clayPrimary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  DateHelpers.formatDateShort(_selectedDate),
                                  style: AppTypography.numericData.copyWith(fontSize: 13),
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

              // Repeat Rule Dropdown
              Text('Repeat Rule', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRepeat,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Repeat Daily 🔄')),
                  DropdownMenuItem(value: 'weekly', child: Text('Repeat Weekly 📅')),
                  DropdownMenuItem(value: 'once', child: Text('One-time Only 📌')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRepeat = val);
                },
              ),

              const SizedBox(height: 20),

              // Notes / Instructions
              Text('Notes & Instructions', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Mix 1 tablet with wet food',
                ),
              ),

              const SizedBox(height: 36),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  child: const Text('Schedule Reminder 🐾'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
