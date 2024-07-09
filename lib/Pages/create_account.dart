import 'dart:io';
import 'package:apptweetgits/Pages/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountPage extends StatefulWidget {
  final String? email;

  const CreateAccountPage({super.key, this.email});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  TextEditingController nameController = TextEditingController();
  String? selectedDepartment;
  final List<String> departments = ['CSE', 'FT', 'RB', 'MECH', 'CE', 'EEE', 'ECE', 'ECS', 'CHE'];
  TextEditingController semesterController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    nameController.text = '';
    semesterController.text = '';
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = selectedImage;
    });
  }

  Future<void> addUserDetails() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    String? imageUrl;

    if (_imageFile != null) {
      final ref = _storage.ref().child('users/${widget.email}/profile.jpg');
      await ref.putFile(File(_imageFile!.path));
      imageUrl = await ref.getDownloadURL();
    }

    return users
        .add({
          'name': nameController.text,
          'email': widget.email,
          'department': selectedDepartment,
          'semester': semesterController.text,
          'profileImage': imageUrl,
        })
        .then((docRef) {
          print("Document written with ID: ${docRef.id}");
        })
        .catchError((error) {
          print("Error adding document: $error");
        });
  }

  void _signInWithGoogle() async {
    if (nameController.text.isEmpty ||
        selectedDepartment == null ||
        semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields')),
      );
      return;
    }

    int? semesterValue = int.tryParse(semesterController.text);

    if (semesterValue == null || semesterValue < 1 || semesterValue > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semester value must be between 1 and 8')),
      );
      return;
    }

    await addUserDetails();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // disable back button
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Create Account',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0066FF),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _imageFile!= null
                           ? FileImage(File(_imageFile!.path))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  _buildTextField('Name', 'Enter your name',
                      controller: nameController),
                  const SizedBox(height: 30.0),
                  _buildTextField('Email', widget.email?? 'Enter your Email',
                      controller: null, isEnabled: false),
                  const SizedBox(height: 30.0),
                  _buildDepartmentDropdown(),
                  const SizedBox(height: 30.0),
                  _buildTextField('Semester', 'Enter your semester',
                      controller: semesterController, isNumeric: true),

                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: SizedBox(
                      width: 327,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _signInWithGoogle,
                        child: const Text(
                          'SAVE PROFILE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {TextEditingController? controller, bool isNumeric = false, bool isEnabled = true}) {
    return SizedBox(
      width: 327,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: ShapeDecoration(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: TextFormField(
              controller: controller,
              enabled: isEnabled,
              keyboardType:
                  isNumeric ? TextInputType.number : TextInputType.text,
              inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 15),
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF0066FF)),
                  borderRadius: BorderRadius.circular(16),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return SizedBox(
      width: 327,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Department',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: ShapeDecoration(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: selectedDepartment,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                ),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                  });
                },
                items: departments.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                itemHeight: 48, // Set a fixed item height
                menuMaxHeight: 200, // Set maximum height for the dropdown menu
              ),
            ),
          ),
        ],
      ),
    );
  }
}
