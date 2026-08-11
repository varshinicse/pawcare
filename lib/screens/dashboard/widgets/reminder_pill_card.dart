import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../models/reminder_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';

class ReminderPillCard extends StatefulWidget {
  final Reminder reminder;
  final Function(Reminder) onToggleComplete;

  const ReminderPillCard({
    super.key,
    required this.reminder,
    required this.onToggleComplete,
  });

  @override
  State<ReminderPillCard> createState() => _ReminderPillCardState();
}

class _ReminderPillCardState extends State<ReminderPillCard>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 600));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    _scaleController.forward().then((_) => _scaleController.reverse());
    if (!widget.reminder.isCompleted) {
      _confettiController.play();
    }
    widget.onToggleComplete(widget.reminder);
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.reminder;
    final isCompleted = reminder.isCompleted;
    final isOverdue = DateHelpers.isOverdue(reminder.scheduledTime, isCompleted);

    final typeColor = _getTypeColor(reminder.type, isCompleted, isOverdue);
    final typeIcon = _getTypeIcon(reminder.type);

    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppColors.clayPrimary,
            AppColors.mossAccent,
            Color(0xFFFFD166),
            Color(0xFF06D6A0),
          ],
          numberOfParticles: 15,
        ),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.mossLight
                  : (isOverdue ? AppColors.alertLight : Colors.white),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isCompleted
                    ? AppColors.mossAccent.withValues(alpha: 0.4)
                    : (isOverdue ? AppColors.alertCoral.withValues(alpha: 0.4) : AppColors.dividerColor),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header row: Type Badge & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(typeIcon, size: 14, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            reminder.type.toUpperCase(),
                            style: AppTypography.labelMedium.copyWith(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateHelpers.formatTime(reminder.scheduledTime),
                      style: AppTypography.numericData.copyWith(
                        fontSize: 12,
                        color: isOverdue ? AppColors.alertCoral : AppColors.softTaupe,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  reminder.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 16,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.softTaupe : AppColors.inkText,
                  ),
                ),

                if (reminder.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reminder.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.softTaupe,
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Checkbox Action Button
                GestureDetector(
                  onTap: _handleTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.mossAccent : AppColors.creamSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 18,
                          color: isCompleted ? Colors.white : AppColors.inkText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompleted ? 'Completed 🐾' : 'Mark Done',
                          style: AppTypography.labelMedium.copyWith(
                            color: isCompleted ? Colors.white : AppColors.inkText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type, bool isCompleted, bool isOverdue) {
    if (isCompleted) return AppColors.mossAccent;
    if (isOverdue) return AppColors.alertCoral;

    switch (type.toLowerCase()) {
      case 'medication':
        return AppColors.alertCoral;
      case 'feeding':
        return AppColors.clayPrimary;
      case 'grooming':
        return const Color(0xFF8E7DBE);
      case 'vaccination':
        return AppColors.mossAccent;
      case 'checkup':
      default:
        return const Color(0xFF4A90E2);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return Icons.medication_rounded;
      case 'feeding':
        return Icons.restaurant_rounded;
      case 'grooming':
        return Icons.content_cut_rounded;
      case 'vaccination':
        return Icons.vaccines_rounded;
      case 'checkup':
      default:
        return Icons.health_and_safety_rounded;
    }
  }
}
