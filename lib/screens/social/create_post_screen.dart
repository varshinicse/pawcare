import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ecosystem_provider.dart';
import '../../providers/pet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  String _selectedCategory = '🐾 Daily Life';
  String? _selectedPetTag;
  bool _isPublishing = false;

  final List<String> _categories = [
    '🐾 Daily Life',
    '🎉 Milestone',
    '🥗 Nutrition & Treat',
    '🏃 Outdoor Adventure',
    '💡 Pet Care Tip',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a story or caption for your post.'),
          backgroundColor: AppColors.alertCoral,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    String fullCaption = caption;
    if (_selectedPetTag != null && _selectedPetTag!.isNotEmpty) {
      fullCaption = '[$_selectedCategory | with $_selectedPetTag]\n$caption';
    } else {
      fullCaption = '[$_selectedCategory]\n$caption';
    }


    await Provider.of<EcosystemProvider>(context, listen: false).createPost(fullCaption);

    if (mounted) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published to Community Feed! 🌟'),
          backgroundColor: AppColors.pistachioSecondary,
        ),
      );
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final pets = petProvider.pets;
    final userName = authProvider.userName.isNotEmpty ? authProvider.userName : 'Pet Parent';

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Share a Pet Moment 📸'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isPublishing ? null : _handlePublish,
              child: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.canopy),
                    )
                  : const Text(
                      'Share',
                      style: TextStyle(
                        color: AppColors.primaryTerracotta,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER INFO ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.canopy,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    const Text('Posting publicly in PawCare Community', style: TextStyle(color: AppColors.softTaupe, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // CATEGORY SELECTOR
            Text('TOPIC / CATEGORY', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppColors.canopy,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppColors.inkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isSel ? AppColors.canopy : AppColors.dividerColor),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // PET TAGGING
            if (pets.isNotEmpty) ...[
              Text('TAG YOUR PET', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: pets.map((p) {
                  final isSel = _selectedPetTag == p.name;
                  return FilterChip(
                    avatar: Icon(Icons.pets_rounded, size: 14, color: isSel ? Colors.white : AppColors.primaryTerracotta),
                    label: Text(p.name),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() {
                        _selectedPetTag = val ? p.name : null;
                      });
                    },
                    selectedColor: AppColors.primaryTerracotta,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.inkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isSel ? AppColors.primaryTerracotta : AppColors.dividerColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // CAPTION INPUT
            Text('YOUR STORY', style: AppTypography.labelMedium.copyWith(color: AppColors.softTaupe)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: TextField(
                controller: _captionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'What cute or exciting thing did your pet do today? Share tips, milestones, or stories with pet parents...',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // MEDIA PREVIEW ATTACHMENT
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dividerColor),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bruno-jungle.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Photo Attached', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
}
