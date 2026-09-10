import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String? category;
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    this.category,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category != null) ...[
                Text(
                  category!.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryTerracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                title,
                style: AppTypography.displaySmall.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
        if (actionText != null && onActionTap != null)
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                actionText!,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryTerracotta,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
