import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';
import '../../widgets/empty_state.dart';
import '../dashboard/widgets/reminder_pill_card.dart';
import 'add_reminder_screen.dart';

class ReminderDetailScreen extends StatefulWidget {
  final Reminder? singleReminder;

  const ReminderDetailScreen({super.key, this.singleReminder});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}


class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  String _activeFilter = 'All';

  void _showReminderOptions(BuildContext context, Reminder reminder, String petName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final isOverdue = DateHelpers.isOverdue(reminder.scheduledTime, reminder.isCompleted);
        final dateStr = DateHelpers.formatDateShort(reminder.scheduledTime);
        final timeStr = DateHelpers.formatTime(reminder.scheduledTime);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOverdue ? AppColors.alertLight : AppColors.clayLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      reminder.type.toUpperCase(),
                      style: AppTypography.labelMedium.copyWith(
                        color: isOverdue ? AppColors.alertCoral : AppColors.clayPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    'Repeat: ${reminder.repeat.toUpperCase()}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                reminder.title,
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 18, color: AppColors.softTaupe),
                  const SizedBox(width: 8),
                  Text(
                    '$dateStr at $timeStr',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.alertCoral,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (reminder.notes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('Notes:', style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(reminder.notes, style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe)),
              ],
              const SizedBox(height: 24),
              const Divider(color: AppColors.dividerColor),
              const SizedBox(height: 12),

              // Action Buttons
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
                                : 'Awesome! Reminder marked as completed! 🎉'),
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.alertCoral),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelete(context, reminder);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete Reminder'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () async {
              Navigator.of(dContext).pop();
              await Provider.of<ReminderProvider>(context, listen: false).deleteReminder(reminder.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder "${reminder.title}" deleted.'),
                    backgroundColor: AppColors.alertCoral,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final activePet = petProvider.activePet;

    final allReminders = reminderProvider.reminders;
    final filteredReminders = allReminders.where((r) {
      if (_activeFilter == 'Today') return reminderProvider.todayReminders.contains(r);
      if (_activeFilter == 'Upcoming') return reminderProvider.upcomingReminders.contains(r);
      if (_activeFilter == 'Overdue') return DateHelpers.isOverdue(r.scheduledTime, r.isCompleted);
      if (_activeFilter == 'Completed') return r.isCompleted;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${activePet?.name ?? 'Pet'}\'s Schedule ⏰'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.clayPrimary, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddReminderScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['All', 'Today', 'Upcoming', 'Overdue', 'Completed'].map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.clayPrimary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: filteredReminders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: EmptyStateWidget(
                        title: 'No Reminders Found',
                        description: 'There are no $_activeFilter reminders scheduled right now.',
                        buttonText: 'Add New Reminder',
                        onButtonPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AddReminderScreen()),
                          );
                        },
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: filteredReminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final reminder = filteredReminders[index];
                      return Center(
                        child: ReminderPillCard(
                          reminder: reminder,
                          onTapCard: (r) => _showReminderOptions(context, r, activePet?.name ?? 'Bruno'),
                          onToggleComplete: (r) {
                            reminderProvider.toggleReminderComplete(r, activePet?.name ?? 'Bruno');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
