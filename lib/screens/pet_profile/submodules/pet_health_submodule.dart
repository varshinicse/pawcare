import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/health_record_model.dart';
import '../../../models/pet_model.dart';
import '../../../providers/health_record_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';
import '../../clinical/health_record_details_screen.dart';
import '../../clinical/add_edit_health_record_screen.dart';
import '../widgets/add_edit_health_record_dialog.dart';

class PetHealthSubmodule extends StatefulWidget {
  final Pet pet;

  const PetHealthSubmodule({super.key, required this.pet});

  @override
  State<PetHealthSubmodule> createState() => _PetHealthSubmoduleState();
}

class _PetHealthSubmoduleState extends State<PetHealthSubmodule> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthRecordProvider>(context, listen: false)
          .fetchRecordsForPet(widget.pet.id);
    });
  }

  @override
  void didUpdateWidget(covariant PetHealthSubmodule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.id != widget.pet.id) {
      Provider.of<HealthRecordProvider>(context, listen: false)
          .fetchRecordsForPet(widget.pet.id);
    }
  }

  void _confirmDelete(BuildContext context, HealthRecord record) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Health Record?'),
        content: Text('Are you sure you want to delete "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () async {
              Navigator.of(dContext).pop();
              await Provider.of<HealthRecordProvider>(context, listen: false)
                  .deleteRecord(record.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Health record removed.'),
                    backgroundColor: AppColors.alertCoral,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthRecordProvider>(context);
    final petRecords = healthProvider.getRecordsForPet(widget.pet.id);

    // Apply category filter
    final filteredRecords = _selectedCategory == 'All'
        ? petRecords
        : petRecords
            .where((r) => r.type.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                _selectedCategory.toLowerCase().contains(r.type.toLowerCase()))
            .toList();

    // Summary calculations
    final vaxCount = petRecords
        .where((r) => r.type.toLowerCase().contains('vaccin'))
        .length;
    final latestVisit = petRecords.isNotEmpty ? petRecords.first.date : null;
    final latestWeight = petRecords.firstWhere(
      (r) => r.weightKg > 0,
      orElse: () => HealthRecord(
        id: '',
        petId: widget.pet.id,
        type: '',
        title: '',
        description: '',
        date: DateTime.now(),
        weightKg: widget.pet.weightKg,
      ),
    ).weightKg;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEALTH SUMMARY CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.clayPrimary.withValues(alpha: 0.95),
                  AppColors.clayPrimary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.clayPrimary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HEALTH SUMMARY 🩺',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Active Pet: ${widget.pet.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryStat('Records', '${petRecords.length}'),
                    _buildSummaryDivider(),
                    _buildSummaryStat('Vaccines', '$vaxCount'),
                    _buildSummaryDivider(),
                    _buildSummaryStat('Weight', '${latestWeight.toStringAsFixed(1)} kg'),
                    _buildSummaryDivider(),
                    _buildSummaryStat(
                      'Last Visit',
                      latestVisit != null ? DateHelpers.formatDateShort(latestVisit) : 'None',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. CATEGORY FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
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
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 3. HEADER WITH "+ ADD RECORD" BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical & Medical Records (${filteredRecords.length})',
                style: AppTypography.displaySmall.copyWith(fontSize: 16),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clayPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditHealthRecordScreen(
                        petId: widget.pet.id,
                        petName: widget.pet.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Record', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4. RECORDS LIST / EMPTY STATE
          if (healthProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredRecords.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  const Icon(Icons.medical_information_outlined, size: 48, color: AppColors.softTaupe),
                  const SizedBox(height: 12),
                  Text(
                    'No health records available for ${widget.pet.name}.',
                    style: AppTypography.displaySmall.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap "Add Record" to log vaccinations, vet visits, medications, or health checkups.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredRecords.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return _buildRecordCard(context, record);
              },
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, HealthRecord record) {
    final typeColor = _getTypeColor(record.type);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HealthRecordDetailsScreen(
              record: record,
              petName: widget.pet.name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(record.type), size: 14, color: typeColor),
                      const SizedBox(width: 4),
                      Text(
                        record.type.toUpperCase(),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateHelpers.formatDateShort(record.date),
                  style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe, fontSize: 11),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.softTaupe),
                  onSelected: (val) {
                    if (val == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditHealthRecordScreen(
                            petId: widget.pet.id,
                            petName: widget.pet.name,
                            recordToEdit: record,
                          ),
                        ),
                      );
                    } else if (val == 'delete') {
                      _confirmDelete(context, record);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Record')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Record', style: TextStyle(color: AppColors.alertCoral)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(record.title, style: AppTypography.labelLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
            if (record.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(record.description, style: AppTypography.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (record.veterinarianName.isNotEmpty)
                  _buildBadge(Icons.person_outline_rounded, record.veterinarianName),
                if (record.weightKg > 0)
                  _buildBadge(Icons.monitor_weight_outlined, '${record.weightKg} kg'),
              ],
            ),
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.creamSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Note: ${record.notes}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.softTaupe),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
      ],
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('vax') || t.contains('vaccin')) return AppColors.mossAccent;
    if (t.contains('med')) return const Color(0xFF5D9CEC);
    if (t.contains('vet') || t.contains('visit')) return AppColors.clayPrimary;
    if (t.contains('weight')) return const Color(0xFFE08E45);
    return AppColors.softTaupe;
  }

  IconData _getTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('vax') || t.contains('vaccin')) return Icons.vaccines_rounded;
    if (t.contains('med')) return Icons.medication_rounded;
    if (t.contains('vet') || t.contains('visit')) return Icons.medical_services_rounded;
    if (t.contains('weight')) return Icons.monitor_weight_rounded;
    return Icons.health_and_safety_rounded;
  }
}
