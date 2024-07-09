import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MyProfilePage extends StatefulWidget {
  final Function(String)? onProfileImageUpdated;

  const MyProfilePage({super.key, this.onProfileImageUpdated});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController semesterController = TextEditingController();
  TextEditingController bioController = TextEditingController(); // Controller for bio
  Map<String, dynamic>? userDocument;
  String? selectedDepartment; // For dropdown
  final List<String> departments = ['CSE', 'FT', 'RB', 'MECH', 'CE', 'EEE', 'ECE', 'ECS', 'CHE']; // Department list

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email; // Get the email of the logged-in user

    // Check if the user is not null and email is not null
    if (user == null || userEmail == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user logged in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      appBar: AppBar(
        backgroundColor: Colors.black, // Set AppBar background to black
        title: Text('Profile', style: TextStyle(color: Colors.white)), // Set text color to white
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set icon color to white
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white), // Edit profile icon
            onPressed: () {
              _editProfile(context, userDocument!); // Assuming userDocument is available here
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail) // Use the user's email dynamically
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No user found with that email", style: TextStyle(color: Colors.white)));
          }
          userDocument = snapshot.data!.docs.first.data() as Map<String, dynamic>; // Update the class-level variable
          nameController.text = userDocument!['name'];
          departmentController.text = userDocument!['department'];
          semesterController.text = userDocument!['semester'];
          bioController.text = userDocument!['bio'] ?? ''; // Initialize bio controller
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      ClipOval(
                        child: Image.network(
                          userDocument!['profileImage'] ?? 'assets/default_profile_image.jpg',
                          width: 170, // Set the width to the desired size
                          height: 170, // Set the height to the desired size
                          fit: BoxFit.contain, // Adjusts the fit to contain the image within the frame
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(1), // Reduced padding for a smaller background
                        decoration: BoxDecoration(
                          color: Color(0xFF0066FF), // Background color
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 16), // Icon size reduced to 16
                          onPressed: () async {
                            File? imageFile = await _pickImageFromGallery();
                            if (imageFile != null) {
                              _updateProfile(userDocument!['email'], imageFile);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  userDocument!['name'] ?? 'No Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Set text color to white
                ),
                Text(
                  userDocument!['email'] ?? 'No Email',
                  style: TextStyle(fontSize: 16, color: Color(0xFF0066FF)), // Set text color to 0xFF0066FF
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0), // Adjust left padding for 'Department'
                        child: Text(
                          'Department: ${userDocument!['department'] ?? 'Not Available'}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 75.0, top: 8.0, bottom: 8.0), // Adjust right padding for 'Semester'
                        child: Text(
                          'Semester: ${userDocument!['semester'] ?? 'Not Available'}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300]), // Added Divider here
                ListTile(
                  title: Text(
                    'ABOUT',
                    style: TextStyle(
                      color: Color(0xFF0066FF), // Set the font color to 0xFF0066FF
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    userDocument!['bio'] ?? 'No Bio',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ),
                Divider(color: Colors.grey[300]), // Divider after About
                _buildUserPostsSection(userEmail), // New section for Tweets and Images
              ],
            ),
          );
        },
      ),
    );
  }

  void _editProfile(BuildContext context, Map<String, dynamic> userDocument) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Edit Profile', 
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                DropdownButtonFormField<String>(
                  value: selectedDepartment ?? userDocument['department'],
                  items: departments.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedDepartment = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Department',
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                ),
                TextField(
                  controller: semesterController,
                  decoration: InputDecoration(
                    labelText: 'Semester',
                    labelStyle: const TextStyle(color: Colors.white),
                    errorText: validateSemester(semesterController.text),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(
                    labelText: 'About',
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                String? validationMessage = validateSemester(semesterController.text);
                if (validationMessage == null) {
                  Navigator.of(context).pop();
                  _updateProfile(userDocument['email']);
                } else {
                  // Show a SnackBar if validation fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(validationMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String? validateSemester(String value) {
    if (value.isEmpty) {
      return 'Semester cannot be empty';
    }
    int? semester = int.tryParse(value);
    if (semester == null) {
      return 'Enter a valid number';
    }
    if (semester <= 0) {
      return 'Semester cannot be zero';
    }
    if (semester > 8) {
      return 'Semester cannot be greater than 8';
    }
    return null;
  }

  void _updateProfile(String email, [File? imageFile]) {
    var usersCollection = FirebaseFirestore.instance.collection('users');
    usersCollection.where('email', isEqualTo: email).get().then((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;

        // Upload image and get URL if imageFile is not null
        String imageUrl = imageFile != null ? await _uploadImageAndGetUrl(imageFile, email) : userDocument!['profileImage'];

        // Update Firestore document
        docRef.update({
          'name': nameController.text,
          'department': selectedDepartment ?? departmentController.text,
          'semester': semesterController.text,
          'bio': bioController.text,
          'profileImage': imageUrl, // Use existing or updated profile image URL
        }).then((value) {
          print("Profile Updated");
          if (widget.onProfileImageUpdated != null) {
            widget.onProfileImageUpdated!(imageUrl);
          }
        }).catchError((error) {
          print("Failed to update profile: $error");
        });
      } else {
        print("No document found for email: $email");
      }
    }).catchError((error) {
      print("Error querying document by email: $error");
    });
  }

  Future<String> _uploadImageAndGetUrl(File imageFile, String email) async {
    String filePath = 'profile_images/$email/${DateTime.now().millisecondsSinceEpoch}';
    Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<File?> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Widget _buildUserPostsSection(String userEmail) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gits')
          .where('email', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error loading posts: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No posts found");
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'POSTS',
                style: TextStyle(
                  color: Color(0xFF0066FF), // Set the font color to 0xFF0066FF
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.separated(
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var post = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                var postId = snapshot.data!.docs[index].id;
                DateTime postDate = (post['timestamp'] as Timestamp).toDate();
                return ListTile(
                  title: Text(post['content'], style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post['imageUrl'] != null)
                        Image.network(post['imageUrl']),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(postDate),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showPostOptions(context, postId),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, String postId) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
            return SafeArea(
                child: Wrap(
                    children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete Post'),
                            onTap: () {
                                _deletePost(postId);
                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                ),
            );
        }
    );
  }

  void _deletePost(String postId) {
    FirebaseFirestore.instance.collection('gits').doc(postId).delete().then((_) {
        print("Post deleted successfully");
    }).catchError((error) {
        print("Error deleting post: $error");
    });
  }
}

