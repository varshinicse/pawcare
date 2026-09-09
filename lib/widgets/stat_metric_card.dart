import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Health snapshot 4-stat metric card
class StatMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String note;
  final Color? iconColor;

  const StatMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 22, color: iconColor ?? AppColors.primaryTerracotta),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.softTaupe,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.pistachioDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
