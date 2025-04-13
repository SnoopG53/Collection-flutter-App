import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:garage_sale/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  void _openFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete images from Firebase Storage
    for (final url in post.imageUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        print("Failed to delete image: $e");
      }
    }

    // Delete Firestore post
    await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = post.imageUrls;
    final isOwner = FirebaseAuth.instance.currentUser?.uid == post.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: ListView(
        children: [
          SizedBox(
            height: 250,
            child: imageUrls.isNotEmpty
                ? PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openFullImage(context, imageUrls[index]),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
                  ),
                );
              },
            )
                : Container(
              color: Colors.grey[300],
              child: const Center(child: Text('No Images')),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  post.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
                const SizedBox(height: 20),
                Text(
                  '\$${post.price}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, color: Colors.green),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liked! (Not implemented)')),
                    );
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(post.description, style: const TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 30),

          if (isOwner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _deletePost(context),
                label: const Text('Delete Post'),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
