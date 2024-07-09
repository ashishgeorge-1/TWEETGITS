import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Adjust the import path as necessary

class GitPost {
  final String type;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;

  GitPost({required this.type, required this.content, required this.timestamp, this.imageUrl});
}

class GitPostPage extends StatefulWidget {
  const GitPostPage({super.key});

  @override
  _GitPostPageState createState() => _GitPostPageState();
}

class _GitPostPageState extends State<GitPostPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _selectedCategory; // Variable to hold the selected category
  bool _isPosting = false; // New variable to track posting state

  // Categories list
  final List<String> _categories = ['Food Corner', 'Service Corner', 'Gits Zone'];

  Future<void> _pickImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path); // Directly use the image file without compression
      });
    }
  }

  Future<void> addGit(String content, String category, BuildContext context) async {
    setState(() {
      _isPosting = true; // Start posting
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user!.uid;
      String email = user.email!;
      String? imageUrl;

      if (_imageFile != null) {
        final fileName = basename(_imageFile!.path);
        final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
        print("Image URL: $imageUrl");
      }

      await FirebaseFirestore.instance.collection('gits').add({
        'content': content,
        'authorId': userId,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl, // Ensure this is correctly included
        'category': category,
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error adding git: $e");
    } finally {
      setState(() {
        _isPosting = false; // End posting
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the keyboard is visible
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Post a Git", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              if (_imageFile != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_imageFile!), // Ensure this uses _imageFile
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text('Select Category', style: TextStyle(color: Colors.white)),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                dropdownColor: Colors.grey[900],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Write your git here...',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty && _selectedCategory != null && !_isPosting) {
                    addGit(_controller.text, _selectedCategory!, context);
                  }
                },
                child: _isPosting ? CircularProgressIndicator(color: Colors.white) : Text('Post', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0066FF),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isKeyboardVisible ? null : FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6.0,
        child: const Icon(Icons.camera_alt, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

