import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pet_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/interactive_motion/staggered_entrance.dart';
import '../../widgets/pet_background_wrapper.dart';
import 'add_edit_health_record_screen.dart';
import 'vaccination_details_screen.dart';

class VaccinationListScreen extends StatefulWidget {
  final Pet pet;

  const VaccinationListScreen({super.key, required this.pet});

  @override
  State<VaccinationListScreen> createState() => _VaccinationListScreenState();
}

class _VaccinationListScreenState extends State<VaccinationListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _sampleVaccines = [
    {
      'name': 'Rabies Immunization (Annual)',
      'status': 'Completed',
      'dateAdministered': DateTime.now().subtract(const Duration(days: 45)),
      'nextDueDate': DateTime.now().add(const Duration(days: 320)),
      'vet': 'Dr. Ramesh Kumar, BVSc',
      'clinic': 'PawCare Indiranagar Clinic',
      'batch': 'RAB-2024-88A',
      'notes': 'Subcutaneous annual rabies booster administered. Patient is safe and active.',
    },
    {
      'name': 'DHPP (Distemper, Hepatitis, Parvo, Parainfluenza)',
      'status': 'Completed',
      'dateAdministered': DateTime.now().subtract(const Duration(days: 90)),
      'nextDueDate': DateTime.now().add(const Duration(days: 275)),
      'vet': 'Dr. Priya Sharma, MVSc',
      'clinic': 'PawCare Central Hospital',
      'batch': 'DHPP-990-2B',
      'notes': 'Core 7-in-1 vaccine completed. Full protective immunity active.',
    },
    {
      'name': 'Bordetella (Kennel Cough)',
      'status': 'Upcoming',
      'dateAdministered': DateTime.now().subtract(const Duration(days: 340)),
      'nextDueDate': DateTime.now().add(const Duration(days: 25)),
      'vet': 'Dr. Ramesh Kumar, BVSc',
      'clinic': 'PawCare Indiranagar Clinic',
      'batch': 'BORD-441-A',
      'notes': 'Intranasal kennel cough protection booster recommended before boarding or socializing.',
    },
    {
      'name': 'Canine Coronavirus & Leptospirosis Booster',
      'status': 'Completed',
      'dateAdministered': DateTime.now().subtract(const Duration(days: 120)),
      'nextDueDate': DateTime.now().add(const Duration(days: 245)),
      'vet': 'Dr. Ramesh Kumar, BVSc',
      'clinic': 'PawCare Indiranagar Clinic',
      'batch': 'LEPTO-331-C',
      'notes': 'Seasonal booster for monsoon moisture protection.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _sampleVaccines.where((v) => v['status'] == 'Completed').length;
    final upcomingCount = _sampleVaccines.where((v) => v['status'] == 'Upcoming').length;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${widget.pet.name}’s Vaccinations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTerracotta),
            tooltip: 'Add Vaccine',
            onPressed: () => _navigateToAddVaccine(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.canopy,
          labelColor: AppColors.canopy,
          unselectedLabelColor: AppColors.softTaupe,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
          ],
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_dog_friends.jpg',
        imageOpacity: 0.12,
        child: Column(
          children: [
            // Summary Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white.withValues(alpha: 0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.pistachioDark, size: 20),
                      const SizedBox(width: 8),
                      Text('$completedCount Protected Core Vaccines', style: AppTypography.labelLarge.copyWith(fontSize: 12.5)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.buttercreamAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$upcomingCount Booster Due', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.canopy)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVaccineList(_sampleVaccines),
                  _buildVaccineList(_sampleVaccines.where((v) => v['status'] == 'Completed').toList()),
                  _buildVaccineList(_sampleVaccines.where((v) => v['status'] == 'Upcoming').toList()),
                  _buildVaccineList(_sampleVaccines.where((v) => v['status'] == 'Overdue').toList()),
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
        label: const Text('Add Vaccine Record'),
        onPressed: () => _navigateToAddVaccine(context),
      ),
    );
  }

  Widget _buildVaccineList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 48, color: AppColors.softTaupe),
            const SizedBox(height: 10),
            Text('No vaccine records in this category', style: AppTypography.bodyMedium),
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
        final isCompleted = item['status'] == 'Completed';

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
                  builder: (_) => VaccinationDetailsScreen(
                    pet: widget.pet,
                    vaccineName: item['name'] as String,
                    dateAdministered: item['dateAdministered'] as DateTime,
                    nextDueDate: item['nextDueDate'] as DateTime,
                    status: item['status'] as String,
                    veterinarian: item['vet'] as String,
                    clinic: item['clinic'] as String,
                    batchNumber: item['batch'] as String,
                    notes: item['notes'] as String,
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
                          color: isCompleted ? AppColors.mossLight : AppColors.buttercreamAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status'] as String,
                          style: TextStyle(
                            color: isCompleted ? AppColors.pistachioDark : AppColors.canopy,
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
                  Text('Administered: ${DateFormat('dd MMM yyyy').format(item['dateAdministered'] as DateTime)}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('Next Due: ${DateFormat('dd MMM yyyy').format(item['nextDueDate'] as DateTime)}', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToAddVaccine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditHealthRecordScreen(
          petId: widget.pet.id,
          initialType: 'vaccination',
        ),
      ),
    );
  }
}
