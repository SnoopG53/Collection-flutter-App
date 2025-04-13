import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final String price;
  final List<String> imagePaths;
  final List<String> imageUrls;
  final String userId;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imagePaths = const [],
    this.imageUrls = const [],
    this.userId = '',
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      userId: map['userId'] ?? '',
    );
  }
}

