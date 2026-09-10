import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';
import 'animated_paw_card.dart';

/// Health snapshot 4-stat metric card with tactile feedback
class StatMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String note;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppColors.primaryTerracotta;

    return AnimatedPawCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: AppRadius.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: effectiveColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.softTaupe,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  note,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.pistachioDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

