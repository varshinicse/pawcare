import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/care_history_model.dart';
import '../../../models/pet_model.dart';
import '../../../providers/care_history_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/date_helpers.dart';
import '../../care_history/care_activity_details_screen.dart';

class PetCareHistorySubmodule extends StatefulWidget {
  final Pet pet;

  const PetCareHistorySubmodule({super.key, required this.pet});

  @override
  State<PetCareHistorySubmodule> createState() => _PetCareHistorySubmoduleState();
}

class _PetCareHistorySubmoduleState extends State<PetCareHistorySubmodule> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareHistoryProvider>(context, listen: false)
          .fetchHistoryForPet(widget.pet.id);
    });
  }

  @override
  void didUpdateWidget(covariant PetCareHistorySubmodule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.id != widget.pet.id) {
      Provider.of<CareHistoryProvider>(context, listen: false)
          .fetchHistoryForPet(widget.pet.id);
    }
  }

  List<String> _getAvailableActivityTypes(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return ['Feeding', 'Grooming', 'Litter Cleaning', 'Medication', 'Bathing', 'Custom Activity'];
      case 'fish':
        return ['Feeding', 'Water Change', 'Tank Cleaning', 'Filter Cleaning', 'Temperature Check', 'Custom Activity'];
      case 'bird':
        return ['Feeding', 'Cage Cleaning', 'Water Replacement', 'Health Check', 'Custom Activity'];
      case 'rabbit':
        return ['Feeding', 'Cage Cleaning', 'Grooming', 'Health Check', 'Custom Activity'];
      case 'dog':
      default:
        return ['Feeding', 'Walking', 'Grooming', 'Bathing', 'Medication', 'Vaccination', 'Custom Activity'];
    }
  }

  void _showAddCareLogDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final availableTypes = _getAvailableActivityTypes(widget.pet.species);
    String selectedType = availableTypes.first;
    DateTime completedAt = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: bottomInset + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.dividerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Log Completed Care 🐾', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    Text('Record an activity completed for ${widget.pet.name}', style: AppTypography.bodySmall),
                    const SizedBox(height: 18),

                    // Activity Type
                    Text('ACTIVITY TYPE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTypes.map((type) {
                        final isSel = selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedType = type);
                          },
                          selectedColor: AppColors.clayPrimary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.inkText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? AppColors.clayPrimary : AppColors.dividerColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Activity Title
                    Text('TITLE', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Afternoon Grooming, 50% Water Change',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description / Notes
                    Text('DETAILS / NOTES (OPTIONAL)', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Notes on mood, food consumed, or condition',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mossAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim().isNotEmpty
                              ? titleController.text.trim()
                              : '$selectedType Completed';

                          final newHistory = CareHistory(
                            id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
                            petId: widget.pet.id,
                            activityType: selectedType.toLowerCase().replaceAll(' ', '_'),
                            title: title,
                            description: descController.text.trim(),
                            completedAt: completedAt,
                            createdAt: DateTime.now(),
                          );

                          await Provider.of<CareHistoryProvider>(context, listen: false)
                              .addCareHistory(newHistory);

                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Care activity logged for ${widget.pet.name}! 🐾'),
                                backgroundColor: AppColors.mossAccent,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Save to Care History'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteHistory(BuildContext context, CareHistory item) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Care Entry?'),
        content: Text('Remove "${item.title}" from care history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
            onPressed: () async {
              Navigator.of(dContext).pop();
              await Provider.of<CareHistoryProvider>(context, listen: false)
                  .deleteCareHistory(item.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<CareHistoryProvider>(context);
    final historyList = historyProvider.getHistoryForPet(widget.pet.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with info & Log Care button
          Container(
            width: double.infinity,
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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.mossLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.mossAccent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Care Timeline', style: AppTypography.displaySmall.copyWith(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        'Completed reminders automatically sync here',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _showAddCareLogDialog,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Log Care', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Completed Activities (${historyList.length})',
            style: AppTypography.displaySmall.copyWith(fontSize: 16),
          ),

          const SizedBox(height: 14),

          // Timeline or Empty State
          if (historyProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (historyList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                children: [
                  const Icon(Icons.task_alt_rounded, size: 48, color: AppColors.softTaupe),
                  const SizedBox(height: 12),
                  Text(
                    'No completed care activities yet.',
                    style: AppTypography.displaySmall.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'When you mark reminders complete in the Reminders tab or log an activity with "+ Log Care", it will appear in this chronological timeline.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historyList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = historyList[index];
                return _buildHistoryCard(context, item);
              },
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, CareHistory item) {
    final typeColor = _getActivityColor(item.activityType);
    final isFromReminder = item.reminderId != null && item.reminderId!.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CareActivityDetailsScreen(
              item: item,
              petName: widget.pet.name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Icon Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_getActivityIcon(item.activityType), color: typeColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.softTaupe),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDeleteHistory(context, item),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.description.isNotEmpty) ...[
                    Text(item.description, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.mossLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.mossAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.mossAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isFromReminder) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.creamSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'From Reminder ⏰',
                            style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.softTaupe),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${DateHelpers.formatDateShort(item.completedAt)} • ${DateHelpers.formatTime(item.completedAt)}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.softTaupe),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('feed')) return const Color(0xFFE08E45);
    if (t.contains('walk')) return AppColors.mossAccent;
    if (t.contains('groom') || t.contains('bath')) return const Color(0xFF9E64D8);
    if (t.contains('med')) return const Color(0xFF5D9CEC);
    if (t.contains('water') || t.contains('tank')) return const Color(0xFF29B6F6);
    if (t.contains('clean') || t.contains('litter') || t.contains('cage')) return const Color(0xFF26A69A);
    return AppColors.clayPrimary;
  }

  IconData _getActivityIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('feed')) return Icons.restaurant_rounded;
    if (t.contains('walk')) return Icons.directions_walk_rounded;
    if (t.contains('groom') || t.contains('bath')) return Icons.shower_rounded;
    if (t.contains('med') || t.contains('vax')) return Icons.medication_rounded;
    if (t.contains('water') || t.contains('tank')) return Icons.water_drop_rounded;
    if (t.contains('clean') || t.contains('litter') || t.contains('cage')) return Icons.cleaning_services_rounded;
    return Icons.task_alt_rounded;
  }
}
