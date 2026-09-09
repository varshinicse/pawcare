import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/adoption_model.dart';
import '../../models/post_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_switcher_pill.dart';
import 'adoption_details_screen.dart';
import 'adoption_listings_screen.dart';
import 'create_post_screen.dart';
import 'post_details_screen.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> {
  final _postCaptionController = TextEditingController();

  @override
  void dispose() {
    _postCaptionController.dispose();
    super.dispose();
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Share With The Pack 🐾', style: AppTypography.displaySmall),
              const SizedBox(height: 14),
              TextField(
                controller: _postCaptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share a story, milestone, photo update, or question with pet parents...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTerracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    final text = _postCaptionController.text.trim();
                    if (text.isNotEmpty) {
                      Provider.of<EcosystemProvider>(context, listen: false).createPost(text);
                      _postCaptionController.clear();
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Story posted to community clearing! 🐾'),
                          backgroundColor: AppColors.pistachioSecondary,
                        ),
                      );
                    }
                  },
                  child: const Text('Post Story'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdoptionSheet(AdoptionListing pet) {
    final contactController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adopt ${pet.petName} 🐶', style: AppTypography.displaySmall),
              const SizedBox(height: 6),
              Text('${pet.breed} • ${pet.age} • ${pet.location}', style: AppTypography.bodySmall),
              const SizedBox(height: 14),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Your Contact Phone / Email *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Living Situation / Pet Experience'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canopy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {
                    if (contactController.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Application for ${pet.petName} sent to ${pet.shelterName}! ❤️'),
                          backgroundColor: AppColors.pistachioSecondary,
                        ),
                      );
                    }
                  },
                  child: Text('Submit Adoption Request for ${pet.petName}'),
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
    final posts = ecoProvider.posts;
    final adoptions = ecoProvider.adoptions;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Scrollable Feed
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE PACK',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryTerracotta,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Community clearing', style: AppTypography.displayMedium.copyWith(fontSize: 24)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreatePostScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note_rounded, size: 16),
                          label: const Text('Share story'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTerracotta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            textStyle: AppTypography.labelLarge.copyWith(fontSize: 12.5),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stories, advice, and new beginnings from pet families nearby.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // 1. Featured Trail Story Banner
                    _buildFeaturedStoryBanner(),
                    const SizedBox(height: 20),

                    // 2. Community Stories Feed
                    _buildPostCardsList(ecoProvider, posts),
                    const SizedBox(height: 20),

                    // 3. Adoption Highlight ("Meet Milo" Banner)
                    _buildAdoptionSection(adoptions),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamBase,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.pistachioSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppColors.pistachioDark, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'The Pack',
                style: AppTypography.displaySmall.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const PetSwitcherPill(),
        ],
      ),
    );
  }

  Widget _buildFeaturedStoryBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.canopy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.45,
                child: Image.asset(
                  'assets/images/pets-community.jpg',
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
                      AppColors.canopy.withValues(alpha: 0.95),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTerracotta,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Featured trail story',
                      style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every walk tells a story.',
                    style: AppTypography.displayMedium.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bruno and Luna found their favorite sunlit path — shared by Varshini, 3 hours ago.',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCardsList(EcosystemProvider ecoProvider, List<CommunityPost> posts) {
    if (posts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.forum_outlined, size: 36, color: AppColors.softTaupe),
              const SizedBox(height: 8),
              Text('Be the first to share a story with The Pack!', style: AppTypography.bodySmall),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final post = posts[index];
        final isVet = post.ownerName.toLowerCase().contains('dr.');

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailsScreen(post: post),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.canopy.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isVet ? AppColors.pistachioSecondary : AppColors.primaryTerracotta,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        post.ownerName.isNotEmpty ? post.ownerName[0].toUpperCase() : 'P',
                        style: TextStyle(
                          color: isVet ? AppColors.pistachioDark : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.ownerName, style: AppTypography.labelLarge),
                          Text(
                            isVet ? 'Vet tip • Verified' : 'Community parent • 3h',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (isVet)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.mossLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 12, color: AppColors.pistachioDark),
                            const SizedBox(width: 4),
                            Text('Verified', style: AppTypography.labelSmall.copyWith(color: AppColors.pistachioDark, fontSize: 10)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(post.caption, style: AppTypography.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: () => ecoProvider.likePost(post.id),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: post.likes > 0 ? AppColors.alertLight : AppColors.creamSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              post.likes > 0 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: post.likes > 0 ? AppColors.alertCoral : AppColors.softTaupe,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.likes}',
                              style: AppTypography.labelSmall.copyWith(
                                color: post.likes > 0 ? AppColors.alertCoral : AppColors.inkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.creamSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.softTaupe),
                          const SizedBox(width: 6),
                          Text(
                            '${post.comments.length}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.inkText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdoptionSection(List<AdoptionListing> adoptions) {
    final pet = adoptions.isNotEmpty
        ? adoptions.first
        : AdoptionListing(
            id: 'adopt_milo',
            petName: 'Milo',
            species: 'dog',
            breed: 'Beagle puppy',
            age: '4 months',
            location: 'Koramangala Shelter, Bangalore',
            description: 'Friendly, vaccinated, and loves kids and treats.',
            shelterName: 'Koramangala Shelter',
            contactPhone: '+91 98765 43210',
          );

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
                  'LOOKING FOR A HOME',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryTerracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Meet ${pet.petName}', style: AppTypography.displaySmall.copyWith(fontSize: 20)),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdoptionListingsScreen(),
                  ),
                );
              },
              child: const Text(
                'See All ➔',
                style: TextStyle(
                  color: AppColors.primaryTerracotta,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.buttercreamAccent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.dividerColor.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.pets_rounded, color: AppColors.buttercreamDark, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pet.petName} • ${pet.breed}',
                      style: AppTypography.labelLarge.copyWith(fontSize: 15, color: AppColors.buttercreamDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pet.age} • ${pet.description}',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.buttercreamDark.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.buttercreamDark),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pet.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.copyWith(fontSize: 10.5, color: AppColors.buttercreamDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdoptionDetailsScreen(listing: pet),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.canopy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: AppTypography.labelLarge.copyWith(fontSize: 12),
                ),
                child: Text('Meet ${pet.petName}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
