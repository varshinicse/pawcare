import 'package:flutter/material.dart';
import '../../models/service_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_background_wrapper.dart';
import 'service_details_screen.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Grooming',
    'Veterinary',
    'Vaccination',
    'Walking',
    'Daycare',
  ];

  @override
  Widget build(BuildContext context) {
    final catalog = ServiceItem.defaultCatalog;
    final filtered = _selectedCategory == 'All'
        ? catalog
        : catalog.where((s) => s.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Care & Services 🛁'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_dog_friends.jpg',
        imageOpacity: 0.12,
        child: Column(
          children: [
            // CATEGORY SELECTOR
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: AppColors.canopy,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.inkText,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSel ? AppColors.canopy : AppColors.dividerColor,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            // LIST
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final service = filtered[index];
                  return _buildServiceCard(context, service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem service) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsScreen(service: service),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
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
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.clayLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(service.icon, color: AppColors.primaryTerracotta, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.buttercreamAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.tag.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.canopy,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹${service.price.toStringAsFixed(0)}',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 18,
                              color: AppColors.canopy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(service.title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(height: 1.4),
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${service.rating}', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                Text(' (${service.reviewsCount})', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(width: 14),
                const Icon(Icons.timer_outlined, color: AppColors.softTaupe, size: 14),
                const SizedBox(width: 4),
                Text('${service.durationMinutes} mins', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                const Spacer(),
                const Text(
                  'Book Now ➔',
                  style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
