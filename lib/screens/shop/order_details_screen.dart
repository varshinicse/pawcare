import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderRecord order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text('Order #${order.id.toUpperCase()}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS BANNER
            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mossLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: const TextStyle(color: AppColors.mossAccent, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      Text(
                        DateHelpers.formatDate(order.orderDate),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: AppTypography.displayMedium.copyWith(color: AppColors.canopy, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text('${order.items.length} items purchased', style: AppTypography.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ITEMS IN THIS ORDER
            Text('ITEMS IN THIS ORDER', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.clayLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryTerracotta, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(item.category.toUpperCase(), style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.softTaupe)),
                            ],
                          ),
                        ),
                        Text('₹${item.price.toStringAsFixed(0)}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // DELIVERY TIMELINE
            Text('DELIVERY STATUS & TIMELINE', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  _buildTimelineStep('Order Placed & Confirmed', 'Payment verified', true),
                  const Divider(height: 20),
                  _buildTimelineStep('Packed & Dispatched', 'PawCare Central Warehouse', true),
                  const Divider(height: 20),
                  _buildTimelineStep('Out for Delivery', 'With courier partner', true),
                  const Divider(height: 20),
                  _buildTimelineStep('Delivered to Doorstep', 'Package received', true),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isDone ? AppColors.mossAccent : AppColors.softTaupe,
          size: 20,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
