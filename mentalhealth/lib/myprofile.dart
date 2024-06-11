import 'package:flutter/material.dart';

import '/api_service.dart';
import 'add_friends.dart';
import 'chat.dart';
import 'editprofile.dart';
import 'postwall.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late Future<Map<String, dynamic>> _profileDetailsFuture;
  late Future<List<Map<String, dynamic>>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    _profileDetailsFuture = _fetchProfileDetails();
    _userPostsFuture = _fetchUserPosts();
  }

  Future<Map<String, dynamic>> _fetchProfileDetails() async {
    try {
      final profileDetails = await ApiService.getProfile();
      return profileDetails;
    } catch (e) {
      print('Error fetching profile details: $e');
      throw Exception('Failed to fetch profile details');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserPosts() async {
    try {
      final userPosts = await ApiService.getAllPosts();
      return userPosts;
    } catch (e) {
      print('Error fetching user posts: $e');
      throw Exception('Failed to fetch user posts');
    }
  }

  // Method to delete a post
  Future<void> _deletePost(int postId) async {
    try {
      // Call the API service to delete the post.
      await ApiService.deletePost(postId);
      // Refresh the user posts after deletion.
      setState(() {
        _userPostsFuture = _fetchUserPosts();
      });
    } catch (e) {
      print('Error deleting post: $e');
    }
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
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostWallPage(email: widget.email),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(email: widget.email),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60), // Set the height of the bottom section
          child: Container(
            color: const Color.fromARGB(255, 1, 6, 38), // Dark blue color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home icon at the beginning
                IconButton(
                  icon: const Icon(Icons.home_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(nickname: '', email: ''),
                      ),
                    );
                  },
                  iconSize: 30,
                ),
                // Add Friends icon in the middle
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriendsPage(),
                      ),
                    );
                  },
                  iconSize: 28,
                ),
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostWallPage(email: widget.email),
                      ),
                    );
                  },
                  iconSize: 28,
                ),
                // Profile icon at the end
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () {
                    // Handle Profile button tap
                  },
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  // Method to build the body of the page
  Widget _buildBody(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDetailsFuture,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (profileSnapshot.hasError) {
          return const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color.fromARGB(255, 126, 122, 122),
              child: Icon(Icons.error_outline, color: Colors.white, size: 40),
            ),
          );
        } else {
          final profileDetails = profileSnapshot.data!;
          final profilePictureName = profileDetails['profile_picture'];

          // Safe handling of profile picture URL, allowing for null or empty values
          final profilePictureUrl =
              profilePictureName != null && profilePictureName.isNotEmpty
                  ? 'http://10.0.2.2:8000/profile_pictures/$profilePictureName'
                  : null;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _userPostsFuture,
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (postSnapshot.hasError) {
                return const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color.fromARGB(255, 126, 122, 122),
                    child: Icon(Icons.error_outline,
                        color: Colors.white, size: 40),
                  ),
                );
              } else {
                final userPosts = postSnapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile picture and name section
                      Container(
                        width: 460,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 3, 3, 51), // Dark blue
                              Color.fromARGB(255, 4, 1, 30), // Black
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 8.0, left: 40.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  const Color.fromARGB(255, 126, 122, 122),
                              backgroundImage: profilePictureUrl != null
                                  ? NetworkImage(profilePictureUrl)
                                  : null,
                              child: profilePictureUrl == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white, size: 60)
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              profileDetails['username'],
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                      _buildInfoContainer(
                        icon: Icons.person,
                        label: 'Full Name',
                        value: profileDetails['fullname'] ?? '',
                      ),
                      const SizedBox(height: 0),
                      _buildInfoContainer(
                        icon: Icons.cake,
                        label: 'Birthday',
                        value: profileDetails['birthday'] ?? '',
                      ),
                      const SizedBox(height: 0),
                      _buildInfoContainer(
                        icon: Icons.info,
                        label: 'Bio',
                        value: profileDetails['bio'] ?? '',
                      ),
                      const SizedBox(height: 40),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          final postPictureUrl = post['photo'] != null
                              ? 'http://10.0.2.2:8000/posts/${post['photo']}'
                              : null;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: profilePictureUrl != null
                                          ? NetworkImage(profilePictureUrl)
                                          : null,
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      profileDetails['username'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Spacer(), // Add space between text and delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        // Show confirmation dialog when delete icon is pressed
                                        final bool confirmed = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Delete Post'),
                                              content: const Text(
                                                  'Are you sure you want to delete this post?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmed) {
                                          // If the user confirms deletion, delete the post.
                                          await _deletePost(post['id']);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  post['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  post['content'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (post['photo'] != null)
                                  _loadPostImage(postPictureUrl!),
                                const SizedBox(height: 10),
                                Text(
                                  'Posted on: ${post['created_at']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  // Method to build info containers
  Widget _buildInfoContainer({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 30,
            color: Color.fromARGB(255, 0, 23, 100),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to load post image safely
  Widget _loadPostImage(String imageUrl) {
    return SizedBox(
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain, // Maintain the aspect ratio
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 200,
            width: double.infinity,
            child: Center(
              child: Text('Image not available'),
            ),
          );
        },
      ),
    );
  }
}
