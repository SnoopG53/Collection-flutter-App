import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/post.dart';
import 'new_post_activity.dart';
import 'post_detail_screen.dart';

class BrowsePostsActivity extends StatefulWidget {
  const BrowsePostsActivity({super.key});

  @override
  State<BrowsePostsActivity> createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {
  bool _showMyPostsOnly = true;

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  void _navigateToNewPost(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewPostActivity()),
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final baseQuery = FirebaseFirestore.instance.collection('posts');

    final query = _showMyPostsOnly
        ? baseQuery.where('userId', isEqualTo: currentUser?.uid)
        : baseQuery;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Posts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _showMyPostsOnly = value == 'my';
              });
            },
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Posts')),
              const PopupMenuItem(value: 'my', child: Text('My Posts')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final post = Post.fromDoc(docs[index]);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: post.imageUrls.isNotEmpty
                      ? Image.network(
                    post.imageUrls.first,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.local_offer),
                  title: Text(post.title),
                  subtitle: Text('\$${post.price} • ${post.description}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewPost(context),
        tooltip: 'Add New Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
