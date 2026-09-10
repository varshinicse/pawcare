import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../models/service_item_model.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';
import 'booking_confirmation_screen.dart';

class ServiceBookingScreen extends StatefulWidget {
  final ServiceItem service;

  const ServiceBookingScreen({super.key, required this.service});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  Pet? _selectedPet;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '10:00 AM';
  final TextEditingController _notesController = TextEditingController();

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '03:30 PM',
    '05:00 PM',
    '06:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      setState(() {
        _selectedPet = petProvider.activePet ?? (petProvider.pets.isNotEmpty ? petProvider.pets.first : null);
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final pets = petProvider.pets;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Book Appointment'),
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
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
                  Text(
                    '₹${widget.service.price.toStringAsFixed(0)}',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 22,
                      color: AppColors.canopy,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _selectedPet == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingConfirmationScreen(
                                  service: widget.service,
                                  pet: _selectedPet!,
                                  date: _selectedDate,
                                  timeSlot: _selectedTimeSlot,
                                  notes: _notesController.text.trim(),
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      'Review Booking',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image with gentle ambient overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/book_appointment_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Scrollable Booking Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SERVICE HERO BANNER WITH BACKGROUND IMAGE
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.canopy,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.canopy.withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.38,
                            child: Image.asset(
                              'assets/images/book_appointment_bg.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.canopy.withValues(alpha: 0.94),
                                  AppColors.canopy.withValues(alpha: 0.65),
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.buttercreamAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.service.category.toUpperCase(),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.canopy,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded, color: Colors.white, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${widget.service.durationMinutes} mins',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.service.title,
                                style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Compassionate, gentle care for your pet 🐾',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // STEP 1: SELECT PET
                Text('1. SELECT PET', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (pets.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.softTaupe),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('No pets registered yet. Please add a pet first.')),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/add-pet'),
                      child: const Text('Add Pet'),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    final isSelected = _selectedPet?.id == pet.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPet = pet),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.canopy : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.canopy : AppColors.dividerColor,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.canopy.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.clayLight,
                              child: Icon(
                                Icons.pets_rounded,
                                color: isSelected ? Colors.white : AppColors.clayPrimary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pet.name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.inkText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    pet.species.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? AppColors.pistachioSecondary : AppColors.softTaupe,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // STEP 2: SELECT DATE
            Text('2. SELECT DATE', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final isSelected = DateUtils.isSameDay(_selectedDate, date);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 65,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryTerracotta : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryTerracotta : AppColors.dividerColor,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateHelpers.formatDayOfWeek(date).substring(0, 3).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : AppColors.softTaupe,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.inkText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // STEP 3: TIME SLOT
            Text('3. SELECT TIME SLOT', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedTimeSlot = slot);
                  },
                  selectedColor: AppColors.canopy,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.inkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? AppColors.canopy : AppColors.dividerColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // STEP 4: SPECIAL NOTES
            Text('4. SPECIAL NOTES / PREFERENCES', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Bruno gets anxious around loud dryers, please be gentle.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.dividerColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
        ],
      ),
    );
  }
}
