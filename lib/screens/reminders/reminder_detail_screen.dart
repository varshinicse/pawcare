import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/empty_state.dart';
import '../dashboard/widgets/reminder_pill_card.dart';
import 'add_reminder_screen.dart';

class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({super.key});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final activePet = petProvider.activePet;

    final allReminders = reminderProvider.reminders;
    final filteredReminders = allReminders.where((r) {
      if (_activeFilter == 'Today') return reminderProvider.todayReminders.contains(r);
      if (_activeFilter == 'Upcoming') return reminderProvider.upcomingReminders.contains(r);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Today', 'Upcoming', 'Completed'].map((filter) {
                final isSelected = _activeFilter == filter;
                return ChoiceChip(
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
