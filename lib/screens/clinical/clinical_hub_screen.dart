import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/health_record_model.dart';
import '../../models/pet_model.dart';
import '../../providers/activity_tracker_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/interactive_motion/jumping_card.dart';
import '../../widgets/interactive_motion/staggered_entrance.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/pet_background_wrapper.dart';
import '../../widgets/pet_switcher_pill.dart';
import '../pet_profile/pet_detail_screen.dart';
import '../services/appointment_details_screen.dart';
import 'add_edit_health_record_screen.dart';
import 'ai_health_insights_screen.dart';
import 'health_record_details_screen.dart';
import 'medication_list_screen.dart';
import 'metric_detail_screens/activity_details_screen.dart';
import 'metric_detail_screens/heart_rate_history_screen.dart';
import 'metric_detail_screens/sleep_hydration_screen.dart';
import 'metric_detail_screens/temperature_history_screen.dart';
import 'metric_detail_screens/weight_tracking_screen.dart';
import 'vaccination_list_screen.dart';

class ClinicalHubScreen extends StatefulWidget {
  const ClinicalHubScreen({super.key});

  @override
  State<ClinicalHubScreen> createState() => _ClinicalHubScreenState();
}

class _ClinicalHubScreenState extends State<ClinicalHubScreen> {
  String _selectedTimelineFilter = 'all';
  String? _lastLoadedPetId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final petProvider = Provider.of<PetProvider>(context);
    final activePet = petProvider.activePet;
    if (activePet != null && activePet.id != _lastLoadedPetId) {
      _lastLoadedPetId = activePet.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<HealthRecordProvider>(context, listen: false).fetchRecordsForPet(activePet.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final hrProvider = Provider.of<HealthRecordProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final activityProvider = Provider.of<ActivityTrackerProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final activePet = petProvider.activePet ??
        (petProvider.pets.isNotEmpty
            ? petProvider.pets.first
            : Pet(
                id: 'default_bruno',
                ownerId: 'default_user',
                name: 'Bruno',
                species: 'dog',
                breed: 'Golden Retriever',
                age: 2.5,
                weightKg: 28.5,
                foodHabits: 'Royal Canin Maxi Adult - Twice daily',
                medicalHistory: ['Vaccinated DHPP', 'Annual Rabies'],
                avatarAsset: 'dog_hero',
                createdAt: DateTime.now(),
              ));

    final records = hrProvider.getRecordsForPet(activePet.id);

    // Timeline filtering
    final timelineRecords = records.where((r) {
      if (_selectedTimelineFilter == 'all') return true;
      if (_selectedTimelineFilter == 'vaccines') return r.type.toLowerCase().contains('vaccin');
      if (_selectedTimelineFilter == 'meds') return r.type.toLowerCase().contains('med');
      if (_selectedTimelineFilter == 'vitals') return r.type.toLowerCase().contains('vital') || r.type.toLowerCase().contains('weight') || r.type.toLowerCase().contains('temp');
      return r.type.toLowerCase() == _selectedTimelineFilter.toLowerCase();
    }).toList();

    // Vitals extraction
    final tempRecords = records.where((r) => r.temperatureCelsius > 0).toList();
    final latestTemp = tempRecords.isNotEmpty ? tempRecords.first.temperatureCelsius : 38.4;

    final weightRecords = records.where((r) => r.weightKg > 0).toList();
    final currentWeight = activePet.weightKg > 0 ? activePet.weightKg : (weightRecords.isNotEmpty ? weightRecords.first.weightKg : 28.5);

    final petLogs = activityProvider.getLogsForPet(activePet.id);
    final totalMinsToday = petLogs.fold<double>(0.0, (sum, l) => sum + l.durationMinutes);
    final activeMins = totalMinsToday > 0 ? totalMinsToday.toInt() : 55;

    final upcomingApts = appointmentProvider.upcomingAppointments
        .where((a) => a.petId == activePet.id || a.petName.toLowerCase() == activePet.name.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: PetBackgroundWrapper(
        imagePath: 'assets/images/cat_dog_friends.jpg',
        imageOpacity: 0.12,
        child: SafeArea(
          child: Column(
            children: [
            // 1. Header with Pet Switcher
            _buildHeader(context),

            // 2. Scrollable Healthcare Hub
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await hrProvider.fetchRecordsForPet(activePet.id);
                },
                color: AppColors.canopy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP SECTION: Clickable Pet Profile Hero Card
                      StaggeredEntrance(
                        index: 0,
                        child: _buildClickablePetProfileCard(context, activePet, latestTemp, currentWeight, activeMins),
                      ),
                      const SizedBox(height: 20),

                      // SECTION 2: Health Overview (7 Interactive Metric Cards)
                      StaggeredEntrance(
                        index: 1,
                        child: _buildHealthOverviewMetrics(context, activePet, latestTemp, currentWeight, activeMins),
                      ),
                      const SizedBox(height: 22),

                      // SECTION 3: AI Health Insights Card
                      StaggeredEntrance(
                        index: 2,
                        child: _buildAiHealthInsightsCard(context, activePet),
                      ),
                      const SizedBox(height: 22),

                      // SECTION 4: Vaccination & Medication Management Rail
                      StaggeredEntrance(
                        index: 3,
                        child: _buildVaccinationMedicationSection(context, activePet),
                      ),
                      const SizedBox(height: 22),

                      // SECTION 5: Upcoming Care & Vet Appointments
                      StaggeredEntrance(
                        index: 4,
                        child: _buildUpcomingCareSection(context, activePet, upcomingApts, reminderProvider),
                      ),
                      const SizedBox(height: 22),

                      // SECTION 6: Health Timeline & Record History
                      StaggeredEntrance(
                        index: 5,
                        child: _buildHealthTimelineSection(context, activePet, timelineRecords),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.canopy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Add Health Log', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditHealthRecordScreen(petId: activePet.id, petName: activePet.name),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.canopy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pet Healthcare',
                    style: AppTypography.displaySmall.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Live Clinical Vitals & Care Records',
                    style: AppTypography.labelSmall.copyWith(fontSize: 9.5, color: AppColors.pistachioDark, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const PetSwitcherPill(),
        ],
      ),
    );
  }

  Widget _buildClickablePetProfileCard(BuildContext context, Pet pet, double temp, double weight, int activeMins) {
    return JumpingCard(
      enableFloating: true,
      floatAmplitude: 2.5,
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.canopy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.canopy.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Pet Avatar with Hero Animation
                PetAvatar(
                  species: pet.species,
                  avatarAsset: pet.avatarAsset,
                  size: 64,
                  heroTag: 'pet_avatar_${pet.id}',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pet.name,
                            style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 22, height: 1.1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pistachioSecondary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Optimal Health 🌟',
                              style: TextStyle(color: AppColors.pistachioSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pet.breed} • ${pet.age.toStringAsFixed(1)} yrs • Male',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to view complete pet medical profile ➔',
                        style: TextStyle(color: AppColors.primaryGlow, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick Stat Badges
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileStat('Weight', '${weight.toStringAsFixed(1)} kg'),
                  Container(width: 1, height: 24, color: Colors.white24),
                  _buildProfileStat('Body Temp', '${temp.toStringAsFixed(1)}°C'),
                  Container(width: 1, height: 24, color: Colors.white24),
                  _buildProfileStat('Activity', '$activeMins mins'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildHealthOverviewMetrics(BuildContext context, Pet pet, double temp, double weight, int activeMins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH METRICS & VITALS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryTerracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Interactive Vitals & Telemetry', style: AppTypography.displaySmall.copyWith(fontSize: 17)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.canopy,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.canopy.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text('Score: 94/100 💚', style: TextStyle(color: AppColors.pistachioSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 6 Creative Full-Cover Image Metric Cards (Compact & Sleek)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.40,
          children: [
            // 1. Heart Rate Card
            _buildMetricTile(
              context: context,
              bgImage: 'assets/images/dog_avatar_bruno.jpg',
              icon: Icons.favorite_rounded,
              label: 'Heart Rate',
              value: '82 BPM',
              status: 'Normal • Resting',
              accentColor: AppColors.alertCoral,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HeartRateHistoryScreen(pet: pet)),
                );
              },
            ),

            // 2. Body Temperature Card
            _buildMetricTile(
              context: context,
              bgImage: 'assets/images/cute_puppy_pajamas.jpg',
              icon: Icons.thermostat_rounded,
              label: 'Body Temp',
              value: '${temp.toStringAsFixed(1)}°C',
              status: 'Normal Range',
              accentColor: AppColors.pistachioSecondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TemperatureHistoryScreen(pet: pet)),
                );
              },
            ),

            // 3. Weight Card
            _buildMetricTile(
              context: context,
              bgImage: 'assets/images/pet_feeding_routine.jpg',
              icon: Icons.scale_rounded,
              label: 'Body Weight',
              value: '${weight.toStringAsFixed(1)} kg',
              status: 'Optimal BCS 5/9',
              accentColor: AppColors.buttercreamAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WeightTrackingScreen(pet: pet)),
                );
              },
            ),

            // 4. Activity Level Card
            _buildMetricTile(
              context: context,
              bgImage: 'assets/images/dog_beach_play.jpg',
              icon: Icons.directions_run_rounded,
              label: 'Daily Activity',
              value: '$activeMins mins',
              status: 'Goal: 60 mins',
              accentColor: const Color(0xFF68D391),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ActivityDetailsScreen(pet: pet)),
                );
              },
            ),

            // 5. Sleep Tracking Card
            _buildMetricTile(
              context: context,
              bgImage: 'assets/images/cozy_cat_cuddle.jpg',
              icon: Icons.bedtime_rounded,
              label: 'Sleep Rest',
              value: '12.4 hrs',
              status: '5.2h Deep Sleep',
              accentColor: const Color(0xFFB794F4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SleepHydrationScreen(pet: pet, initialIsSleep: true)),
                );
              },
            ),

            // 6. Hydration Card
            _buildMetricTile(
              context: context,
              bgImage: 'assets/images/vet_clinical_service.jpg',
              icon: Icons.water_drop_rounded,
              label: 'Hydration',
              value: '1,200 mL',
              status: '4 / 6 bowls',
              accentColor: const Color(0xFF63B3ED),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SleepHydrationScreen(pet: pet, initialIsSleep: false)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String bgImage,
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return JumpingCard(
      enableFloating: true,
      floatAmplitude: 1.5,
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full Card Cover Background Image
              Image.asset(
                bgImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.canopy),
              ),

              // 2. High-contrast Creative Dark Vignette Gradient Overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.60),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // 3. Card Content (Compact & Legible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Glowing Icon Badge & Status Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Icon(icon, color: accentColor, size: 15),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Text(
                              status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom: Value and Label
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Colors.white54),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiHealthInsightsCard(BuildContext context, Pet pet) {
    return JumpingCard(
      enableFloating: true,
      floatAmplitude: 2.5,
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AiHealthInsightsScreen(pet: pet)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.buttercreamAccent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.canopy.withValues(alpha: 0.04),
              blurRadius: 12,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.buttercreamDark, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI HEALTH INSIGHTS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.buttercreamDark,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.buttercreamDark),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "\"${pet.name}'s daily activity improved by 14% this week. Immunization booster due in 25 days.\"",
              style: AppTypography.displaySmall.copyWith(
                fontSize: 14,
                color: AppColors.buttercreamDark,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to explore personalized AI care trends & risk analysis ➔',
              style: TextStyle(fontSize: 11, color: AppColors.buttercreamDark.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationMedicationSection(BuildContext context, Pet pet) {
    return Row(
      children: [
        // Vaccination Card
        Expanded(
          child: JumpingCard(
            enableFloating: false,
            scaleOnTap: 0.95,
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VaccinationListScreen(pet: pet)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.pistachioSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: AppColors.pistachioDark, size: 20),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.softTaupe),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Vaccinations', style: AppTypography.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('4 Protected • 1 Due', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Medication Card
        Expanded(
          child: JumpingCard(
            enableFloating: false,
            scaleOnTap: 0.95,
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MedicationListScreen(pet: pet)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTerracotta.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.medication_rounded, color: AppColors.primaryTerracotta, size: 20),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.softTaupe),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Medications', style: AppTypography.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('3 Active Courses', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCareSection(
    BuildContext context,
    Pet pet,
    List<dynamic> upcomingAppointments,
    ReminderProvider reminderProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING CARE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryTerracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Scheduled Visits & Routines', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (upcomingAppointments.isNotEmpty)
          ...upcomingAppointments.map((apt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.canopy.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppColors.canopy, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.serviceTitle, style: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${apt.clinicName} • ${DateFormat('dd MMM, hh:mm a').format(apt.dateTime)}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTerracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AppointmentDetailsScreen(appointment: apt)),
                      );
                    },
                    child: const Text('View', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded, color: AppColors.pistachioDark, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Routine Care On Schedule', style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                      Text('No urgent vet visits due this week', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHealthTimelineSection(BuildContext context, Pet pet, List<HealthRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH TIMELINE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryTerracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Clinical Event Log', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditHealthRecordScreen(petId: pet.id, petName: pet.name)),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTerracotta),
              label: const Text('Add Record', style: TextStyle(color: AppColors.primaryTerracotta, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Timeline Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTimelineFilterChip('All Records', 'all'),
              const SizedBox(width: 6),
              _buildTimelineFilterChip('💉 Vaccines', 'vaccines'),
              const SizedBox(width: 6),
              _buildTimelineFilterChip('💊 Medications', 'meds'),
              const SizedBox(width: 6),
              _buildTimelineFilterChip('🌡️ Vitals', 'vitals'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (records.isEmpty)
          _buildSampleTimeline(context, pet)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final rec = records[index];
              return _buildTimelineItem(context, pet, rec);
            },
          ),
      ],
    );
  }

  Widget _buildTimelineFilterChip(String label, String value) {
    final isSelected = _selectedTimelineFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedTimelineFilter = value),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canopy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.canopy : AppColors.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : AppColors.inkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Pet pet, HealthRecord rec) {
    return JumpingCard(
      enableFloating: false,
      scaleOnTap: 0.97,
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HealthRecordDetailsScreen(record: rec, petName: pet.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.canopy.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.canopy, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.title, style: AppTypography.labelLarge.copyWith(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${rec.veterinarianName} • ${DateFormat('dd MMM yyyy').format(rec.date)}', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.softTaupe),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTimeline(BuildContext context, Pet pet) {
    return Column(
      children: [
        _buildSampleTimelineTile(
          context: context,
          pet: pet,
          title: 'Annual DHPP Core Vaccine',
          type: 'Vaccination',
          vet: 'Dr. Ramesh Kumar, BVSc',
          date: DateTime.now().subtract(const Duration(days: 45)),
        ),
        const SizedBox(height: 10),
        _buildSampleTimelineTile(
          context: context,
          pet: pet,
          title: 'Routine Health Wellness Checkup',
          type: 'Vet Visit',
          vet: 'Dr. Priya Sharma, MVSc',
          date: DateTime.now().subtract(const Duration(days: 90)),
        ),
        const SizedBox(height: 10),
        _buildSampleTimelineTile(
          context: context,
          pet: pet,
          title: 'Himalaya Digyton Digestive Support',
          type: 'Prescription',
          vet: 'Dr. Ramesh Kumar, BVSc',
          date: DateTime.now().subtract(const Duration(days: 120)),
        ),
      ],
    );
  }

  Widget _buildSampleTimelineTile({
    required BuildContext context,
    required Pet pet,
    required String title,
    required String type,
    required String vet,
    required DateTime date,
  }) {
    final sampleRec = HealthRecord(
      id: 'sample_${title.hashCode}',
      petId: pet.id,
      type: type,
      title: title,
      description: 'Comprehensive clinical examination performed. All health observations recorded as optimal.',
      date: date,
      veterinarianName: vet,
      weightKg: 28.5,
      temperatureCelsius: 38.4,
    );

    return _buildTimelineItem(context, pet, sampleRec);
  }
}
