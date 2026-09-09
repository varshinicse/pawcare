import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'add_edit_customer_screen.dart';
import 'customer_details_screen.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final allCustomers = customerProvider.customers;

    final filtered = allCustomers.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Pet Parents & Customers 👥'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Add New Customer',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryTerracotta,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Search by customer name, phone, email...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.softTaupe),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

            // Customers List
            Expanded(
              child: customerProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTerracotta))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_search_rounded, size: 48, color: AppColors.softTaupe),
                              const SizedBox(height: 12),
                              Text('No customers found', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                              const SizedBox(height: 6),
                              Text('Tap + to register a new pet parent', style: AppTypography.bodySmall),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, index) {
                            final customer = filtered[index];
                            return _buildCustomerCard(context, customer);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomerDetailsScreen(customer: customer)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.canopy.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.canopy,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: AppTypography.labelLarge.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(customer.phone, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.pets_rounded, size: 12, color: AppColors.primaryTerracotta),
                      const SizedBox(width: 4),
                      Text(
                        '${customer.registeredPetIds.length} registered pets',
                        style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.primaryTerracotta),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.softTaupe),
          ],
        ),
      ),
    );
  }
}
