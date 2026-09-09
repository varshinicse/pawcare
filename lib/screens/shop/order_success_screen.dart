import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'orders_list_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double totalAmount;
  final int itemsCount;
  final String deliveryAddress;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.itemsCount,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ICON
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.mossAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.mossAccent,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed Successfully! 🎉',
                style: AppTypography.displayMedium.copyWith(fontSize: 24, color: AppColors.canopy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your pet care supplies have been processed and will be delivered in 2-3 business days.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.softTaupe),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // SUMMARY CARD
              Container(
                width: double.infinity,
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
                  children: [
                    _buildRow('Order ID', orderId.toUpperCase()),
                    const Divider(height: 20),
                    _buildRow('Total Paid', '₹${totalAmount.toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _buildRow('Total Items', '$itemsCount Items'),
                    const Divider(height: 20),
                    _buildRow('Estimated Delivery', 'Tomorrow by 6 PM'),
                  ],
                ),
              ),
              const Spacer(),

              // ACTIONS
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canopy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrdersListScreen(),
                      ),
                    );
                  },
                  child: const Text('View Order History 📦', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.inkText,
                    side: const BorderSide(color: AppColors.dividerColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Home Hub'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
