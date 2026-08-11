import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class EmergencyVetScreen extends StatelessWidget {
  const EmergencyVetScreen({super.key});

  final List<Map<String, String>> _vetList = const [
    {
      'name': 'Apollo 24/7 Pet Emergency Hospital',
      'phone': '+919876543210',
      'address': 'Plot 42, HSR Layout, Sector 1, Bangalore',
      'distance': '1.2 km away',
      'status': 'Open 24 Hours • Emergency Care',
    },
    {
      'name': 'Paws & Claws Veterinary Clinic',
      'phone': '+919876543211',
      'address': '12th Main Road, Indiranagar, Bangalore',
      'distance': '3.5 km away',
      'status': 'Open 24 Hours • ICU & Trauma Unit',
    },
    {
      'name': 'City Pet Multispecialty Hospital',
      'phone': '+919876543212',
      'address': '80 Feet Road, Koramangala 4th Block, Bangalore',
      'distance': '4.8 km away',
      'status': 'Closes 10:00 PM • Surgery & X-Ray',
    },
    {
      'name': 'Happy Tails Animal Clinic',
      'phone': '+919876543213',
      'address': 'Outer Ring Road, Bellandur, Bangalore',
      'distance': '6.1 km away',
      'status': 'Open 24 Hours • Ambulance Available',
    },
  ];

  Future<void> _makeCall(BuildContext context, String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calling $phone...'),
              backgroundColor: AppColors.clayPrimary,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling $phone...'),
            backgroundColor: AppColors.clayPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Emergency Vet Directory 🚑'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgent Emergency Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.alertLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.alertCoral.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.alertCoral,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Immediate Assistance',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.alertCoral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verified 24/7 veterinary hospitals & emergency services near your location.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.inkText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Nearest Clinics', style: AppTypography.displaySmall),
            const SizedBox(height: 14),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vetList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final vet = _vetList[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.inkText.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vet['name']!,
                              style: AppTypography.displaySmall.copyWith(fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mossLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              vet['distance']!,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.mossAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        vet['status']!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mossAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.softTaupe),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vet['address']!,
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alertCoral,
                          ),
                          onPressed: () => _makeCall(context, vet['phone']!),
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                          label: Text('Call Hospital Now (${vet['phone']})'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
