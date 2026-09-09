import 'package:flutter/material.dart';
import '../../models/adoption_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'adoption_application_screen.dart';

class AdoptionDetailsScreen extends StatelessWidget {
  final AdoptionListing listing;

  const AdoptionDetailsScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('${listing.petName}\'s Story 🐾'),
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
                    builder: (_) => AdoptionApplicationScreen(listing: listing),
                  ),
                );
              },
              child: Text(
                'Apply to Adopt ${listing.petName} 🐾',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO IMAGE
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pets-community.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // BODY CONTENT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE & BREED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(listing.petName, style: AppTypography.displayMedium.copyWith(fontSize: 24, color: AppColors.canopy)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mossLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          listing.species.toUpperCase(),
                          style: const TextStyle(color: AppColors.mossAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${listing.breed} • ${listing.age}', style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe)),
                  const SizedBox(height: 20),

                  // TRAITS BADGES
                  Row(
                    children: [
                      _buildTraitPill(Icons.health_and_safety_outlined, 'Vaccinated'),
                      const SizedBox(width: 8),
                      _buildTraitPill(Icons.sentiment_very_satisfied_rounded, 'Friendly'),
                      const SizedBox(width: 8),
                      _buildTraitPill(Icons.home_outlined, 'House Trained'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // RESCUE STORY / ABOUT
                  Text('About ${listing.petName}', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    listing.description.isNotEmpty
                        ? listing.description
                        : '${listing.petName} was lovingly rescued and fostered by ${listing.shelterName}. They are energetic, gentle with other pets, and looking for a forever home filled with love and play.',
                    style: AppTypography.bodyMedium.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // SHELTER & GUARDIAN DETAILS
                  Text('Shelter & Guardian Information', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.clayLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.apartment_rounded, color: AppColors.primaryTerracotta, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(listing.shelterName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                  Text(listing.location, style: AppTypography.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (listing.contactPhone.isNotEmpty) ...[
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 18, color: AppColors.softTaupe),
                              const SizedBox(width: 10),
                              Text('Helpline: ${listing.contactPhone}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitPill(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.canopy, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.canopy)),
          ],
        ),
      ),
    );
  }
}
