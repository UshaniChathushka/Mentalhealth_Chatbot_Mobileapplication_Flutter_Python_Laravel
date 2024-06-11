import 'package:flutter/material.dart';

import 'api_service.dart';

class AddFriendsPage extends StatefulWidget {
  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  late List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error fetching users: $e');
      // Handle error
    }
  }

  void _followUser(int userId) {
    ApiService.followUser(userId.toString()).then((_) {
      setState(() {
        // Assuming you want to update UI or do something after following
      });
    }).catchError((error) {
      print('Error following user: $error');
      // Handle error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 6, 38),
        title: const Text(
          'Add Friends',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color.fromARGB(255, 255, 255, 255),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 100,
      ),
      body: _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final profilePictureUrl = user['profile_picture'] != null
                    ? 'http://10.0.2.2:8000/profile_pictures/${user['profile_picture']}'
                    : null;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: profilePictureUrl != null
                        ? NetworkImage(profilePictureUrl)
                        : null,
                  ),
                  title: Text(user['username'] ?? 'No username'),
                  subtitle: Text(user['bio'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _followUser(user['id']); // Pass id as int
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 4, 3, 105), // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: const Text('Follow'),
                  ),
                );
              },
            ),
    );
  }
}
