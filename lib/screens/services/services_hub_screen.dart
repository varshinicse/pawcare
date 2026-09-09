import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'appointments_list_screen.dart';
import 'care_schedule_screen.dart';
import 'services_list_screen.dart';

class ServicesHubScreen extends StatefulWidget {
  final int initialTabIndex;

  const ServicesHubScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Care & Services 🛁'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.canopy,
          indicatorWeight: 3,
          labelColor: AppColors.canopy,
          unselectedLabelColor: AppColors.softTaupe,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Catalog', icon: Icon(Icons.medical_services_outlined, size: 20)),
            Tab(text: 'Appointments', icon: Icon(Icons.event_outlined, size: 20)),
            Tab(text: 'Schedule', icon: Icon(Icons.calendar_month_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ServicesListScreen(),
          AppointmentsListScreen(),
          CareScheduleScreen(),
        ],
      ),
    );
  }
}
