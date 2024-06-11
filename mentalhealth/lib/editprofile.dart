import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import './api_service.dart';
import './myprofile.dart';

class EditProfilePage extends StatefulWidget {
  final String email;

  const EditProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _profilePictureUrl;
  File? _profilePicture;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfileDetails();
  }

  Future<void> getProfileDetails() async {
    try {
      final Map<String, dynamic> profileData = await ApiService.getProfile();
      setState(() {
        _usernameController.text = profileData['username'] ?? '';
        _fullNameController.text = profileData['fullname'] ?? '';
        _birthdayController.text = profileData['birthday'] ?? '';
        _bioController.text = profileData['bio'] ?? '';
        if (profileData['profile_picture'] != null) {
          _profilePictureUrl =
              'http://10.0.2.2:8000/profile_pictures/${profileData['profile_picture']}';
        }
      });
    } catch (e) {
      print('Error fetching profile data: $e');
      // Handle error as needed
    }
  }

  Future<void> _saveProfile() async {
    try {
      await ApiService.updateProfile(
        email: widget.email,
        username: _usernameController.text,
        fullName: _fullNameController.text,
        birthday: _birthdayController.text,
        bio: _bioController.text,
        profilePicture: _profilePicture,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile details saved successfully'),
        ),
      );

      // Navigate back to MyProfilePage after saving profile details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyProfilePage(email: widget.email),
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile details. Error: $e'),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _profilePicture = File(result.files.single.path!);
      });
    }
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: const Color.fromARGB(255, 126, 122, 122),
      backgroundImage: _profilePicture != null
          ? FileImage(_profilePicture!)
          : _profilePictureUrl != null
              ? NetworkImage(_profilePictureUrl!) as ImageProvider
              : null,
      child: IconButton(
        icon: const Icon(Icons.add_a_photo),
        onPressed: _pickFile,
        color: Colors.white,
      ),
    );
  }

  Widget _buildEditableProfileItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 6, 38),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: const Color.fromARGB(255, 1, 6, 38),
                  height: 180,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _buildProfilePicture(),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildEditableProfileItem('Username', _usernameController),
            _buildEditableProfileItem('Full Name', _fullNameController),
            _buildEditableProfileItem('Birthday', _birthdayController),
            _buildEditableProfileItem('Bio', _bioController),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 3, 123, 252),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
