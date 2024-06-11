import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './chat.dart';
import './comment_page.dart';
import './myprofile.dart';
import 'add_friends.dart';
import 'api_service.dart';
import 'newpost.dart';

class PostWallPage extends StatefulWidget {
  final String email;

  PostWallPage({required this.email});

  @override
  _PostWallPageState createState() => _PostWallPageState();
}

class _PostWallPageState extends State<PostWallPage> {
  String? _profilePictureUrl;
  Map<String, dynamic> _profileData = {};
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _followedUsersPosts = [];

  // State variables for likes and comments
  Map<int, int> _likesCount = {};
  Map<int, bool> _isLiked = {};
  Map<int, List<Map<String, dynamic>>> _comments = {};

  @override
  void initState() {
    super.initState();
    _fetchProfileInfo();
    _fetchUserPosts();
    _fetchFollowedUsersPosts();
  }

  Future<void> _fetchProfileInfo() async {
    try {
      final profileData = await ApiService.getProfile();
      setState(() {
        _profileData = profileData;
        if (_profileData['profile_picture'] != null) {
          _profilePictureUrl =
              'http://10.0.2.2:8000/profile_pictures/${_profileData['profile_picture']}';
        }
      });
    } catch (e) {
      print('Error fetching profile information: $e');
    }
  }

