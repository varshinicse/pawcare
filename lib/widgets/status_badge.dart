import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';

enum BadgeType { success, warning, alert, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successLight;
        fg = AppColors.successGreen;
        break;
      case BadgeType.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warningAmber;
        break;
      case BadgeType.alert:
        bg = AppColors.alertLight;
        fg = AppColors.alertCoral;
        break;
      case BadgeType.info:
        bg = AppColors.infoLight;
        fg = AppColors.infoBlue;
        break;
      case BadgeType.neutral:
        bg = AppColors.creamSurface;
        fg = AppColors.inkText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize * 1.1, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
