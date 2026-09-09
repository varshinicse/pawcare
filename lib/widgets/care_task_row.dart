import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Care Task Row in Today's Care Trail
class CareTaskRow extends StatelessWidget {
  final Reminder task;
  final VoidCallback onToggle;

  const CareTaskRow({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    final timeStr = DateFormat('h:mm a').format(task.scheduledTime);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? AppColors.mossLight.withValues(alpha: 0.5) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? AppColors.pistachioSecondary.withValues(alpha: 0.5) : AppColors.dividerColor,
          ),
        ),
        child: Row(
          children: [
            // Custom Status Checkbox
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDone ? AppColors.pistachioSecondary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.pistachioSecondary : AppColors.primaryTerracotta.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.schedule_rounded,
                size: 18,
                color: isDone ? AppColors.pistachioDark : AppColors.primaryTerracotta,
              ),
            ),
            const SizedBox(width: 12),

            // Title & Notes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.softTaupe : AppColors.inkText,
                    ),
                  ),
                  if (task.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.softTaupe,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Time & Type Tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: AppTypography.numericData.copyWith(
                    fontSize: 12.5,
                    color: AppColors.inkText,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.creamSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.type.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 9,
                      color: AppColors.softTaupe,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
