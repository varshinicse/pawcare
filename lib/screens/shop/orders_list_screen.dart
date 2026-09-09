import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';
import 'order_details_screen.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final orders = ecoProvider.orders;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('My Orders 📦'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.softTaupe),
                    const SizedBox(height: 16),
                    Text('No Orders Placed Yet', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                    const SizedBox(height: 6),
                    Text(
                      'When you purchase pet food, toys, or healthcare products, your order receipts will appear here.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order);
              },
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderRecord order) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.toUpperCase()}',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mossLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: const TextStyle(color: AppColors.mossAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateHelpers.formatDate(order.orderDate),
              style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe, fontSize: 12),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Text(
                  '${order.items.length} items',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 18,
                    color: AppColors.canopy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softTaupe),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
