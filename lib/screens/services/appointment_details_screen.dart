import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final ServiceAppointment appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  void _showRescheduleDialog(BuildContext context) async {
    final newDate = appointment.dateTime.add(const Duration(days: 1));

    final selected = await showDatePicker(
      context: context,
      initialDate: newDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (selected != null && context.mounted) {
      final updated = appointment.copyWith(
        dateTime: selected,
        status: 'Upcoming',
      );
      await Provider.of<AppointmentProvider>(context, listen: false).updateAppointment(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment rescheduled to ${DateHelpers.formatDate(selected)}.'),
            backgroundColor: AppColors.pistachioSecondary,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }


  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel Appointment?'),
        content: Text('Are you sure you want to cancel the booking for "${appointment.serviceTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () async {
              Navigator.of(dContext).pop();
              await Provider.of<AppointmentProvider>(context, listen: false).cancelAppointment(appointment.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled.'),
                    backgroundColor: AppColors.alertCoral,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = appointment.status == 'Confirmed' || appointment.status == 'Upcoming'
        ? AppColors.mossAccent
        : appointment.status == 'Completed'
            ? AppColors.softTaupe
            : AppColors.alertCoral;

    final isActionable = appointment.status != 'Cancelled' && appointment.status != 'Completed';

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: isActionable
          ? Container(
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
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.alertCoral,
                            side: const BorderSide(color: AppColors.alertCoral),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _confirmCancel(context),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Cancel Booking'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.canopy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () => _showRescheduleDialog(context),
                          icon: const Icon(Icons.event_repeat_rounded, size: 18),
                          label: const Text('Reschedule'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP STATUS BANNER
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
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        'ID: ${appointment.id.toUpperCase()}',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.softTaupe),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    appointment.serviceTitle,
                    style: AppTypography.displaySmall.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Category: ${appointment.serviceCategory}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe),
                  ),
                  const Divider(height: 28),
                  _buildDetailRow(Icons.pets_rounded, 'Pet', appointment.petName),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today_rounded, 'Date & Time', DateHelpers.formatDate(appointment.dateTime)),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.location_on_rounded, 'Location', appointment.clinicName),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.payments_rounded, 'Amount', '₹${appointment.price.toStringAsFixed(0)}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // NOTES SECTION
            if (appointment.notes.isNotEmpty) ...[
              Text('Special Instructions / Notes', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                child: Text(appointment.notes, style: AppTypography.bodyMedium),
              ),
              const SizedBox(height: 20),
            ],

            // FACILITY CONTACT
            Text('Facility Contact & Support', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pistachioSecondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_rounded, color: AppColors.canopy, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PawCare Helpdesk', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('+91 80 4912 8800', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.softTaupe),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
        const Spacer(),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