  Future<void> _fetchUserPosts() async {
    try {
      final userPosts = await ApiService.getAllPosts();
      setState(() {
        _userPosts = userPosts;
        for (var post in userPosts) {
          int postId = post['id'];
          // Initialize state variables
          _likesCount[postId] = 0;
          _isLiked[postId] = false;
          _comments[postId] = post['comments'] ?? [];
        }
      });

      // Fetch the like count for each post
      for (var post in userPosts) {
        int postId = post['id'];
        int likeCount = await ApiService.getLikeCount(postId);
        setState(() {
          _likesCount[postId] = likeCount;
        });
      }
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }

  Future<void> _fetchFollowedUsersPosts() async {
    try {
      final followedUsersPosts = await ApiService.getFollowedUsersPosts();
      setState(() {
        _followedUsersPosts = followedUsersPosts;
        for (var post in followedUsersPosts) {
          int postId = post['id'];
          // Initialize state variables
          _likesCount[postId] = 0;
          _isLiked[postId] = false;
          _comments[postId] = post['comments'] ?? [];
        }
      });

      // Fetch the like count for each post
      for (var post in followedUsersPosts) {
        int postId = post['id'];
        int likeCount = await ApiService.getLikeCount(postId);
        setState(() {
          _likesCount[postId] = likeCount;
        });
      }
    } catch (e) {
      print('Error fetching followed users posts: $e');
    }
  }

  void _handleLikeButtonPress(int postId) async {
    try {
      // Try to like the post and get the new like count
      int likeCount = await ApiService.likePost(postId);
      setState(() {
        _likesCount[postId] = likeCount;
        _isLiked[postId] = !_isLiked[postId]!;
      });
    } catch (e) {
      if (e.toString().contains("You have already liked this post")) {
        setState(() {
          _isLiked[postId] = true;
        });
      } else {
        print('Error liking post: $e');
      }
    }
  }

  void _handleCommentButtonPress(int postId) {
    // Search for the selected post in user posts
    Map<String, dynamic> selectedPost = _userPosts.firstWhere(
      (post) => post['id'] == postId,
      orElse: () => <String, dynamic>{},
    );

    // If the post wasn't found in user posts, search in followed users' posts
    if (selectedPost.isEmpty) {
      selectedPost = _followedUsersPosts.firstWhere(
        (post) => post['id'] == postId,
        orElse: () => <String, dynamic>{},
      );
    }

    // If the post was found, navigate to the comment page
    if (selectedPost.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostCommentsPage(
            post: selectedPost,
            postId: postId,
          ),
        ),
      );
    } else {
      // Handle the case where no post was found (optional)
      print('Post with ID $postId not found');
    }
  }

  Widget _buildPostItem(
    Map<String, dynamic> post,
    String profilePictureUrl,
    String username,
  ) {
    int postId = post['id'];
    int likesCount = _likesCount[postId] ?? 0;
    bool isLiked = _isLiked[postId] ?? false;
    List<Map<String, dynamic>> comments = _comments[postId] ?? [];

    return FutureBuilder<int>(
      future: ApiService.getLikeCount(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Failed to fetch like count'));
        } else {
          likesCount = snapshot.data ?? 0;
          _likesCount[postId] = likesCount; // Update likes count in state

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                      backgroundImage: NetworkImage(profilePictureUrl),
                      radius: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 10),
                if (post['photo'] != null)
                  _loadPostImage('http://10.0.2.2:8000/posts/${post['photo']}'),
                const SizedBox(height: 10),
                Text(
                  'Posted on: ${post['created_at']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align children to the start
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _handleLikeButtonPress(postId),
                    ),
                    // Add a smaller space between the like button and like count
                    const SizedBox(width: 5),
                    Text('$likesCount',
                        style: const TextStyle(
                            fontSize: 16)), // Display the updated like count
                    const Spacer(), // Fill remaining space to push the comment button to the end
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.comment,
                        color: Color.fromARGB(255, 6, 140,
                            213), // Set your desired color // Use the desired color, // Your desired color
                      ),
                      onPressed: () => _handleCommentButtonPress(postId),
                    ),
                  ],
                ),

                // Display comments for the post
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((comment) {
                    return ListTile(
                      title: Text(comment['comment']),
                      subtitle: Text('By user ID: ${comment['user_id']}'),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 6, 38),
          title: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              'D O R A',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'CrimsonText',
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 20),
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Handle menu button tap
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Place the BottomAppBar directly after the AppBar
          BottomAppBar(
            height: 60,
            color: Color.fromARGB(255, 0, 1,
                33), // Set navigation bar color as desired (current dark blue)
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home icon at the beginning
                IconButton(
                  icon: const Icon(Icons.home_outlined,
                      color: Colors.white), // Set icon color as needed
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          nickname: '',
                          email: '',
                        ),
                      ),
                    );
                  },
                  iconSize: 30,
                ),
                // Add Friends icon in the middle
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white), // Set icon color as needed
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
                // Profile icon at the end
                IconButton(
                  icon: const Icon(Icons.person_outline,
                      color: Colors.white), // Set icon color as needed
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyProfilePage(
                          email: '',
                        ),
                      ),
                    );
                  },
                  iconSize: 28,
                ),
              ],
            ),
          ),

          // Remaining widgets
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 90,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewPostPage(
                            email: widget.email,
                            profilePicturePath: _profilePictureUrl ?? '',
                            username: _profileData['username'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Share your posts here',
                              style: TextStyle(
                                color: Color.fromARGB(255, 136, 135, 135),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.photo_library,
                              color: Color.fromARGB(255, 6, 31, 124),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 20,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // Handle profile picture tap
                      },
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 2.0,
                          ),
                          image: _profilePictureUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_profilePictureUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 80,
                    left: 2,
                    right: 2,
                    bottom: 40,
                    child: (_userPosts.isEmpty && _followedUsersPosts.isEmpty)
                        ? const Center(child: Text('No posts available'))
                        : ListView.builder(
                            itemCount:
                                _userPosts.length + _followedUsersPosts.length,
                            itemBuilder: (context, index) {
                              // Reverse the lists to display the most recent posts first
                              final reversedUserPosts =
                                  _userPosts.reversed.toList();
                              final reversedFollowedUsersPosts =
                                  _followedUsersPosts.reversed.toList();

                              if (index < reversedUserPosts.length) {
                                final post = reversedUserPosts[index];
                                return _buildPostItem(
                                  post,
                                  _profilePictureUrl ?? '',
                                  _profileData['username'] ?? '',
                                );
                              } else {
                                final followedPostIndex =
                                    index - reversedUserPosts.length;
                                final followedPost = reversedFollowedUsersPosts[
                                    followedPostIndex];
                                return _buildPostItem(
                                  followedPost,
                                  'http://10.0.2.2:8000/profile_pictures/${followedPost['user']['profile_picture']}',
                                  followedPost['user']['username'],
                                );
                              }
                            },
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
