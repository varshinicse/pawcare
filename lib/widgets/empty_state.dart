import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';
import 'paw_buttons.dart';

class EmptyStateWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.pets_rounded,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: AppShadows.softSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: child,
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: widget.iconBackgroundColor ?? AppColors.terracottaLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.iconColor ?? AppColors.primaryTerracotta).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 36,
                  color: widget.iconColor ?? AppColors.primaryTerracotta,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: AppTypography.displaySmall.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe, height: 1.45),
            ),
          ),
          if (widget.buttonText != null && widget.onButtonPressed != null) ...[
            const SizedBox(height: 24),
            PrimaryPawButton(
              text: widget.buttonText!,
              icon: Icons.add_rounded,
              onPressed: widget.onButtonPressed,
            ),
          ],
        ],
      ),
    );
  }
}

