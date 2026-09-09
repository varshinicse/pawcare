import 'package:flutter/material.dart';
import '../../models/adoption_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AdoptionConfirmationScreen extends StatelessWidget {
  final AdoptionListing listing;
  final String applicantName;

  const AdoptionConfirmationScreen({
    super.key,
    required this.listing,
    required this.applicantName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // HEART ICON
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryTerracotta.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primaryTerracotta,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Application Received! 🐾',
                style: AppTypography.displayMedium.copyWith(fontSize: 24, color: AppColors.canopy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you $applicantName! Your application to adopt ${listing.petName} has been submitted to ${listing.shelterName}.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // NEXT STEPS CARD
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What happens next?', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildStepRow('1', 'The shelter team will review your application within 24-48 hours.'),
                    const SizedBox(height: 10),
                    _buildStepRow('2', 'A representative will reach out via phone to schedule a meet & greet.'),
                    const SizedBox(height: 10),
                    _buildStepRow('3', 'Complete home readiness check and welcome ${listing.petName} home!'),
                  ],
                ),
              ),
              const Spacer(),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canopy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Home Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.clayLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(color: AppColors.clayPrimary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.inkText, height: 1.3)),
        ),
      ],
    );
  }
}
