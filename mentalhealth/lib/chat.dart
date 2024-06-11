import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './login.dart';
import './myprofile.dart';
import './postwall.dart';

class Chat extends StatefulWidget {
  final String nickname;
  final String email;

  const Chat({Key? key, required this.nickname, required this.email})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> chatHistory = [];

  // Function to check if the user is logged in
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Navigate to MyProfile page if the user is logged in
  Future<void> goToMyProfile() async {
    if (await isLoggedIn()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyProfilePage(email: widget.email),
        ),
      );
    } else {
      // User is not logged in, show a message and navigate to LoginPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please log in first to access your profile.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // Navigate to PostWall page if the user is logged in
  Future<void> goToPostWall() async {
    if (await isLoggedIn()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostWallPage(email: widget.email),
        ),
      );
    } else {
      // User is not logged in, show a message and navigate to LoginPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to access posts.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> sendMessage() async {
    String userInput = _controller.text;
    if (userInput.isEmpty) return;

    // Send the user input to the chatbot API
    final response = await http.post(
      Uri.parse(
          'http://172.20.10.5:5000/chatbot'), // Replace with your server IP address
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': userInput}),
    );

    if (response.statusCode == 200) {
      // Parse the chatbot's response
      final chatbotResponse = json.decode(response.body);
      setState(() {
        // Add the user's input and the chatbot's response to the chat history
        chatHistory.add({'sender': 'You', 'message': userInput});
        chatHistory
            .add({'sender': 'Chatbot', 'message': chatbotResponse['response']});
        _controller.clear(); // Clear the input field
      });
    } else {
      // Handle error
      print('Failed to communicate with chatbot');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 4, 51),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 20),
              child: IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () async {
                    // Show menu options
                    final selectedOption = await showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(
                          100, // Adjust left margin as needed
                          60, // Adjust top margin as needed
                          60, // Adjust right margin as needed
                          0 // Adjust bottom margin as needed
                          ),
                      items: [
                        const PopupMenuItem(
                          value: 'my_profile',
                          child: Text('My Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'see_posts',
                          child: Text('See Posts'),
                        ),
                      ],
                    );

                    if (selectedOption == 'my_profile') {
                      await goToMyProfile();
                    } else if (selectedOption == 'see_posts') {
                      await goToPostWall();
                    }
                  }),
            ),
          ],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(
                      'Welcome, ${widget.nickname}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 8.0),
                    child: Icon(
                      Icons.waving_hand,
                      color: Color.fromARGB(255, 255, 230, 3),
                      size: 34.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5), // Adjust the opacity as desired
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            // Chat history list
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = chatHistory[index];
                  final isUserMessage = chat['sender'] == 'You';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: isUserMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUserMessage)
                          Image.asset(
                            'assets/logo2.png',
                            width: 40,
                            height: 40,
                          ),
                        Flexible(
                          child: Bubble(
                            padding: isUserMessage
                                ? const BubbleEdges.only(right: 8.0)
                                : const BubbleEdges.only(left: 8.0),
                            nip: isUserMessage
                                ? BubbleNip.rightTop
                                : BubbleNip.leftTop,
                            color: isUserMessage
                                ? Color.fromARGB(255, 8, 117, 218)
                                : Color.fromARGB(255, 5, 3, 105),
                            child: Text(
                              chat['message']!,
                              style: TextStyle(
                                color: isUserMessage
                                    ? Colors.white
                                    : const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                        if (isUserMessage)
                          const Icon(
                            MaterialIcons.person,
                            color: Colors.black,
                            size: 30,
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
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true, // Background color
                        fillColor: Colors.white, // White background
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                          borderSide: BorderSide.none, // No border line
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.0), // Padding
                      ),
                      onSubmitted: (value) {
                        // When the user presses the "Enter" key, send the message
                        sendMessage();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
