import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/ecosystem_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/date_helpers.dart';

class PostDetailsScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleAddComment(EcosystemProvider provider, CommunityPost currentPost) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    provider.addComment(currentPost.id, text);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ecosystemProvider = Provider.of<EcosystemProvider>(context);
    final currentPost = ecosystemProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('Community Post 💬'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
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
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a kind comment or tip...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.softTaupe),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true,
                    fillColor: AppColors.creamSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.canopy,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: () => _handleAddComment(ecosystemProvider, currentPost),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // POST HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.canopy,
                    child: Text(
                      currentPost.ownerAvatar.isNotEmpty
                          ? currentPost.ownerAvatar
                          : currentPost.ownerName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentPost.ownerName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(DateHelpers.formatDate(currentPost.createdAt), style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.buttercreamAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Community', style: TextStyle(color: AppColors.canopy, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // POST IMAGE
            if (currentPost.imagePath.isNotEmpty)
              Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      currentPost.imagePath.contains('assets')
                          ? currentPost.imagePath
                          : 'assets/images/pets-community.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // CAPTION & ACTIONS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LIKES & COMMENTS STATS
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isLiked ? AppColors.alertCoral : AppColors.softTaupe,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() => _isLiked = !_isLiked);
                          ecosystemProvider.likePost(currentPost.id);
                        },
                      ),
                      Text(
                        '${currentPost.likes + (_isLiked ? 1 : 0)} Likes',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.mode_comment_outlined, color: AppColors.softTaupe, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${currentPost.comments.length} Comments',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // CAPTION TEXT
                  Text(
                    currentPost.caption,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 15, height: 1.5),
                  ),
                  const Divider(height: 32),

                  // COMMENTS SECTION HEADER
                  Text(
                    'Comments (${currentPost.comments.length})',
                    style: AppTypography.displaySmall.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // COMMENTS LIST
                  if (currentPost.comments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dividerColor),
                      ),
                      child: Center(
                        child: Text(
                          'No comments yet. Be the first to leave some love! 🐾',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentPost.comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final comment = currentPost.comments[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.clayLight,
                                child: const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.clayPrimary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pet Friend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(comment, style: AppTypography.bodySmall.copyWith(color: AppColors.inkText)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
