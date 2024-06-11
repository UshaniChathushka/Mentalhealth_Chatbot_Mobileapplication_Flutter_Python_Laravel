import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import './api_service.dart';
import 'postwall.dart'; // Import post.dart file

class AddProfilePage extends StatefulWidget {
  final String email;

  const AddProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  _AddProfilePageState createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  File? _file;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      print("File path: ${result.files.single.path}");
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> saveProfile(String email) async {
    try {
      await ApiService.addProfile(
        email: email,
        profilePicture: _file,
        profilePictureFilename:
            _file != null ? _file!.path.split('/').last : null,
        username: _usernameController.text,
        fullName: _fullNameController.text,
        birthday: _birthdayController.text,
        bio: _bioController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile details saved successfully'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostWallPage(email: widget.email),
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
          'Add Profile Details',
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
                  child: _file != null
                      ? ClipOval(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_file!),
                          ),
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              const Color.fromARGB(255, 126, 122, 122),
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: pickFile,
                            color: Colors.white,
                          ),
                        ),
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
                onPressed: () => saveProfile(widget.email),
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
