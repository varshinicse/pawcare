import 'package:flutter/material.dart';

import '../../../models/reminder_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import 'reminder_pill_card.dart';

class TodayTimeline extends StatelessWidget {
  final List<Reminder> reminders;
  final Function(Reminder) onToggleComplete;
  final VoidCallback onAddReminder;

  const TodayTimeline({
    super.key,
    required this.reminders,
    required this.onToggleComplete,
    required this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Today\'s Schedule', style: AppTypography.displaySmall),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.clayLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${reminders.where((r) => r.isCompleted).length}/${reminders.length}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.clayPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: onAddReminder,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.clayLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, size: 20, color: AppColors.clayPrimary),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (reminders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No reminders pending for today! Enjoy relaxed playtime.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return ReminderPillCard(
                  reminder: reminders[index],
                  onToggleComplete: onToggleComplete,
                );
              },
            ),
          ),
      ],
    );
  }
}
