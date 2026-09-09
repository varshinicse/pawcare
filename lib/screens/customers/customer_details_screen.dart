import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'add_edit_customer_screen.dart';
import 'customer_pets_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete ${customer.name}?'),
        content: const Text('Are you sure you want to remove this customer record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () {
              Provider.of<CustomerProvider>(context, listen: false).deleteCustomer(customer.id);
              Navigator.pop(ctx); // pop dialog
              Navigator.pop(context); // pop screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Customer ${customer.name} removed.'), backgroundColor: AppColors.alertCoral),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final allPets = petProvider.pets;
    final customerPets = allPets.where((p) => customer.registeredPetIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(customer.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Customer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddEditCustomerScreen(existingCustomer: customer)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertCoral),
            tooltip: 'Delete Customer',
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.canopy.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.pistachioSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.pistachioDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      customer.name,
                      style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since ${customer.joinedDate.year}',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contact Info Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONTACT DETAILS', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryTerracotta, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', customer.phone),
                    const Divider(height: 20, color: AppColors.dividerColor),
                    _buildInfoRow(Icons.email_outlined, 'Email', customer.email),
                    const Divider(height: 20, color: AppColors.dividerColor),
                    _buildInfoRow(Icons.location_on_outlined, 'Address', customer.address),
                    if (customer.notes.isNotEmpty) ...[
                      const Divider(height: 20, color: AppColors.dividerColor),
                      _buildInfoRow(Icons.notes_rounded, 'Notes', customer.notes),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Registered Pets Section & Navigation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('REGISTERED PETS', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryTerracotta, fontWeight: FontWeight.w800)),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CustomerPetsScreen(customer: customer, pets: customerPets.isNotEmpty ? customerPets : allPets),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryTerracotta),
                          label: Text('View Pets Flow', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryTerracotta, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (customerPets.isEmpty && allPets.isEmpty)
                      Text('No registered pets linked to this customer yet.', style: AppTypography.bodySmall)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (customerPets.isNotEmpty ? customerPets : allPets).take(2).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final pet = (customerPets.isNotEmpty ? customerPets : allPets)[idx];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.dividerColor),
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.mossLight,
                              child: Icon(Icons.pets_rounded, color: AppColors.pistachioDark, size: 18),
                            ),
                            title: Text(pet.name, style: AppTypography.labelLarge),
                            subtitle: Text('${pet.breed} • ${pet.age} yrs', style: AppTypography.bodySmall),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softTaupe),
                            onTap: () {
                              petProvider.selectPet(pet);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomerPetsScreen(customer: customer, pets: [pet]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.softTaupe),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              const SizedBox(height: 2),
              Text(value.isNotEmpty ? value : 'Not provided', style: AppTypography.labelLarge.copyWith(fontSize: 13.5)),
            ],
          ),
        ),
      ],
    );
  }
}
