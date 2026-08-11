import 'package:flutter/material.dart';

import '../../../models/reminder_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';

class UpcomingEventsList extends StatelessWidget {
  final List<Reminder> upcomingReminders;

  const UpcomingEventsList({
    super.key,
    required this.upcomingReminders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming 7 Days', style: AppTypography.displaySmall),
        const SizedBox(width: 8),
        Text(
          'Vaccinations, checkups & grooming schedule',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: 12),

        if (upcomingReminders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Text(
              'No upcoming appointments scheduled for next week.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingReminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final reminder = upcomingReminders[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.creamSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(reminder.type),
                        color: AppColors.clayPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: AppTypography.labelLarge.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reminder.notes.isNotEmpty
                                ? reminder.notes
                                : 'Scheduled task for ${reminder.type}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.clayLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        DateHelpers.formatDateShort(reminder.scheduledTime),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.clayPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines_rounded;
      case 'checkup':
        return Icons.health_and_safety_rounded;
      case 'grooming':
        return Icons.content_cut_rounded;
      case 'medication':
        return Icons.medication_rounded;
      default:
        return Icons.calendar_month_rounded;
    }
  }
}
