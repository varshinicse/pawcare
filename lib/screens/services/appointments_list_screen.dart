import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';
import 'appointment_details_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final all = appointmentProvider.appointments;

    final filtered = _selectedFilter == 'All'
        ? all
        : all.where((a) => a.status.toLowerCase() == _selectedFilter.toLowerCase() ||
            (_selectedFilter == 'Upcoming' && a.status == 'Confirmed')).toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('My Appointments 📅'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _filters.map((f) {
                final isSel = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = f);
                    },
                    selectedColor: AppColors.canopy,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSel ? AppColors.canopy : AppColors.dividerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // LIST
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_busy_rounded, size: 56, color: AppColors.softTaupe),
                          const SizedBox(height: 14),
                          Text(
                            'No $_selectedFilter Appointments',
                            style: AppTypography.displaySmall.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Book a new service appointment from the Services Catalog.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final apt = filtered[index];
                      return _buildAppointmentCard(context, apt);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, ServiceAppointment apt) {
    final statusColor = apt.status == 'Confirmed' || apt.status == 'Upcoming'
        ? AppColors.mossAccent
        : apt.status == 'Completed'
            ? AppColors.softTaupe
            : AppColors.alertCoral;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailsScreen(appointment: apt),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    apt.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  '₹${apt.price.toStringAsFixed(0)}',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.canopy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(apt.serviceTitle, style: AppTypography.displaySmall.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Pet: ${apt.petName} • ${apt.serviceCategory}', style: AppTypography.bodySmall.copyWith(color: AppColors.softTaupe)),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.softTaupe),
                const SizedBox(width: 6),
                Text(
                  DateHelpers.formatDate(apt.dateTime),
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softTaupe),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
