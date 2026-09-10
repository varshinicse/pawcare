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
  final String initialType;

  const AddEditHealthRecordScreen({
    super.key,
    required this.petId,
    this.petName = 'Pet',
    HealthRecord? existingRecord,
    HealthRecord? recordToEdit,
    this.initialType = 'general',
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
  late TextEditingController _customMetricController;
  late String _selectedType;
  bool _hasAttachment = false;

  final List<Map<String, dynamic>> _recordCategories = [
    {'type': 'weight', 'label': 'Weight', 'icon': '⚖️'},
    {'type': 'temperature', 'label': 'Temperature', 'icon': '🌡️'},
    {'type': 'heart_rate', 'label': 'Heart Rate', 'icon': '❤️'},
    {'type': 'activity', 'label': 'Activity', 'icon': '🏃'},
    {'type': 'medication', 'label': 'Medication', 'icon': '💊'},
    {'type': 'vaccination', 'label': 'Vaccine', 'icon': '💉'},
    {'type': 'vet_visit', 'label': 'Vet Visit', 'icon': '🏥'},
    {'type': 'general', 'label': 'General Note', 'icon': '📝'},
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    _selectedType = r?.type ?? widget.initialType;

    _titleController = TextEditingController(
      text: r?.title ?? _getDefaultTitleForType(_selectedType),
    );
    _descController = TextEditingController(text: r?.description ?? '');
    _vetController = TextEditingController(text: r?.veterinarianName ?? 'Dr. Ramesh Kumar, BVSc');
    _weightController = TextEditingController(text: r != null && r.weightKg > 0 ? r.weightKg.toString() : '');
    _tempController = TextEditingController(text: r != null && r.temperatureCelsius > 0 ? r.temperatureCelsius.toString() : '38.4');
    _customMetricController = TextEditingController();
  }

  String _getDefaultTitleForType(String type) {
    switch (type.toLowerCase()) {
      case 'weight':
        return 'Weight Check-in';
      case 'temperature':
        return 'Body Temperature Log';
      case 'heart_rate':
        return 'Resting Heart Rate Check';
      case 'activity':
        return 'Exercise & Play Session';
      case 'medication':
        return 'New Medication Course';
      case 'vaccination':
        return 'Immunization Booster';
      case 'vet_visit':
        return 'Clinical Vet Consultation';
      default:
        return 'Routine Health Checkup';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _vetController.dispose();
    _weightController.dispose();
    _tempController.dispose();
    _customMetricController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedType = type;
      if (_titleController.text.isEmpty ||
          _recordCategories.any((c) => _titleController.text == _getDefaultTitleForType(c['type'] as String))) {
        _titleController.text = _getDefaultTitleForType(type);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final vet = _vetController.text.trim().isNotEmpty ? _vetController.text.trim() : 'Dr. Ramesh Kumar, BVSc';
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
        const SnackBar(
          content: Text('Clinical record updated successfully! 📋'),
          backgroundColor: AppColors.pistachioSecondary,
        ),
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
        const SnackBar(
          content: Text('Health log recorded to care timeline! 🐾'),
          backgroundColor: AppColors.pistachioSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Health Record' : 'Add Health Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Select Log Type Category Pills
              Text('Select Record Type', style: AppTypography.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _recordCategories.map((cat) {
                    final isSelected = _selectedType == cat['type'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _onTypeChanged(cat['type'] as String),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.canopy : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.canopy : AppColors.dividerColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(cat['icon'] as String, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.inkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    Text('Record Title *', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'e.g. Annual DHPP Booster',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Metrics depending on Type
                    if (_selectedType == 'weight') ...[
                      Text('Weight (kg) *', style: AppTypography.labelMedium),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'e.g. 28.5',
                          suffixText: 'kg',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_selectedType == 'temperature') ...[
                      Text('Body Temperature (°C) *', style: AppTypography.labelMedium),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _tempController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'e.g. 38.4',
                          suffixText: '°C',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_selectedType == 'heart_rate') ...[
                      Text('Resting Heart Rate (BPM) *', style: AppTypography.labelMedium),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _customMetricController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'e.g. 82',
                          suffixText: 'BPM',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Attending Vet / Doctor Field
                    Text('Veterinarian / Clinic Name', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _vetController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Dr. Ramesh Kumar / PawCare Hospital',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description / Clinical Observations
                    Text('Clinical Notes & Observations', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Enter doctor instructions, dosage, or recovery advice...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Attachment Simulator Box
                    InkWell(
                      onTap: () {
                        setState(() => _hasAttachment = !_hasAttachment);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_hasAttachment ? 'Prescription document attached 📄' : 'Attachment removed'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _hasAttachment ? AppColors.pistachioSecondary.withValues(alpha: 0.15) : AppColors.creamSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _hasAttachment ? AppColors.pistachioDark : AppColors.dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _hasAttachment ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                              color: _hasAttachment ? AppColors.pistachioDark : AppColors.canopy,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _hasAttachment ? 'Prescription_Scan_Verified.pdf' : 'Attach Prescription / Lab Report 📄',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _hasAttachment ? FontWeight.bold : FontWeight.w600,
                                  color: _hasAttachment ? AppColors.pistachioDark : AppColors.inkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canopy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: _save,
                  child: Text(
                    isEditing ? 'Update Health Record' : 'Save & Record to Health Trail',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
