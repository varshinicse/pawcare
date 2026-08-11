import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String ownerName;
  final String ownerAvatar;
  final String imagePath;
  final String caption;
  final int likes;
  final DateTime createdAt;
  final List<String> comments;

  CommunityPost({
    required this.id,
    required this.ownerName,
    required this.ownerAvatar,
    required this.imagePath,
    required this.caption,
    this.likes = 0,
    required this.createdAt,
    this.comments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'imagePath': imagePath,
      'caption': caption,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'comments': comments,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map, String docId) {
    return CommunityPost(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      ownerName: map['ownerName'] ?? 'Owner',
      ownerAvatar: map['ownerAvatar'] ?? '',
      imagePath: map['imagePath'] ?? '',
      caption: map['caption'] ?? '',
      likes: map['likes'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      comments: List<String>.from(map['comments'] ?? []),
    );
  }

  CommunityPost copyWith({
    String? id,
    String? ownerName,
    String? ownerAvatar,
    String? imagePath,
    String? caption,
    int? likes,
    DateTime? createdAt,
    List<String>? comments,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }
}
