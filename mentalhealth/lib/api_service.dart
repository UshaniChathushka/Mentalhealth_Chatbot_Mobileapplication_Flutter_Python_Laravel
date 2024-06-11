import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<String> signUp({
    required String email,
    required String password,
    required String name,
    required String password_confirmation,
  }) async {
    final url = Uri.parse('$baseUrl/api/register');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
        'name': name,
        'password_confirmation': password_confirmation
      },
    );

    if (response.statusCode == 200) {
      // Extract token from response
      final responseData = json.decode(response.body);
      final String token = responseData['token'];

      // Store token in SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);

      return token; // Return token
    } else {
      throw Exception('Signup failed');
    }
  }

  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/api/verifyOtp');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode == 200) {
      // OTP verification successful
      print('OTP verification successful');
    } else {
      // OTP verification failed
      final errorMessage = json.decode(response.body)['message'];
      throw Exception('OTP verification failed: $errorMessage');
    }
  }

  static Future<void> addProfile({
    required String email,
    required String username,
    required String fullName,
    required String birthday,
    required String bio,
    File? profilePicture,
    String? profilePictureFilename,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/addProfile');
      final request = http.MultipartRequest('POST', url);
      request.fields['email'] = email;
      request.fields['username'] = username;
      request.fields['fullname'] = fullName;
      request.fields['birthday'] = birthday;
      request.fields['bio'] = bio;
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
          filename: profilePicture.path.split('/').last,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Profile details added successfully');
      } else {
        final errorMessage = await response.stream.bytesToString();
        throw Exception('Failed to add profile: $errorMessage');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      throw Exception('Failed to add profile: $e');
    }
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/login');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
        'device_name': 'mobile',
      },
    );

    if (response.statusCode == 200) {
      // Login successful
      print('Login successful');
      final responseData = json.decode(response.body);
      final String token = responseData['token'];
      return token;
    } else {
      // Login failed
      throw Exception('Login failed: Incorrect email or password');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      // Token not found, handle this case accordingly
      throw Exception('Token not found');
    }

    final url = Uri.parse('$baseUrl/api/getProfile');
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Profile details fetched successfully
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      // Failed to fetch profile details
      throw Exception('Failed to fetch profile details');
    }
  }

  // Inside ApiService class in api_service.dart

  static Future<void> updateProfile({
    required String email,
    String? username,
    String? fullName,
    String? birthday,
    String? bio,
    File? profilePicture,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/api/updateProfile');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields that are modified to the request
      if (username != null) {
        request.fields['username'] = username;
      }
      if (fullName != null) {
        request.fields['fullname'] = fullName;
      }
      if (birthday != null) {
        request.fields['birthday'] = birthday;
      }
      if (bio != null) {
        request.fields['bio'] = bio;
      }
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
          filename: profilePicture.path.split('/').last,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Profile details updated successfully');
      } else {
        final errorMessage = await response.stream.bytesToString();
        throw Exception('Failed to update profile: $errorMessage');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> uploadPost({
    required String title,
    required String content,
    File? photo,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/api/newPost');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Add post details to the request
      request.fields['title'] = title;
      request.fields['content'] = content;

      // Add photo if available
      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          filename: photo.path.split('/').last,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Post uploaded successfully');
      } else {
        final errorMessage = await response.stream.bytesToString();
        throw Exception('Failed to upload post: $errorMessage');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to upload post: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllPosts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('$baseUrl/api/all-posts');
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> postsData = responseData['posts']['data'];

      List<Map<String, dynamic>> posts = [];
      for (var postData in postsData) {
        posts.add({
          'id': postData['id'],
          'title': postData['title'],
          'content': postData['content'],
          'created_at': postData['created_at'],
          'photo': postData['photo'],
          'user': postData['user'],
        });
      }
      return posts;
    } else {
      throw Exception('Failed to fetch all posts');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/api/getAllUsers');

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['users'];

        List<Map<String, dynamic>> users = [];
        for (var userData in responseData) {
          users.add({
            'id': userData['id'], // Include the user ID
            'username': userData['username'],
            'profile_picture': userData['profile_picture'],
            'bio': userData['bio'],
            // Add other fields if needed
          });
        }
        return users;
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in getAllUsers: $e');
    }
  }

  static Future<void> followUser(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/api/followUser');
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        print('User followed successfully');
      } else {
        final errorMessage = json.decode(response.body)['message'];
        throw Exception('Failed to follow user: $errorMessage');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to follow user: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowedUsersPosts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final url = Uri.parse('$baseUrl/api/followedUsersPosts');
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> postsData = responseData['posts']['data'];

        List<Map<String, dynamic>> posts = [];
        for (var postData in postsData) {
          final Map<String, dynamic> user = postData['user'];
          posts.add({
            'id': postData['id'],
            'title': postData['title'],
            'content': postData['content'],
            'created_at': postData['created_at'],
            'photo': postData['photo'],
            'user': {
              'username': user['username'],
              'profile_picture': user['profile_picture'],
            },
          });
        }
        return posts;
      } else {
        throw Exception('Failed to fetch followed users posts');
      }
    } catch (e) {
      throw Exception('Error in getFollowedUsersPosts: $e');
    }
  }

  static Future<void> deletePost(int postId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      // Construct the URL for the DELETE request, including the post ID
      final url = Uri.parse('$baseUrl/api/deletePost/$postId');

      // Make the DELETE request
      final response = await http.delete(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Post deleted successfully
        print('Post deleted successfully');
      } else {
        // Failed to delete the post
        final errorMessage = json.decode(response.body)['message'];
        throw Exception('Failed to delete post: $errorMessage');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      throw Exception('Failed to delete post: $e');
    }
  }

  static Future<int> likePost(int postId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('$baseUrl/api/like/$postId');
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      // Like was successful
      final responseData = json.decode(response.body);
      final int likeCount = responseData['likeCount'];
      return likeCount;
    } else {
      final errorMessage = json.decode(response.body)['message'];
      throw Exception('Failed to like post: $errorMessage');
    }
  }

  static Future<Map<String, dynamic>> addComment({
    required int postId,
    required String comment,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('$baseUrl/api/comment/$postId');
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: {
        'comment': comment,
      },
    );

    // Check response status code
    if (response.statusCode == 201) {
      // Parse the response body
      final responseData = json.decode(response.body);

      // Check for the 'comment' key
      if (responseData.containsKey('comment')) {
        final Map<String, dynamic> comment = responseData['comment'];
        return comment;
      } else {
        throw Exception('Unexpected response format: Missing comment');
      }
    } else {
      // Parse error message from the response body
      final errorMessage = json.decode(response.body)['message'];
      throw Exception('Failed to add comment: $errorMessage');
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(int postId) async {
    final url = Uri.parse('$baseUrl/api/comments/$postId');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorMessage = json.decode(response.body)['message'];
      throw Exception('Failed to fetch comments: $errorMessage');
    }

    final responseData = json.decode(response.body);
    return List<Map<String, dynamic>>.from(responseData);
  }

  static Future<int> getLikeCount(int postId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('$baseUrl/api/post/$postId/like-count');
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final int likeCount = responseData['like_count'];
      return likeCount;
    } else {
      final errorMessage = json.decode(response.body)['message'];
      throw Exception('Failed to fetch like count: $errorMessage');
    }
  }

  static Future<void> newpassword({
    required String email,
    required String newpassword,
  }) async {
    final url = Uri.parse('$baseUrl/api/newpassword');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'newpassword': newpassword,
      },
    );

    if (response.statusCode == 200) {
      print('Password reset successfully');
    } else {
      // Handle errors and provide feedback to the user
      final errorData = json.decode(response.body);
      throw Exception('Failed to reset password: ${errorData['message']}');
    }
  }
}
