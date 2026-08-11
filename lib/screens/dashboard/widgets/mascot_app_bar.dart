import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/reminder_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

enum MascotState { idle, happy, worried }

class MascotAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String ownerName;
  final VoidCallback? onNotificationTap;

  const MascotAppBar({
    super.key,
    required this.ownerName,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(92.0);

  @override
  State<MascotAppBar> createState() => _MascotAppBarState();
}

class _MascotAppBarState extends State<MascotAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;
  MascotState _currentState = MascotState.idle;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    // Determine state dynamically
    if (reminderProvider.justCompletedAction) {
      _currentState = MascotState.happy;
    } else if (reminderProvider.hasOverdueReminders) {
      _currentState = MascotState.worried;
    } else {
      _currentState = MascotState.idle;
    }

    return Container(
      color: AppColors.creamBase,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // MASCOT COMPANION AVATAR & STATUS
              Expanded(
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _currentState == MascotState.happy ? _bounceAnimation.value * 1.5 : _bounceAnimation.value),
                          child: _buildMascotAvatar(_currentState),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PawCare Companion',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.softTaupe,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _getMascotStatusText(_currentState),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelLarge.copyWith(
                                    fontSize: 14,
                                    color: _getMascotStatusColor(_currentState),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(_getMascotEmoji(_currentState), style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // NOTIFICATION BELL WITH BADGE & STREAK COUNTER
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Streak Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.clayLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.clayPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${reminderProvider.completedStreak}d streak',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.clayPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Notification Bell
                  Stack(
                    children: [
                      IconButton(
                        onPressed: widget.onNotificationTap,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.inkText,
                            size: 20,
                          ),
                        ),
                      ),
                      if (reminderProvider.todayReminders.any((r) => !r.isCompleted) || reminderProvider.hasOverdueReminders)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.alertCoral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotAvatar(MascotState state) {
    Color bg;
    IconData icon;

    switch (state) {
      case MascotState.happy:
        bg = AppColors.mossAccent;
        icon = Icons.pets_rounded;
        break;
      case MascotState.worried:
        bg = AppColors.alertCoral;
        icon = Icons.sentiment_dissatisfied_rounded;
        break;
      case MascotState.idle:
      default:
        bg = AppColors.clayPrimary;
        icon = Icons.pets_rounded;
        break;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  String _getMascotStatusText(MascotState state) {
    switch (state) {
      case MascotState.happy:
        return 'Tail Wagging!';
      case MascotState.worried:
        return 'Needs Attention!';
      case MascotState.idle:
      default:
        return 'All Cozy';
    }
  }

  Color _getMascotStatusColor(MascotState state) {
    switch (state) {
      case MascotState.happy:
        return AppColors.mossAccent;
      case MascotState.worried:
        return AppColors.alertCoral;
      case MascotState.idle:
      default:
        return AppColors.inkText;
    }
  }

  String _getMascotEmoji(MascotState state) {
    switch (state) {
      case MascotState.happy:
        return '🦴';
      case MascotState.worried:
        return '🥺';
      case MascotState.idle:
      default:
        return '🐾';
    }
  }
}
