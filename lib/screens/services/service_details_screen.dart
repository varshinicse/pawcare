import 'package:flutter/material.dart';
import '../../models/service_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'service_booking_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceItem service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(service.category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price', style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
                  Text(
                    '₹${service.price.toStringAsFixed(0)}',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 22,
                      color: AppColors.canopy,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceBookingScreen(service: service),
                        ),
                      );
                    },
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO BANNER
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.canopy,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.canopy.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    if (service.imageAsset != null)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.35,
                          child: Image.asset(
                            service.imageAsset!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.canopy.withValues(alpha: 0.92),
                              AppColors.canopy.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.buttercreamAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.tag.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.buttercreamAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(service.icon, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.title,
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating} (${service.reviewsCount} reviews)',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.timer_outlined, color: AppColors.pistachioSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes} mins',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 24),

            // OVERVIEW
            Text('About This Service', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              service.description,
              style: AppTypography.bodyMedium.copyWith(height: 1.5, color: AppColors.inkText),
            ),
            const SizedBox(height: 24),

            // WHAT'S INCLUDED
            Text('What\'s Included', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: service.includedFeatures.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.mossAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // CLINIC / SALON LOCATION
            Text('Location & Facility', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.clayLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: AppColors.primaryTerracotta, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PawCare Wellness Center & Salon', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('12th Main, 100ft Road, Indiranagar, Bengaluru', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
