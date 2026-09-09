import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/pet_model.dart';
import '../../models/service_item_model.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';
import 'booking_success_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final ServiceItem service;
  final Pet pet;
  final DateTime date;
  final String timeSlot;
  final String notes;

  const BookingConfirmationScreen({
    super.key,
    required this.service,
    required this.pet,
    required this.date,
    required this.timeSlot,
    required this.notes,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isBooking = false;

  Future<void> _handleConfirm() async {
    setState(() => _isBooking = true);

    final appointment = ServiceAppointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      serviceTitle: widget.service.title,
      serviceCategory: widget.service.category,
      petId: widget.pet.id,
      petName: widget.pet.name,
      dateTime: widget.date,
      price: widget.service.price,
      status: 'Confirmed',
      clinicName: 'PawCare Indiranagar Facility',
      notes: widget.notes.isNotEmpty ? widget.notes : 'Standard service requested.',
    );

    await Provider.of<AppointmentProvider>(context, listen: false).createAppointment(appointment);

    if (mounted) {
      setState(() => _isBooking = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(appointment: appointment),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Review Booking'),
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
              onPressed: _isBooking ? null : _handleConfirm,
              child: _isBooking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Confirm Appointment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SUMMARY CARD
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
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.clayLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(widget.service.icon, color: AppColors.primaryTerracotta, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.service.title, style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('${widget.service.category} • ${widget.service.durationMinutes} mins', style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Pet', '${widget.pet.name} (${widget.pet.species.toUpperCase()})'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date', DateHelpers.formatDate(widget.date)),
                  const SizedBox(height: 12),
                  _buildDetailRow('Time Slot', widget.timeSlot),
                  const SizedBox(height: 12),
                  _buildDetailRow('Location', 'PawCare Indiranagar Center'),
                  if (widget.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('Notes', widget.notes),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PRICE BREAKDOWN
            Text('Price Breakdown', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Service Fee', '₹${widget.service.price.toStringAsFixed(0)}'),
                  const SizedBox(height: 10),
                  _buildPriceRow('Platform & Sanitization Fee', '₹0 (Free)'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Payable', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                      Text(
                        '₹${widget.service.price.toStringAsFixed(0)}',
                        style: AppTypography.displaySmall.copyWith(
                          fontSize: 20,
                          color: AppColors.canopy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CANCELLATION POLICY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.buttercreamAccent.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.buttercreamAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.canopy, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Free cancellation and rescheduling up to 4 hours before your slot.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.canopy, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
