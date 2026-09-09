import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/reminder_model.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';
import '../../reminders/add_reminder_screen.dart';

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
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _showUpcomingActionSheet(context, reminder),
                child: Container(
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
                ),
              );
            },
          ),
      ],
    );
  }

  void _showUpcomingActionSheet(BuildContext context, Reminder reminder) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final petName = petProvider.activePet?.name ?? 'Pet';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.clayLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(reminder.type),
                        color: AppColors.clayPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reminder.title, style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                          Text(
                            '${reminder.type.toUpperCase()} • ${DateHelpers.formatDateFull(reminder.scheduledTime)}',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (reminder.notes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Notes:', style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Text(reminder.notes, style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe)),
                ],
                const SizedBox(height: 20),
                const Divider(color: AppColors.dividerColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddReminderScreen(reminderToEdit: reminder),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: reminder.isCompleted ? AppColors.softTaupe : AppColors.mossAccent,
                        ),
                        onPressed: () {
                          final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                          reminderProvider.toggleReminderComplete(reminder, petName);
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(reminder.isCompleted
                                  ? 'Reminder marked as incomplete.'
                                  : 'Reminder marked as completed! 🎉'),
                              backgroundColor: reminder.isCompleted ? AppColors.inkText : AppColors.mossAccent,
                            ),
                          );
                        },
                        icon: Icon(
                          reminder.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        label: Text(reminder.isCompleted ? 'Mark Undone' : 'Mark Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
