import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_design_tokens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/animated_paw_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/paw_buttons.dart';
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PawIconButton(
              icon: Icons.add,
              tooltip: 'Add New Customer',
              backgroundColor: AppColors.primaryTerracotta,
              iconColor: Colors.white,
              size: 38,
              iconSize: 20,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
                );
              },
            ),
          ),
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
                  boxShadow: AppShadows.softSm,
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name, phone, email...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.softTaupe),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.softTaupe),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: EmptyStateWidget(
                            title: _searchQuery.isEmpty ? 'No customers registered' : 'No customers match "$_searchQuery"',
                            description: _searchQuery.isEmpty
                                ? 'Register your first customer and link their beloved pets to manage their records.'
                                : 'Try searching for a different name, phone number, or email address.',
                            icon: Icons.people_outline_rounded,
                            buttonText: _searchQuery.isEmpty ? 'Add New Customer' : null,
                            onButtonPressed: _searchQuery.isEmpty
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
                                    );
                                  }
                                : null,
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
    return AnimatedPawCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomerDetailsScreen(customer: customer)),
        );
      },
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadius.xl,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.canopyGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.canopy.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
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
                      style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.primaryTerracotta, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.softTaupe),
        ],
      ),
    );
  }
}

