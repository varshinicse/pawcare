import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_record_model.dart';
import '../../providers/health_record_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AddEditHealthRecordScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final HealthRecord? existingRecord;

  const AddEditHealthRecordScreen({
    super.key,
    required this.petId,
    this.petName = 'Pet',
    HealthRecord? existingRecord,
    HealthRecord? recordToEdit,
  }) : existingRecord = existingRecord ?? recordToEdit;

  @override
  State<AddEditHealthRecordScreen> createState() => _AddEditHealthRecordScreenState();
}

class _AddEditHealthRecordScreenState extends State<AddEditHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _vetController;
  late TextEditingController _weightController;
  late TextEditingController _tempController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    _titleController = TextEditingController(text: r?.title ?? '');
    _descController = TextEditingController(text: r?.description ?? '');
    _vetController = TextEditingController(text: r?.veterinarianName ?? 'Dr. Ramesh Kumar');
    _weightController = TextEditingController(text: r != null && r.weightKg > 0 ? r.weightKg.toString() : '');
    _tempController = TextEditingController(text: r != null && r.temperatureCelsius > 0 ? r.temperatureCelsius.toString() : '38.4');
    _selectedType = r?.type ?? 'prescription';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _vetController.dispose();
    _weightController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final vet = _vetController.text.trim().isNotEmpty ? _vetController.text.trim() : 'Dr. Ramesh Kumar';
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final temp = double.tryParse(_tempController.text.trim()) ?? 38.4;

    final hrProvider = Provider.of<HealthRecordProvider>(context, listen: false);

    if (widget.existingRecord != null) {
      final updated = widget.existingRecord!.copyWith(
        title: title,
        description: desc,
        type: _selectedType,
        veterinarianName: vet,
        weightKg: weight,
        temperatureCelsius: temp,
      );
      hrProvider.updateRecord(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clinical log updated! 📋'), backgroundColor: AppColors.pistachioSecondary),
      );
    } else {
      final newRecord = HealthRecord(
        id: 'hr_${DateTime.now().millisecondsSinceEpoch}',
        petId: widget.petId,
        type: _selectedType,
        title: title,
        description: desc,
        date: DateTime.now(),
        veterinarianName: vet,
        weightKg: weight,
        temperatureCelsius: temp,
      );
      hrProvider.addRecord(newRecord);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clinical log saved! 🐾'), backgroundColor: AppColors.pistachioSecondary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Clinical Log 📋' : 'Add Clinical Log 📋'),
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
                  decoration: const InputDecoration(labelText: 'Record Type'),
                  items: const [
                    DropdownMenuItem(value: 'prescription', child: Text('Prescription Medicine')),
                    DropdownMenuItem(value: 'vaccination', child: Text('Vaccination Record')),
                    DropdownMenuItem(value: 'surgery', child: Text('Surgery Record')),
                    DropdownMenuItem(value: 'vet_note', child: Text('Veterinarian Notes')),
                    DropdownMenuItem(value: 'lab_report', child: Text('Lab / Check-up Report')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Treatment / Diagnosis Title *', prefixIcon: Icon(Icons.medical_services_outlined)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter title' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _vetController,
                  decoration: const InputDecoration(labelText: 'Attending Veterinarian', prefixIcon: Icon(Icons.person_pin_circle_outlined)),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.scale_rounded)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _tempController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Temp (°C)', prefixIcon: Icon(Icons.thermostat_rounded)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Instructions / Prescription Details',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
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
                    child: Text(isEditing ? 'Update Clinical Record' : 'Save Clinical Record 🐾'),
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
