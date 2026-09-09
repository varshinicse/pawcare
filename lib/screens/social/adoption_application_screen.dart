import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/adoption_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'adoption_confirmation_screen.dart';

class AdoptionApplicationScreen extends StatefulWidget {
  final AdoptionListing listing;

  const AdoptionApplicationScreen({super.key, required this.listing});

  @override
  State<AdoptionApplicationScreen> createState() => _AdoptionApplicationScreenState();
}

class _AdoptionApplicationScreenState extends State<AdoptionApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _homeType = 'Apartment';
  bool _hasOtherPets = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = auth.userName;
    _phoneController.text = auth.userPhone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdoptionConfirmationScreen(
            listing: widget.listing,
            applicantName: _nameController.text.trim(),
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
        title: Text('Adoption Application (${widget.listing.petName})'),
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
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Submit Application for ${widget.listing.petName}',
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
              // PET SUMMARY BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.pets_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adopting: ${widget.listing.petName}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${widget.listing.breed} • ${widget.listing.shelterName}',
                            style: const TextStyle(color: AppColors.pistachioSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 1: APPLICANT INFO
              Text('1. APPLICANT DETAILS', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Residential Address / City',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your city/address' : null,
              ),
              const SizedBox(height: 24),

              // SECTION 2: HOME ENVIRONMENT
              Text('2. HOME ENVIRONMENT', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _homeType,
                    isExpanded: true,
                    items: ['Apartment', 'Independent Villa / House', 'Farmhouse / Open Space']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _homeType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Do you currently own other pets?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _hasOtherPets,
                  activeColor: AppColors.canopy,
                  onChanged: (val) => setState(() => _hasOtherPets = val),
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 3: STATEMENT
              Text('3. WHY DO YOU WANT TO ADOPT?', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell the shelter team why you\'d like to welcome ${widget.listing.petName} into your family...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
