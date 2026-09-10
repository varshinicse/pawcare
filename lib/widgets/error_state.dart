import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_design_tokens.dart';
import '../theme/app_typography.dart';
import 'paw_buttons.dart';

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.title = 'Oops, something went wrong',
    this.message = 'We encountered an issue loading your data. Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.alertCoral.withValues(alpha: 0.3)),
        boxShadow: AppShadows.softSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.alertLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.alertCoral,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.displaySmall.copyWith(fontSize: 18, color: AppColors.inkText),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe, height: 1.4),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            PrimaryPawButton(
              text: 'Try Again',
              icon: Icons.refresh_rounded,
              backgroundColor: AppColors.alertCoral,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
