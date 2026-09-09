import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/reminder_model.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;
  final String petName;

  const EditReminderScreen({
    super.key,
    required this.reminder,
    this.petName = 'Pet',
  });

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _selectedType;
  late String _selectedRepeat;
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r.title);
    _notesController = TextEditingController(text: r.notes);
    _selectedType = r.type;
    _selectedRepeat = r.repeat;
    _selectedTime = TimeOfDay.fromDateTime(r.scheduledTime);
    _selectedDate = r.scheduledTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedScheduled = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updated = widget.reminder.copyWith(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      type: _selectedType,
      repeat: _selectedRepeat,
      scheduledTime: updatedScheduled,
    );

    final provider = Provider.of<ReminderProvider>(context, listen: false);
    await provider.updateReminder(updated, widget.petName);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder updated for ${widget.petName}! ⏰'), backgroundColor: AppColors.pistachioSecondary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _selectedTime.format(context);
    final dateStr = DateFormat('dd MMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text("Edit Reminder ⏰"),
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
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Reminder Category'),
                  items: const [
                    DropdownMenuItem(value: 'feeding', child: Text('Feeding Routine 🥣')),
                    DropdownMenuItem(value: 'medication', child: Text('Medication & Supplements 💊')),
                    DropdownMenuItem(value: 'grooming', child: Text('Grooming & Bath 🛁')),
                    DropdownMenuItem(value: 'vaccination', child: Text('Vaccination 💉')),
                    DropdownMenuItem(value: 'vet_visit', child: Text('Vet Appointment 🩺')),
                    DropdownMenuItem(value: 'walking', child: Text('Walking & Exercise 🦮')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Reminder Title *', prefixIcon: Icon(Icons.alarm_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.softTaupe),
                              const SizedBox(width: 8),
                              Text(dateStr, style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                          if (picked != null) setState(() => _selectedTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 18, color: AppColors.softTaupe),
                              const SizedBox(width: 8),
                              Text(timeStr, style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _selectedRepeat,
                  decoration: const InputDecoration(labelText: 'Repeat Interval'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('One-time Only')),
                    DropdownMenuItem(value: 'daily', child: Text('Repeat Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Repeat Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Repeat Monthly')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRepeat = val);
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes / Dosage / Instructions', prefixIcon: Icon(Icons.note_alt_outlined)),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _save,
                    child: const Text('Save Reminder Changes ⏰'),
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
