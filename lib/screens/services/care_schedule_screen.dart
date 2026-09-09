import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/reminder_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';
import '../reminders/reminder_detail_screen.dart';
import 'appointment_details_screen.dart';

class CareScheduleScreen extends StatefulWidget {
  const CareScheduleScreen({super.key});

  @override
  State<CareScheduleScreen> createState() => _CareScheduleScreenState();
}

class _CareScheduleScreenState extends State<CareScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    // Filter reminders for the selected day
    final dayReminders = reminderProvider.reminders.where((r) {
      return DateUtils.isSameDay(r.scheduledTime, _selectedDate);
    }).toList();

    // Filter appointments for the selected day
    final dayAppointments = appointmentProvider.appointments.where((a) {
      return DateUtils.isSameDay(a.dateTime, _selectedDate);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Care Schedule Calendar 📅'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 7-DAY HORIZONTAL SELECTOR
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: Colors.white,
            child: SizedBox(
              height: 76,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(const Duration(days: 2)).add(Duration(days: index));
                  final isSelected = DateUtils.isSameDay(_selectedDate, date);
                  final isToday = DateUtils.isSameDay(DateTime.now(), date);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.canopy
                            : isToday
                                ? AppColors.clayLight
                                : AppColors.creamSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.canopy
                              : isToday
                                  ? AppColors.primaryTerracotta
                                  : AppColors.dividerColor,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateHelpers.formatDayOfWeek(date).substring(0, 3).toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.pistachioSecondary
                                  : isToday
                                      ? AppColors.primaryTerracotta
                                      : AppColors.softTaupe,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.inkText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),

          // TIMELINE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateHelpers.formatDate(_selectedDate),
                    style: AppTypography.displaySmall.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  // APPOINTMENTS SECTION
                  if (dayAppointments.isNotEmpty) ...[
                    Text('APPOINTMENTS (${dayAppointments.length})', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                    const SizedBox(height: 10),
                    ...dayAppointments.map((apt) => _buildAppointmentCard(context, apt)),
                    const SizedBox(height: 20),
                  ],

                  // REMINDERS SECTION
                  Text('DAILY CARE & REMINDERS (${dayReminders.length})', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                  const SizedBox(height: 10),
                  if (dayReminders.isEmpty && dayAppointments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.dividerColor),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.event_available_rounded, size: 48, color: AppColors.softTaupe),
                          const SizedBox(height: 12),
                          Text('No schedule items for this day.', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Relax! All care tasks and appointments are clear.', style: AppTypography.bodySmall),
                        ],
                      ),
                    )
                  else
                    ...dayReminders.map((rem) => _buildReminderRow(context, rem)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, ServiceAppointment apt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailsScreen(appointment: apt),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.canopy,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.canopy.withValues(alpha: 0.15),
                blurRadius: 8,
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
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt.serviceTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pet: ${apt.petName} • ${apt.clinicName}',
                      style: const TextStyle(color: AppColors.pistachioSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderRow(BuildContext context, Reminder reminder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReminderDetailScreen(singleReminder: reminder),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Row(
            children: [
              Icon(
                reminder.isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: reminder.isCompleted ? AppColors.mossAccent : AppColors.primaryTerracotta,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                        color: reminder.isCompleted ? AppColors.softTaupe : AppColors.inkText,
                      ),
                    ),
                    Text(
                      '${reminder.type} • ${DateHelpers.formatTime(reminder.scheduledTime)}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.softTaupe),
            ],
          ),
        ),
      ),
    );
  }
}
