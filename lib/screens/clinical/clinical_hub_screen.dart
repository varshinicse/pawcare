import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/health_record_model.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ClinicalHubScreen extends StatefulWidget {
  const ClinicalHubScreen({super.key});

  @override
  State<ClinicalHubScreen> createState() => _ClinicalHubScreenState();
}

class _ClinicalHubScreenState extends State<ClinicalHubScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedType = 'prescription';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      if (petProvider.activePet != null) {
        Provider.of<HealthRecordProvider>(context, listen: false)
            .fetchRecordsForPet(petProvider.activePet!.id);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addLog(String petId) {
    if (_titleController.text.trim().isEmpty) return;

    final record = HealthRecord(
      id: 'hr_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: DateTime.now(),
    );

    Provider.of<HealthRecordProvider>(context, listen: false).addRecord(record);
    _titleController.clear();
    _descController.clear();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Clinical log added successfully! 🐾'),
        backgroundColor: AppColors.mossAccent,
      ),
    );
  }

  void _showAddLogSheet(String petId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Clinical Log 📋', style: AppTypography.displaySmall),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Log Type'),
                items: const [
                  DropdownMenuItem(value: 'prescription', child: Text('Prescription Medicine')),
                  DropdownMenuItem(value: 'vaccination', child: Text('Vaccination Record')),
                  DropdownMenuItem(value: 'surgery', child: Text('Surgery Record')),
                  DropdownMenuItem(value: 'vet_note', child: Text('Veterinarian Notes')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title / Treatment'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Instructions / Notes'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _addLog(petId),
                  child: const Text('Add to Health Record'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final hrProvider = Provider.of<HealthRecordProvider>(context);
    final activePet = petProvider.activePet;

    if (activePet == null) {
      return Scaffold(
        backgroundColor: AppColors.creamBase,
        appBar: AppBar(title: const Text('Digital Health Records')),
        body: const Center(child: Text('Please add a pet to view health logs.')),
      );
    }

    final records = hrProvider.getRecordsForPet(activePet.id);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${activePet.name}\'s Health Card 📋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.clayPrimary, size: 28),
            onPressed: () => _showAddLogSheet(activePet.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF & QR Pet ID card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.clayLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 36, color: AppColors.clayPrimary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR Pet ID Tag Generated',
                              style: AppTypography.labelLarge.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Microchip: ${activePet.microchipNumber}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final file = await hrProvider.generatePdfHealthCard(activePet.name);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Downloaded: $file 📄'),
                                  backgroundColor: AppColors.mossAccent,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Export PDF Card'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showQrDialog(activePet.name, activePet.microchipNumber);
                          },
                          icon: const Icon(Icons.qr_code_rounded, size: 18),
                          label: const Text('View QR Tag'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Clinical Chronology', style: AppTypography.displaySmall),
            const SizedBox(height: 12),

            records.isEmpty
                ? const Text('No medical logs recorded yet.')
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final log = records[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.creamSurface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                log.type == 'vaccination' ? Icons.vaccines_rounded : Icons.description_rounded,
                                color: AppColors.clayPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.title,
                                    style: AppTypography.labelLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log.description,
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showQrDialog(String petName, String microchip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('$petName\'s QR Pet ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.clayPrimary, width: 4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.inkText),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scanning displays owner info, emergency contacts & vaccines.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Tag: $microchip',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
