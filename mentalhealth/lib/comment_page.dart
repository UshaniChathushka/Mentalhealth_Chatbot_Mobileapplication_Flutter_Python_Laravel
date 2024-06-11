import 'package:flutter/material.dart';

import 'api_service.dart';

class PostCommentsPage extends StatefulWidget {
  final Map<String, dynamic> post;

  PostCommentsPage({required this.post, required int postId});

  @override
  _PostCommentsPageState createState() => _PostCommentsPageState();
}

class _PostCommentsPageState extends State<PostCommentsPage> {
  List<Map<String, dynamic>> _comments = [];
  String _newComment = '';
  bool isLoading = false;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await ApiService.getComments(widget.post['id']);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      _showError('Error fetching comments: $e');
    }
  }

  Future<void> _handleAddComment() async {
    if (_newComment.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });

        await ApiService.addComment(
          postId: widget.post['id'],
          comment: _newComment,
        );

        await _fetchComments();

        setState(() {
          _newComment = '';
          isLoading = false;
          _commentController.clear();
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        _showError('Failed to add comment: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 9, 48),
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'Add the comment',
            style: TextStyle(
              fontSize: 24.0,
              fontFamily: 'Roboto',
              color: Colors.white,
            ),
          ),
        ),
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (post['user'] != null &&
                        post['user']['profile_picture'] != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          'http://10.0.2.2:8000/profile_pictures/${post['user']['profile_picture']}',
                        ),
                        radius: 25,
                      ),
                    const SizedBox(width: 10),
                    if (post['user'] != null)
                      Text(
                        post['user']['username'],
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post['content'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (post['photo'] != null)
                  Image.network(
                    'http://10.0.2.2:8000/posts/${post['photo']}',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final user = comment['user'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null && user['profile_picture'] != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            'http://10.0.2.2:8000/profile_pictures/${user['profile_picture']}',
                          ),
                          radius: 20,
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user != null)
                              Text(
                                user['username'],
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            Text(
                              comment['comment'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    onChanged: (value) {
                      _newComment = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _handleAddComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
