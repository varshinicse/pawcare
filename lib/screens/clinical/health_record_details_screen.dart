import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/health_record_model.dart';
import '../../providers/health_record_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'add_edit_health_record_screen.dart';

class HealthRecordDetailsScreen extends StatelessWidget {
  final HealthRecord record;
  final String petName;

  const HealthRecordDetailsScreen({
    super.key,
    required this.record,
    required this.petName,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete "${record.title}"?'),
        content: const Text('Are you sure you want to delete this clinical record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () {
              Provider.of<HealthRecordProvider>(context, listen: false).deleteRecord(record.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clinical log deleted.'), backgroundColor: AppColors.alertCoral),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVaccine = record.type.toLowerCase().contains('vaccin');
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(record.date);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Clinical Record 📋'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Record',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditHealthRecordScreen(petId: record.petId, existingRecord: record),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertCoral),
            tooltip: 'Delete Record',
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.canopy.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVaccine ? AppColors.pistachioSecondary : AppColors.primaryTerracotta,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.type.toUpperCase(),
                        style: TextStyle(
                          color: isVaccine ? AppColors.pistachioDark : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      record.title,
                      style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Logged for $petName • $formattedDate',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Clinical Vitals Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CLINICAL DETAILS', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryTerracotta, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    _buildDetailItem(Icons.person_pin_circle_outlined, 'Attending Veterinarian', record.veterinarianName),
                    const Divider(height: 20, color: AppColors.dividerColor),
                    _buildDetailItem(Icons.scale_rounded, 'Weight at Visit', record.weightKg > 0 ? '${record.weightKg} kg' : 'Not recorded'),
                    const Divider(height: 20, color: AppColors.dividerColor),
                    _buildDetailItem(Icons.thermostat_rounded, 'Body Temperature', record.temperatureCelsius > 0 ? '${record.temperatureCelsius}°C' : 'Not recorded'),
                    if (record.description.isNotEmpty) ...[
                      const Divider(height: 20, color: AppColors.dividerColor),
                      _buildDetailItem(Icons.notes_rounded, 'Prescriptions & Notes', record.description),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.softTaupe),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.labelLarge.copyWith(fontSize: 13.5)),
            ],
          ),
        ),
      ],
    );
  }
}
