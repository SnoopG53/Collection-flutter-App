import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class NewPostActivity extends StatefulWidget {
  const NewPostActivity({super.key});

  @override
  State<NewPostActivity> createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_pickedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 4 images.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _pickedImages.add(image);
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final storage = FirebaseStorage.instance;
    final uuid = const Uuid();
    List<String> downloadUrls = [];

    for (XFile xfile in _pickedImages) {
      final file = File(xfile.path);
      final fileName = '${uuid.v4()}${path.extension(file.path)}';
      final ref = storage.ref().child('post_images').child(fileName);

      print('ploading to Firebase Storage: ${ref.fullPath}');

      try {
        final uploadTask = await ref.putFile(file);
        final url = await uploadTask.ref.getDownloadURL();
        print('Upload success, URL: $url');
        downloadUrls.add(url);
      } catch (e) {
        print('Upload failed for $fileName: $e');
        rethrow;
      }
    }

    return downloadUrls;
  }


  Future<void> _postClassified() async {
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || price.isEmpty || description.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final imageUrls = await _uploadImages();
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'price': price,
        'description': description,
        'imageUrls': imageUrls,
        'userId': user?.uid,
        'timestamp': Timestamp.now(),
      });


      Navigator.pop(context, {
        'title': title,
        'price': price,
        'description': description,
        'imageUrls': imageUrls,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildImagePreview() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _pickedImages.map((xfile) {
        return Stack(
          children: [
            Image.file(
              File(xfile.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: -6,
              right: -6,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                onPressed: () {
                  setState(() {
                    _pickedImages.remove(xfile);
                  });
                },
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Enter title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter price'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Enter description'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildImagePreview(),
            const SizedBox(height: 24),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _postClassified,
              child: const Text('POST'),
            ),
          ],
        ),
      ),
    );
  }
}
