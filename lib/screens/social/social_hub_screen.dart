import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lost_pet_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentControllers = <String, TextEditingController>{};
  final _lostNameController = TextEditingController();
  final _lostLocationController = TextEditingController();
  final _lostContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentControllers.forEach((_, c) => c.dispose());
    _lostNameController.dispose();
    _lostLocationController.dispose();
    _lostContactController.dispose();
    super.dispose();
  }

  TextEditingController _getCommentController(String postId) {
    return _commentControllers.putIfAbsent(postId, () => TextEditingController());
  }

  void _addLostPet() {
    if (_lostNameController.text.isEmpty || _lostLocationController.text.isEmpty) return;

    final alert = LostPetAlert(
      id: 'lost_${DateTime.now().millisecondsSinceEpoch}',
      petName: _lostNameController.text,
      species: 'dog',
      breed: 'Mixed',
      lastSeenLocation: _lostLocationController.text,
      dateLost: DateTime.now(),
      contactNumber: _lostContactController.text,
    );

    Provider.of<EcosystemProvider>(context, listen: false).reportLostPet(alert);
    _lostNameController.clear();
    _lostLocationController.clear();
    _lostContactController.clear();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lost pet alert broadcasted successfully! 🚨'),
        backgroundColor: AppColors.alertCoral,
      ),
    );
  }

  void _showReportLostSheet() {
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
              Text('Report Lost Pet 🚨', style: AppTypography.displaySmall),
              const SizedBox(height: 14),
              TextField(
                controller: _lostNameController,
                decoration: const InputDecoration(labelText: 'Pet Name'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _lostLocationController,
                decoration: const InputDecoration(labelText: 'Last Seen Location'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _lostContactController,
                decoration: const InputDecoration(labelText: 'Contact Owner Phone'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
                  onPressed: _addLostPet,
                  child: const Text('Broadcast SOS Alert'),
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

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Community Hub 🐾'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.clayPrimary,
          unselectedLabelColor: AppColors.softTaupe,
          indicatorColor: AppColors.clayPrimary,
          tabs: const [
            Tab(text: 'COMMUNITY'),
            Tab(text: 'ADOPTIONS'),
            Tab(text: 'LOST & FOUND'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(ecoProvider),
          _buildAdoptionsTab(ecoProvider),
          _buildLostTab(ecoProvider),
        ],
      ),
    );
  }

  Widget _buildFeedTab(EcosystemProvider ecoProvider) {
    final posts = ecoProvider.posts;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final controller = _getCommentController(post.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.clayLight,
                    child: Text(post.ownerAvatar, style: AppTypography.labelLarge.copyWith(color: AppColors.clayPrimary)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.ownerName, style: AppTypography.labelLarge),
                      Text(DateHelpers.formatDateShort(post.createdAt), style: AppTypography.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.caption, style: AppTypography.bodyMedium),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => ecoProvider.likePost(post.id),
                    icon: const Icon(Icons.favorite_rounded, color: AppColors.alertCoral, size: 20),
                    label: Text('${post.likes} Likes', style: AppTypography.labelMedium.copyWith(color: AppColors.alertCoral)),
                  ),
                  Text('${post.comments.length} Comments', style: AppTypography.labelMedium),
                ],
              ),
              const Divider(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post.comments.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $c', style: AppTypography.bodySmall),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Add comment...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ecoProvider.addComment(post.id, controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.send_rounded, color: AppColors.clayPrimary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdoptionsTab(EcosystemProvider ecoProvider) {
    final listings = ecoProvider.adoptions;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final pet = listings[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pet.petName, style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.mossLight, borderRadius: BorderRadius.circular(14)),
                    child: Text(pet.age, style: AppTypography.labelMedium.copyWith(color: AppColors.mossAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${pet.breed} • ${pet.species.toUpperCase()}', style: AppTypography.bodySmall),
              const SizedBox(height: 10),
              Text(pet.description, style: AppTypography.bodyMedium),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pet.shelterName, style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text('Contact Shelter'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLostTab(EcosystemProvider ecoProvider) {
    final lostList = ecoProvider.lostPets;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.alertCoral,
        foregroundColor: Colors.white,
        onPressed: _showReportLostSheet,
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Report Lost Pet'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: lostList.length,
        itemBuilder: (context, index) {
          final alert = lostList[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.alertLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.alertCoral.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SOS: Lost ${alert.petName}', style: AppTypography.displaySmall.copyWith(fontSize: 18, color: AppColors.alertCoral)),
                    const Icon(Icons.warning_rounded, color: AppColors.alertCoral),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Last Seen: ${alert.lastSeenLocation}', style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text('Date Lost: ${DateHelpers.formatDateShort(alert.dateLost)}', style: AppTypography.bodySmall),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCoral),
                        onPressed: () {},
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: const Text('Contact Owner'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
