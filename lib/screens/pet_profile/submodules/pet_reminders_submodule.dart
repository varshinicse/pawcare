import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/pet_model.dart';
import '../../../models/reminder_model.dart';
import '../../../providers/care_history_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';
import '../../reminders/add_reminder_screen.dart';
import '../../reminders/edit_reminder_screen.dart';
import '../../reminders/reminder_detail_screen.dart';

class PetRemindersSubmodule extends StatefulWidget {
  final Pet pet;

  const PetRemindersSubmodule({super.key, required this.pet});

  @override
  State<PetRemindersSubmodule> createState() => _PetRemindersSubmoduleState();
}

class _PetRemindersSubmoduleState extends State<PetRemindersSubmodule> {
  String _activeFilter = 'All'; // 'All', 'Today', 'Upcoming', 'Overdue', 'Completed'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderProvider>(context, listen: false)
          .fetchRemindersForPet(widget.pet.id);
    });
  }

  @override
  void didUpdateWidget(covariant PetRemindersSubmodule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.id != widget.pet.id) {
      Provider.of<ReminderProvider>(context, listen: false)
          .fetchRemindersForPet(widget.pet.id);
    }
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete "${reminder.title}"? Scheduled notifications will be canceled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () async {
              Navigator.of(dContext).pop();
              await Provider.of<ReminderProvider>(context, listen: false)
                  .deleteReminder(reminder.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder deleted and notification canceled.'),
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
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final careHistoryProvider = Provider.of<CareHistoryProvider>(context, listen: false);

    final petReminders = reminderProvider.reminders
        .where((r) => r.petId == widget.pet.id)
        .toList();

    // Apply Filter
    final List<Reminder> displayList;
    switch (_activeFilter) {
      case 'Today':
        displayList = petReminders.where((r) => DateHelpers.isToday(r.scheduledTime)).toList();
        break;
      case 'Upcoming':
        displayList = petReminders.where((r) => DateHelpers.isUpcomingWithin7Days(r.scheduledTime)).toList();
        break;
      case 'Overdue':
        displayList = petReminders.where((r) => DateHelpers.isOverdue(r.scheduledTime, r.isCompleted)).toList();
        break;
      case 'Completed':
        displayList = petReminders.where((r) => r.isCompleted).toList();
        break;
      case 'All':
      default:
        displayList = petReminders;
        break;
    }

    displayList.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    final totalActive = petReminders.where((r) => !r.isCompleted).length;
    final overdueCount = petReminders.where((r) => DateHelpers.isOverdue(r.scheduledTime, r.isCompleted)).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. STATUS BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: overdueCount > 0 ? AppColors.alertLight : AppColors.clayLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    overdueCount > 0 ? Icons.alarm_on_rounded : Icons.notifications_active_rounded,
                    color: overdueCount > 0 ? AppColors.alertCoral : AppColors.clayPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalActive Active Reminders for ${widget.pet.name}',
                        style: AppTypography.displaySmall.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        overdueCount > 0
                            ? '$overdueCount overdue! Check schedule below'
                            : 'All set. Notifications will alert you on time.',
                        style: AppTypography.bodySmall.copyWith(
                          color: overdueCount > 0 ? AppColors.alertCoral : AppColors.softTaupe,
                          fontWeight: overdueCount > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clayPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddReminderScreen(targetPetId: widget.pet.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. FILTER PILLS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Today', 'Upcoming', 'Overdue', 'Completed'].map((filter) {
                final isSel = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = filter);
                    },
                    selectedColor: AppColors.clayPrimary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSel ? AppColors.clayPrimary : AppColors.dividerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Reminders (${displayList.length})',
            style: AppTypography.displaySmall.copyWith(fontSize: 16),
          ),

          const SizedBox(height: 14),

          // 3. REMINDERS LIST OR EMPTY STATE
          if (reminderProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (displayList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  const Icon(Icons.alarm_rounded, size: 48, color: AppColors.softTaupe),
                  const SizedBox(height: 12),
                  Text(
                    'No reminders under "$_activeFilter".',
                    style: AppTypography.displaySmall.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap "+ New" above to schedule a feeding, medication, walk, water change, or custom task.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = displayList[index];
                return _buildReminderCard(context, reminder, reminderProvider, careHistoryProvider);
              },
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Reminder reminder,
    ReminderProvider reminderProvider,
    CareHistoryProvider careHistoryProvider,
  ) {
    final categoryColor = _getCategoryColor(reminder.type);
    final isOverdue = DateHelpers.isOverdue(reminder.scheduledTime, reminder.isCompleted);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReminderDetailScreen(singleReminder: reminder),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isOverdue ? AppColors.alertCoral.withValues(alpha: 0.5) : AppColors.dividerColor,
            width: isOverdue ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox button for complete
                GestureDetector(
                  onTap: () {
                    reminderProvider.toggleReminderComplete(
                      reminder,
                      widget.pet.name,
                      careHistoryProvider: careHistoryProvider,
                    );
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(top: 2, right: 12),
                    decoration: BoxDecoration(
                      color: reminder.isCompleted ? AppColors.mossAccent : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: reminder.isCompleted ? AppColors.mossAccent : AppColors.softTaupe,
                        width: 2,
                      ),
                    ),
                    child: reminder.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),

                // Title & Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                          color: reminder.isCompleted ? AppColors.softTaupe : AppColors.inkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (reminder.notes.isNotEmpty)
                        Text(
                          reminder.notes,
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                        ),
                    ],
                  ),
                ),

                // Options Menu
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.softTaupe),
                  onSelected: (val) {
                    if (val == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditReminderScreen(
                            reminder: reminder,
                          ),
                        ),
                      );
                    } else if (val == 'delete') {
                      _confirmDelete(context, reminder);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Reminder')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Reminder', style: TextStyle(color: AppColors.alertCoral)),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Badges Row
          Row(
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reminder.type.toUpperCase(),
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Repeat Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.creamSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.repeat_rounded, size: 12, color: AppColors.softTaupe),
                    const SizedBox(width: 4),
                    Text(
                      reminder.repeat.toUpperCase(),
                      style: const TextStyle(color: AppColors.softTaupe, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Notification bell status
              Icon(
                reminder.notificationEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                size: 16,
                color: reminder.notificationEnabled ? AppColors.mossAccent : AppColors.softTaupe,
              ),

              const Spacer(),

              // Date & Time text
              Text(
                '${DateHelpers.formatDateShort(reminder.scheduledTime)} • ${DateHelpers.formatTime(reminder.scheduledTime)}',
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                  color: isOverdue ? AppColors.alertCoral : AppColors.softTaupe,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Color _getCategoryColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('feed')) return const Color(0xFFE08E45);
    if (t.contains('walk')) return AppColors.mossAccent;
    if (t.contains('groom') || t.contains('bath')) return const Color(0xFF9E64D8);
    if (t.contains('med') || t.contains('vax')) return const Color(0xFF5D9CEC);
    if (t.contains('water') || t.contains('tank')) return const Color(0xFF29B6F6);
    return AppColors.clayPrimary;
  }
}
