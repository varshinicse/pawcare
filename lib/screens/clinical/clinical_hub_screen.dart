import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/health_record_model.dart';
import '../../models/pet_model.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_switcher_pill.dart';

class ClinicalHubScreen extends StatefulWidget {
  const ClinicalHubScreen({super.key});

  @override
  State<ClinicalHubScreen> createState() => _ClinicalHubScreenState();
}

class _ClinicalHubScreenState extends State<ClinicalHubScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _vetController = TextEditingController();
  final _weightController = TextEditingController();
  final _tempController = TextEditingController();

  String _selectedFilter = 'all';
  String _selectedFormType = 'prescription';
  String? _lastLoadedPetId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final petProvider = Provider.of<PetProvider>(context);
    final activePet = petProvider.activePet;
    if (activePet != null && activePet.id != _lastLoadedPetId) {
      _lastLoadedPetId = activePet.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<HealthRecordProvider>(context, listen: false)
              .fetchRecordsForPet(activePet.id);
        }
      });
    }
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

  void _saveRecord(String petId, {HealthRecord? existing}) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a record title.')),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text.trim()) ?? (existing?.weightKg ?? 0.0);
    final temp = double.tryParse(_tempController.text.trim()) ?? (existing?.temperatureCelsius ?? 38.4);
    final vetName = _vetController.text.trim().isNotEmpty ? _vetController.text.trim() : 'Dr. Ramesh Kumar';

    final hrProvider = Provider.of<HealthRecordProvider>(context, listen: false);

    if (existing != null) {
      final updated = existing.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: _selectedFormType,
        veterinarianName: vetName,
        weightKg: weight,
        temperatureCelsius: temp,
      );
      hrProvider.updateRecord(updated);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinical log updated successfully! 📋'),
          backgroundColor: AppColors.pistachioSecondary,
        ),
      );
    } else {
      final record = HealthRecord(
        id: 'hr_${DateTime.now().millisecondsSinceEpoch}',
        petId: petId,
        type: _selectedFormType,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: DateTime.now(),
        veterinarianName: vetName,
        weightKg: weight,
        temperatureCelsius: temp,
      );
      hrProvider.addRecord(record);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinical log added successfully! 🐾'),
          backgroundColor: AppColors.pistachioSecondary,
        ),
      );
    }

    _clearForm();
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _vetController.clear();
    _weightController.clear();
    _tempController.clear();
    _selectedFormType = 'prescription';
  }

  void _showRecordFormSheet(String petId, {HealthRecord? recordToEdit}) {
    if (recordToEdit != null) {
      _titleController.text = recordToEdit.title;
      _descController.text = recordToEdit.description;
      _vetController.text = recordToEdit.veterinarianName;
      _weightController.text = recordToEdit.weightKg > 0 ? recordToEdit.weightKg.toString() : '';
      _tempController.text = recordToEdit.temperatureCelsius > 0 ? recordToEdit.temperatureCelsius.toString() : '';
      _selectedFormType = recordToEdit.type;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    Text(
                      recordToEdit != null ? 'Edit Clinical Log 📋' : 'Add Clinical Log 📋',
                      style: AppTypography.displaySmall,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedFormType,
                      decoration: const InputDecoration(labelText: 'Log Type'),
                      items: const [
                        DropdownMenuItem(value: 'prescription', child: Text('Prescription Medicine')),
                        DropdownMenuItem(value: 'vaccination', child: Text('Vaccination Record')),
                        DropdownMenuItem(value: 'surgery', child: Text('Surgery Record')),
                        DropdownMenuItem(value: 'vet_note', child: Text('Veterinarian Notes')),
                        DropdownMenuItem(value: 'lab_report', child: Text('Lab / Check-up Report')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedFormType = val);
                          setState(() => _selectedFormType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title / Treatment Name *'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _vetController,
                      decoration: const InputDecoration(
                        labelText: 'Attending Veterinarian',
                        hintText: 'e.g. Dr. Ramesh Kumar',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              hintText: 'e.g. 28.5',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _tempController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Temp (°C)',
                              hintText: 'e.g. 38.4',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Instructions / Clinical Notes',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTerracotta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => _saveRecord(petId, existing: recordToEdit),
                        child: Text(recordToEdit != null ? 'Update Health Record' : 'Save Health Record 🐾'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final hrProvider = Provider.of<HealthRecordProvider>(context);
    final activePet = petProvider.activePet ??
        (petProvider.pets.isNotEmpty
            ? petProvider.pets.first
            : Pet(
                id: 'default',
                ownerId: 'user',
                name: 'Bruno',
                species: 'dog',
                breed: 'Golden Retriever',
                age: 2.5,
                weightKg: 28.5,
                foodHabits: 'Royal Canin',
                medicalHistory: ['Vaccinated'],
                avatarAsset: 'dog_hero',
                createdAt: DateTime.now(),
              ));


    final allRecords = hrProvider.records;
    final filteredRecords = _selectedFilter == 'all'
        ? allRecords
        : allRecords.where((r) => r.type.toLowerCase().contains(_selectedFilter.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            _buildHeader(context, activePet),

            // Scrollable Clinical Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CLINICAL CANOPY',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryTerracotta,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${activePet.name}'s health",
                              style: AppTypography.displayMedium.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showRecordFormSheet(activePet.id),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                          label: const Text('Add log'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTerracotta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            textStyle: AppTypography.labelLarge.copyWith(fontSize: 12.5),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A complete, calm view of care records and vital trends synced with mobile.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // 1. Clinical Canopy Overview Card
                    _buildClinicalHeroCard(activePet),
                    const SizedBox(height: 16),

                    // 2. Resting Heart Rate & Activity Progress Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.canopy.withValues(alpha: 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.favorite_rounded, color: AppColors.alertCoral, size: 22),
                                const SizedBox(height: 12),
                                Text('Resting heart rate', style: AppTypography.bodySmall),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    text: '84 ',
                                    style: AppTypography.displaySmall.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.inkText,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'bpm',
                                        style: AppTypography.bodySmall.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.canopy.withValues(alpha: 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.trending_up_rounded, color: AppColors.pistachioDark, size: 22),
                                const SizedBox(height: 12),
                                Text('Weekly activity', style: AppTypography.bodySmall),
                                const SizedBox(height: 2),
                                Text(
                                  '74%',
                                  style: AppTypography.displaySmall.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.inkText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: const LinearProgressIndicator(
                                    value: 0.74,
                                    minHeight: 6,
                                    backgroundColor: AppColors.creamSurface,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.pistachioSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Clinical Records Feed Section
                    _buildRecordsFeed(context, hrProvider, activePet, filteredRecords),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Pet activePet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamBase,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.pistachioSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medical_services_rounded, color: AppColors.pistachioDark, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Clinical Vault',
                style: AppTypography.displaySmall.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const PetSwitcherPill(),
        ],
      ),
    );
  }

  Widget _buildClinicalHeroCard(Pet activePet) {
    final isBruno = activePet.name.toLowerCase() == 'bruno';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.canopy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: isBruno
                    ? Image.asset(
                        'assets/images/bruno-jungle.jpg',
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPetAvatarFallback(activePet),
                      )
                    : _buildPetAvatarFallback(activePet),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${activePet.breed} • ${activePet.age} yrs',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.pistachioSecondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Healthy',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.pistachioDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activePet.name,
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVitalMetric('WEIGHT', '${activePet.weightKg} kg'),
                Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.2)),
                _buildVitalMetric('TEMP', '38.4°C'),
                Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.2)),
                _buildVitalMetric('STATUS', 'Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatarFallback(Pet pet) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.pistachioSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        pet.name.isNotEmpty ? pet.name[0].toUpperCase() : 'P',
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.pistachioDark),
      ),
    );
  }

  Widget _buildVitalMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsFeed(
    BuildContext context,
    HealthRecordProvider hrProvider,
    Pet activePet,
    List<HealthRecord> records,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARE HISTORY',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryTerracotta,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recent clinical records',
                    style: AppTypography.displaySmall.copyWith(fontSize: 18),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.softTaupe),
                onSelected: (val) => setState(() => _selectedFilter = val),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'all', child: Text('All Records')),
                  PopupMenuItem(value: 'vaccin', child: Text('Vaccines Only')),
                  PopupMenuItem(value: 'prescript', child: Text('Prescriptions Only')),
                  PopupMenuItem(value: 'vet_note', child: Text('Vet Notes Only')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.assignment_outlined, size: 36, color: AppColors.softTaupe),
                    const SizedBox(height: 8),
                    Text('No clinical records logged for ${activePet.name}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.dividerColor),
              itemBuilder: (ctx, index) {
                final record = records[index];
                final isVaccine = record.type.toLowerCase().contains('vaccin');
                final dateStr = DateFormat('dd MMM').format(record.date);

                return InkWell(
                  onTap: () => _showRecordFormSheet(activePet.id, recordToEdit: record),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isVaccine ? AppColors.mossLight : AppColors.creamSurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isVaccine ? Icons.vaccines_rounded : Icons.shield_outlined,
                            size: 22,
                            color: isVaccine ? AppColors.pistachioDark : AppColors.primaryTerracotta,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.title,
                                style: AppTypography.labelLarge.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${record.type.toUpperCase()} • ${record.veterinarianName}',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          dateStr,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.softTaupe,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
