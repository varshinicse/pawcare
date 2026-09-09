import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/adoption_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'adoption_details_screen.dart';

class AdoptionListingsScreen extends StatefulWidget {
  const AdoptionListingsScreen({super.key});

  @override
  State<AdoptionListingsScreen> createState() => _AdoptionListingsScreenState();
}

class _AdoptionListingsScreenState extends State<AdoptionListingsScreen> {
  String _selectedSpecies = 'All';

  final List<String> _speciesFilters = ['All', 'Dog', 'Cat', 'Rabbit', 'Bird'];

  @override
  Widget build(BuildContext context) {
    final ecosystemProvider = Provider.of<EcosystemProvider>(context);
    final allListings = ecosystemProvider.adoptions;

    final filtered = _selectedSpecies == 'All'
        ? allListings
        : allListings.where((a) => a.species.toLowerCase() == _selectedSpecies.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Adopt a Pet 🏡🐾'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // SPECIES FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _speciesFilters.map((s) {
                final isSel = _selectedSpecies == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSpecies = s);
                    },
                    selectedColor: AppColors.canopy,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSel ? AppColors.canopy : AppColors.dividerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // LIST OF PETS
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pets_rounded, size: 56, color: AppColors.softTaupe),
                          const SizedBox(height: 14),
                          Text('No $_selectedSpecies available for adoption right now.', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('Check back soon as shelter partners update listings daily.', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final pet = filtered[index];
                      return _buildAdoptionCard(context, pet);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionCard(BuildContext context, AdoptionListing listing) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdoptionDetailsScreen(listing: listing),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PET PHOTO
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.clayLight,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/pets-community.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(listing.petName, style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mossLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.species.toUpperCase(),
                          style: const TextStyle(color: AppColors.mossAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.breed} • ${listing.age}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.softTaupe),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.shelterName,
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Profile & Adopt ➔',
                        style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
