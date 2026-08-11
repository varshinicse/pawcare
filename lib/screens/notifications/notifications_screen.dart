import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final activePet = petProvider.activePet;
    final petName = activePet?.name ?? 'your pet';

    final allReminders = reminderProvider.reminders;
    final pendingReminders = allReminders.where((r) => !r.isCompleted).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    final completedReminders = allReminders.where((r) => r.isCompleted).toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Notifications Center 🔔'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary banner
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.clayLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: AppColors.clayPrimary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pendingReminders.length} Active Notifications',
                          style: AppTypography.displaySmall.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Real-time alerts for $petName',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 1: Active Scheduled Notifications
            Text('Active Scheduled Alerts', style: AppTypography.displaySmall),
            const SizedBox(height: 12),

            if (pendingReminders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Text(
                  'No pending alerts! All pet care tasks are complete. 🎉',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingReminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final reminder = pendingReminders[index];
                  return _buildNotificationCard(context, reminder, petName, reminderProvider, isPending: true);
                },
              ),

            const SizedBox(height: 28),

            // Section 2: Completed / Recent Notification History
            Text('Recent Notification History', style: AppTypography.displaySmall),
            const SizedBox(height: 12),

            if (completedReminders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Text(
                  'No past notification history yet.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedReminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final reminder = completedReminders[index];
                  return _buildNotificationCard(context, reminder, petName, reminderProvider, isPending: false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Reminder reminder,
    String petName,
    ReminderProvider reminderProvider, {
    required bool isPending,
  }) {
    final timeStr = DateHelpers.formatTime(reminder.scheduledTime);
    final dateStr = DateHelpers.formatDateShort(reminder.scheduledTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? AppColors.alertLight : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPending ? AppColors.alertCoral.withValues(alpha: 0.3) : AppColors.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPending ? AppColors.alertCoral : AppColors.mossAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPending ? Icons.alarm_on_rounded : Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reminder.title,
                          style: AppTypography.labelLarge.copyWith(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending ? AppColors.alertCoral.withValues(alpha: 0.15) : AppColors.mossLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPending ? 'SCHEDULED' : 'COMPLETED',
                            style: AppTypography.labelMedium.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isPending ? AppColors.alertCoral : AppColors.mossAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Care for $petName • $dateStr at $timeStr',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reminder.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reminder.notes,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    reminderProvider.toggleReminderComplete(reminder, petName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task "${reminder.title}" completed! 🎉'),
                        backgroundColor: AppColors.mossAccent,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Mark Done'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
