import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/health_record_model.dart';
import '../../../providers/health_record_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';

class AddEditHealthRecordDialog extends StatefulWidget {
  final String petId;
  final String petName;
  final HealthRecord? recordToEdit;

  const AddEditHealthRecordDialog({
    super.key,
    required this.petId,
    required this.petName,
    this.recordToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required String petId,
    required String petName,
    HealthRecord? recordToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => AddEditHealthRecordDialog(
        petId: petId,
        petName: petName,
        recordToEdit: recordToEdit,
      ),
    );
  }

  @override
  State<AddEditHealthRecordDialog> createState() => _AddEditHealthRecordDialogState();
}

class _AddEditHealthRecordDialogState extends State<AddEditHealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _vetController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  late String _selectedType;
  late DateTime _selectedDate;

  final List<String> _recordTypes = [
    'Vaccination',
    'Vet Visit',
    'Medication',
    'Weight',
    'General Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.recordToEdit;
    _titleController = TextEditingController(text: r?.title ?? '');
    _descController = TextEditingController(text: r?.description ?? '');
    _vetController = TextEditingController(text: r?.veterinarianName ?? 'Dr. Ramesh Kumar');
    _weightController = TextEditingController(text: (r?.weightKg != null && r!.weightKg > 0) ? r.weightKg.toString() : '');
    _notesController = TextEditingController(text: r?.notes ?? '');
    _selectedType = r?.type ?? 'Vaccination';
    _selectedDate = r?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _vetController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<HealthRecordProvider>(context, listen: false);
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;

    if (widget.recordToEdit != null) {
      final updated = widget.recordToEdit!.copyWith(
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: _selectedDate,
        veterinarianName: _vetController.text.trim(),
        weightKg: weight,
        notes: _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await provider.updateRecord(updated);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health record updated for ${widget.petName}! 🩺'),
            backgroundColor: AppColors.mossAccent,
          ),
        );
      }
    } else {
      final newRecord = HealthRecord(
        id: 'hr_${DateTime.now().millisecondsSinceEpoch}',
        petId: widget.petId,
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: _selectedDate,
        veterinarianName: _vetController.text.trim(),
        weightKg: weight,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await provider.addRecord(newRecord);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New health record saved for ${widget.petName}! 🩺'),
            backgroundColor: AppColors.mossAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Health Record' : 'Add Health Record 🩺',
                      style: AppTypography.displaySmall.copyWith(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  'Record medical event or vital for ${widget.petName}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 20),

                // Record Type Selector
                Text('RECORD TYPE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recordTypes.map((type) {
                    final isSel = _selectedType.toLowerCase() == type.toLowerCase();
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = type);
                      },
                      selectedColor: AppColors.clayPrimary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.inkText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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

                const SizedBox(height: 18),

                // Title
                Text('TITLE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Annual Rabies Booster, Dental Clean',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a record title' : null,
                ),

                const SizedBox(height: 16),

                // Date Picker & Weight row
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

                const SizedBox(height: 16),

                // Veterinarian
                Text('VETERINARIAN / CLINIC', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _vetController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Dr. Ramesh Kumar / City Vet Care',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.medical_services_outlined, size: 20, color: AppColors.clayPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text('DESCRIPTION / FINDINGS', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Details of the treatment, dosage, or examination outcome',
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
                Text('ADDITIONAL NOTES (OPTIONAL)', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Follow-up recommendations, dietary advice, etc.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clayPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(isEditing ? 'Save Changes' : 'Add Health Record'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
