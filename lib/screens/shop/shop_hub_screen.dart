import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense_model.dart';
import '../../models/pet_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ShopHubScreen extends StatefulWidget {
  const ShopHubScreen({super.key});

  @override
  State<ShopHubScreen> createState() => _ShopHubScreenState();
}

class _ShopHubScreenState extends State<ShopHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _expenseTitleController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  String _selectedCategory = 'food';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _addExpenseLog(String petId) {
    final title = _expenseTitleController.text.trim();
    final amount = double.tryParse(_expenseAmountController.text) ?? 0.0;
    if (title.isEmpty || amount <= 0) return;

    final exp = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      category: _selectedCategory,
      title: title,
      amount: amount,
      date: DateTime.now(),
    );

    Provider.of<EcosystemProvider>(context, listen: false).addExpense(exp);
    _expenseTitleController.clear();
    _expenseAmountController.clear();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense logged successfully! 💸'),
        backgroundColor: AppColors.mossAccent,
      ),
    );
  }

  void _showAddExpenseSheet(String petId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Expense 💸', style: AppTypography.displaySmall),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Expense Category'),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Food & Treats')),
                  DropdownMenuItem(value: 'vet', child: Text('Vet Services')),
                  DropdownMenuItem(value: 'medicine', child: Text('Medicine & Pills')),
                  DropdownMenuItem(value: 'accessories', child: Text('Collars & Accessories')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _expenseTitleController,
                decoration: const InputDecoration(labelText: 'Description / Item name'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _expenseAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _addExpenseLog(petId),
                  child: const Text('Add Expense'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ecoProvider = Provider.of<EcosystemProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final activePet = petProvider.activePet;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Ecosystem Shop & Budget 🛍️'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.clayPrimary,
          unselectedLabelColor: AppColors.softTaupe,
          indicatorColor: AppColors.clayPrimary,
          tabs: const [
            Tab(text: 'MARKETPLACE'),
            Tab(text: 'BUDGET LOG'),
            Tab(text: 'ANALYTICS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketplaceTab(ecoProvider, activePet),
          _buildBudgetTab(ecoProvider, activePet?.id ?? 'default'),
          _buildAnalyticsTab(ecoProvider),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab(EcosystemProvider ecoProvider, Pet? activePet) {
    final products = ecoProvider.products;
    final cart = ecoProvider.cart;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final prod = products[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.creamSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.clayPrimary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prod.title, style: AppTypography.labelLarge),
                            const SizedBox(height: 2),
                            Text('₹${prod.price}', style: AppTypography.numericData.copyWith(color: AppColors.clayPrimary)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ecoProvider.addToCart(prod);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item added to cart! 🐾'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.clayPrimary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${cart.length} Items in Cart', style: AppTypography.labelLarge),
                  ElevatedButton(
                    onPressed: () {
                      ecoProvider.checkoutCart(activePet?.id ?? 'default');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Checkout completed! Order placed successfully. 🎉'),
                          backgroundColor: AppColors.mossAccent,
                        ),
                      );
                    },
                    child: const Text('Checkout Cart'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(EcosystemProvider ecoProvider, String petId) {
    final expenses = ecoProvider.expenses;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.clayPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddExpenseSheet(petId),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Expense'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.clayPrimary, Color(0xFFEA8E5D)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Monthly Budget', style: AppTypography.displaySmall.copyWith(color: Colors.white, fontSize: 18)),
                Text('₹${ecoProvider.grandTotal}', style: AppTypography.numericData.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final exp = expenses[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.title, style: AppTypography.labelLarge),
                          Text(exp.category.toUpperCase(), style: AppTypography.bodySmall),
                        ],
                      ),
                      Text('₹${exp.amount}', style: AppTypography.numericData.copyWith(color: AppColors.alertCoral)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(EcosystemProvider ecoProvider) {
    final food = ecoProvider.getCategoryTotal('food');
    final vet = ecoProvider.getCategoryTotal('vet');
    final medicine = ecoProvider.getCategoryTotal('medicine');
    final acc = ecoProvider.getCategoryTotal('accessories');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Share Analysis', style: AppTypography.displaySmall),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: ExpensePieChartPainter(
                  food: food,
                  vet: vet,
                  medicine: medicine,
                  accessories: acc,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPieLegend('Food & Treats (Clay)', AppColors.clayPrimary, food),
          _buildPieLegend('Vet Services (Moss)', AppColors.mossAccent, vet),
          _buildPieLegend('Medicines (Coral)', AppColors.alertCoral, medicine),
          _buildPieLegend('Accessories (Taupe)', AppColors.softTaupe, acc),
        ],
      ),
    );
  }

  Widget _buildPieLegend(String label, Color color, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(label, style: AppTypography.bodyMedium),
            ],
          ),
          Text('₹$amount', style: AppTypography.numericData),
        ],
      ),
    );
  }
}

class ExpensePieChartPainter extends CustomPainter {
  final double food;
  final double vet;
  final double medicine;
  final double accessories;

  ExpensePieChartPainter({
    required this.food,
    required this.vet,
    required this.medicine,
    required this.accessories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = food + vet + medicine + accessories;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final pFood = (food / total) * 2 * pi;
    final pVet = (vet / total) * 2 * pi;
    final pMed = (medicine / total) * 2 * pi;
    final pAcc = (accessories / total) * 2 * pi;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    double startAngle = -pi / 2;

    // Draw Food
    paint.color = AppColors.clayPrimary;
    canvas.drawArc(rect, startAngle, pFood, true, paint);
    startAngle += pFood;

    // Draw Vet
    paint.color = AppColors.mossAccent;
    canvas.drawArc(rect, startAngle, pVet, true, paint);
    startAngle += pVet;

    // Draw Med
    paint.color = AppColors.alertCoral;
    canvas.drawArc(rect, startAngle, pMed, true, paint);
    startAngle += pMed;

    // Draw Accessories
    paint.color = AppColors.softTaupe;
    canvas.drawArc(rect, startAngle, pAcc, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
