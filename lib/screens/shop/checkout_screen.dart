import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ecosystem_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<MarketplaceProduct> items;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _paymentMethod = 'UPI / Google Pay';
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = auth.userName;
    _phoneController.text = auth.userPhone;
    _addressController.text = '12th Main, 100ft Road, Indiranagar, Bengaluru';
    _pincodeController.text = '560038';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final activePetId = petProvider.activePet?.id ?? (petProvider.pets.isNotEmpty ? petProvider.pets.first.id : 'pet_1');

    final ecoProvider = Provider.of<EcosystemProvider>(context, listen: false);
    await ecoProvider.checkoutCart(activePetId);

    if (mounted) {
      setState(() => _isPlacingOrder = false);
      final createdOrder = ecoProvider.orders.isNotEmpty ? ecoProvider.orders.first : null;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderId: createdOrder?.id ?? 'ORD_${DateTime.now().millisecondsSinceEpoch}',
            totalAmount: widget.total,
            itemsCount: widget.items.length,
            deliveryAddress: _addressController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Checkout 📦'),
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
              onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Place Order • ₹${widget.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: DELIVERY ADDRESS
              Text('1. DELIVERY ADDRESS', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Recipient Name'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter recipient name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Street Address & Landmark'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter delivery address' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'PIN Code'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter PIN code' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 2: PAYMENT METHOD
              Text('2. PAYMENT METHOD', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Column(
                  children: ['UPI / Google Pay', 'Credit / Debit Card', 'Cash on Delivery']
                      .map((method) {
                    final isSel = _paymentMethod == method;
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(method, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      value: method,
                      groupValue: _paymentMethod,
                      activeColor: AppColors.canopy,
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: ORDER SUMMARY
              Text('3. ORDER ITEMS (${widget.items.length})', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
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
                    ...widget.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.mossAccent),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.title, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text('₹${item.price.toStringAsFixed(0)}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                        Text(
                          '₹${widget.total.toStringAsFixed(0)}',
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 18,
                            color: AppColors.canopy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
