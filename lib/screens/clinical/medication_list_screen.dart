import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pet_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/interactive_motion/staggered_entrance.dart';
import '../../widgets/pet_background_wrapper.dart';
import 'add_edit_health_record_screen.dart';
import 'medication_details_screen.dart';

class MedicationListScreen extends StatefulWidget {
  final Pet pet;

  const MedicationListScreen({super.key, required this.pet});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _sampleMeds = [
    {
      'name': 'Himalaya Digyton Drops',
      'dosage': '10 drops (1.5 mL)',
      'frequency': 'Twice Daily (Post-Meal)',
      'startDate': DateTime.now().subtract(const Duration(days: 3)),
      'endDate': DateTime.now().add(const Duration(days: 4)),
      'status': 'Active',
      'instructions': 'Administer orally twice daily after food to aid healthy digestion.',
      'doctor': 'Dr. Ramesh Kumar, BVSc',
      'reminder': true,
    },
    {
      'name': 'PetUp Wild Salmon Omega-3 Oil',
      'dosage': '1 Pump (5 mL)',
      'frequency': 'Once Daily (Breakfast)',
      'startDate': DateTime.now().subtract(const Duration(days: 15)),
      'endDate': DateTime.now().add(const Duration(days: 45)),
      'status': 'Active',
      'instructions': 'Mix with morning kibbles for lustrous coat & joint lubrication.',
      'doctor': 'Dr. Ramesh Kumar, BVSc',
      'reminder': true,
    },
    {
      'name': 'Boltz Flea & Tick Preventive Pipette',
      'dosage': 'Single Spot-On Pipette',
      'frequency': 'Monthly',
      'startDate': DateTime.now().subtract(const Duration(days: 10)),
      'endDate': DateTime.now().add(const Duration(days: 20)),
      'status': 'Active',
      'instructions': 'Apply directly on the back of the neck between shoulder blades.',
      'doctor': 'Dr. Priya Sharma, MVSc',
      'reminder': true,
    },
    {
      'name': 'Amoxycillin Antibiotic Syrup',
      'dosage': '5 mL',
      'frequency': 'Twice Daily',
      'startDate': DateTime.now().subtract(const Duration(days: 45)),
      'endDate': DateTime.now().subtract(const Duration(days: 38)),
      'status': 'Completed',
      'instructions': 'Completed 7-day course for mild throat irritation. Fully recovered.',
      'doctor': 'Dr. Ramesh Kumar, BVSc',
      'reminder': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMeds = _sampleMeds.where((m) => m['status'] == 'Active').toList();
    final completedMeds = _sampleMeds.where((m) => m['status'] == 'Completed').toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${widget.pet.name}’s Medications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            tooltip: 'Add Medicine',
            onPressed: () => _navigateToAddMed(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.canopy,
          labelColor: AppColors.canopy,
          unselectedLabelColor: AppColors.softTaupe,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'All Prescriptions'),
            Tab(text: 'Active Courses'),
            Tab(text: 'Past History'),
          ],
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_avatar_luna.jpg',
        imageOpacity: 0.12,
        child: Column(
          children: [
            // Banner summary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white.withValues(alpha: 0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medication_rounded, color: AppColors.primaryTerracotta, size: 20),
                      const SizedBox(width: 8),
                      Text('${activeMeds.length} Active Prescriptions', style: AppTypography.labelLarge.copyWith(fontSize: 12.5)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.mossLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Schedule On Track ⏰', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.pistachioDark)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMedsList(_sampleMeds),
                  _buildMedsList(activeMeds),
                  _buildMedsList(completedMeds),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTerracotta,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Medication'),
        onPressed: () => _navigateToAddMed(context),
      ),
    );
  }

  Widget _buildMedsList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication_outlined, size: 48, color: AppColors.softTaupe),
            const SizedBox(height: 10),
            Text('No medications in this category', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final item = items[index];
        final isActive = item['status'] == 'Active';

        return StaggeredEntrance(
          index: index,
          child: JumpingCard(
            enableFloating: false,
            scaleOnTap: 0.96,
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicationDetailsScreen(
                    pet: widget.pet,
                    medicineName: item['name'] as String,
                    dosage: item['dosage'] as String,
                    frequency: item['frequency'] as String,
                    startDate: item['startDate'] as DateTime,
                    endDate: item['endDate'] as DateTime,
                    instructions: item['instructions'] as String,
                    prescribingDoctor: item['doctor'] as String,
                    status: item['status'] as String,
                    reminderActive: item['reminder'] as bool,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.pistachioSecondary.withValues(alpha: 0.2) : Colors.black12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status'] as String,
                          style: TextStyle(
                            color: isActive ? AppColors.pistachioDark : AppColors.softTaupe,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softTaupe),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(item['name'] as String, style: AppTypography.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Dose: ${item['dosage']} • ${item['frequency']}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    'Schedule: ${DateFormat('dd MMM').format(item['startDate'] as DateTime)} - ${DateFormat('dd MMM yyyy').format(item['endDate'] as DateTime)}',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.softTaupe),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToAddMed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditHealthRecordScreen(
          petId: widget.pet.id,
          initialType: 'medication',
        ),
      ),
    );
  }
}
