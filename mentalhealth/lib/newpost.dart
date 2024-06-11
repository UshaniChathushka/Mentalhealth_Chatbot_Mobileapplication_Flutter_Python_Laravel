import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';

class NewPostPage extends StatefulWidget {
  final String profilePicturePath;
  final String username;
  final String email;

  const NewPostPage({
    Key? key,
    required this.email,
    required this.profilePicturePath,
    required this.username,
  }) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  File? _postImage;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  Future<void> pickPostImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File selectedImage = File(result.files.single.path!);
      setState(() {
        _postImage = selectedImage;
      });
    }
  }

  Future<void> uploadPost() async {
    String title = _titleController.text;
    String content = _contentController.text;

    try {
      await ApiService.uploadPost(
        title: title,
        content: content,
        photo: _postImage,
      );

      // Navigate back to the PostPage after successful post upload
      Navigator.pop(context);
    } catch (e) {
      // Handle error
      print('Error uploading post: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to upload post. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 6, 38),
        toolbarHeight: 120,
        title: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add new post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'Roboto',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  uploadPost();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 11, 159),
                  shadowColor: const Color.fromARGB(0, 154, 140, 140),
                ),
                child: const Text(
                  'POST',
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.profilePicturePath),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.username,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Add Your Post Title here...',
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Say something about your post',
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
                maxLines: 3,
              ),
              const SizedBox(height: 0),
              if (_postImage != null)
                Image.file(_postImage!, fit: BoxFit.cover),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickPostImage,
                icon: const Icon(Icons.arrow_upward),
                label: const Text(
                  'Select an image',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 2, 42, 136), // Change text color here
                    fontSize: 15, // Change font size here
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 234, 234, 234), // Change button color here
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
