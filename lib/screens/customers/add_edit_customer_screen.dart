import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final Customer? existingCustomer;

  const AddEditCustomerScreen({super.key, this.existingCustomer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCustomer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    final provider = Provider.of<CustomerProvider>(context, listen: false);

    if (widget.existingCustomer != null) {
      final updated = widget.existingCustomer!.copyWith(
        name: name,
        phone: phone,
        email: email,
        address: address,
        notes: notes,
      );
      provider.updateCustomer(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer $name updated successfully! 🎉'), backgroundColor: AppColors.pistachioSecondary),
      );
    } else {
      final newCustomer = Customer(
        id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        email: email,
        address: address,
        registeredPetIds: [],
        joinedDate: DateTime.now(),
        notes: notes,
      );
      provider.addCustomer(newCustomer);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer $name registered! 🐾'), backgroundColor: AppColors.pistachioSecondary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCustomer != null;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Register Pet Parent 👥'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update Contact Information' : 'New Pet Parent Details',
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage customer profiles, contact info, and registered pets.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Customer Full Name *', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter customer name' : null,
                ),
                const SizedBox(height: 14),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 14),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Address / Location', prefixIcon: Icon(Icons.location_on_outlined)),
                ),
                const SizedBox(height: 14),

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Customer Notes / Care Preferences', prefixIcon: Icon(Icons.note_alt_outlined)),
                ),
                const SizedBox(height: 28),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _saveCustomer,
                    child: Text(isEditing ? 'Save Changes' : 'Register Customer 🐾'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
