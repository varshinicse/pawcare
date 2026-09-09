import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/care_history_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CareActivityDetailsScreen extends StatelessWidget {
  final CareHistory item;
  final String petName;

  const CareActivityDetailsScreen({
    super.key,
    required this.item,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('EEEE, dd MMMM yyyy • h:mm a').format(item.completedAt);

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Care Activity Log 📜'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
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
                        color: AppColors.pistachioSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.pistachioDark),
                          const SizedBox(width: 4),
                          Text(
                            'COMPLETED TASK',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.pistachioDark, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.title,
                      style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed for $petName',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Activity Details
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
                    Text('AUDIT DETAILS', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryTerracotta, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    _buildRow(Icons.category_outlined, 'Care Routine Type', item.activityType.toUpperCase()),
                    const Divider(height: 20, color: AppColors.dividerColor),
                    _buildRow(Icons.schedule_rounded, 'Completed Timestamp', formattedTime),
                    if (item.description.isNotEmpty) ...[
                      const Divider(height: 20, color: AppColors.dividerColor),
                      _buildRow(Icons.notes_rounded, 'Session Notes', item.description),
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

  Widget _buildRow(IconData icon, String label, String value) {
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
