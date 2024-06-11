import 'package:flutter/material.dart';

import 'chat.dart'; // Import the Home page

class WelcomePage extends StatefulWidget {
  final String email;

  WelcomePage({Key? key, required this.email}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController nicknameController = TextEditingController();

  bool isAbove18Selected =
      false; // Track whether the "I'm above 18 years" button is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Logo
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                child: Image.asset(
                  'assets/applogo.png',
                  width: 450,
                  height: 450,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Text - Set Your Age
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 320, left: 40),
                child: const Text(
                  'Set Your Age',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                    color: Color.fromARGB(255, 131, 130, 130),
                  ),
                ),
              ),
            ),

            // Buttons - Below and Above 18 Years
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 380, left: 50),
                child: Column(
                  children: [
                    // Button for "I'm below 18 years"
                    ElevatedButton(
                      onPressed: () {
                        // Display a message when below 18 years is selected
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Age Restriction',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: const Text(
                              'You must be above 18 years to use this app.',
                              style: TextStyle(fontFamily: 'Roboto'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(309, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        "I'm below 18 years",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Button for "I'm above 18 years"
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isAbove18Selected = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(309, 50),
                        backgroundColor: isAbove18Selected
                            ? Color.fromARGB(255, 4, 0, 108)
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        "I'm above 18 years",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text - Set Your Nickname
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 560, left: 40),
                child: const Text(
                  'Set Your Nickname',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                    color: Color.fromARGB(255, 131, 130, 130),
                  ),
                ),
              ),
            ),

            // TextField for Nickname
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 570, left: 40, right: 50),
                child: TextFormField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    hintText: '',
                    hintStyle: TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
              ),
            ),

            // Button - Get Started
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 710, left: 50),
                child: ElevatedButton(
                  onPressed: isAbove18Selected
                      ? () {
                          // Retrieve the nickname from the input
                          String nickname = nicknameController.text;

                          // Navigate to the Home page with the nickname and email
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                nickname: nickname,
                                email: widget.email,
                              ),
                            ),
                          );
                        }
                      : null, // Disable the button if not selected above 18
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(309, 50),
                    backgroundColor: const Color.fromARGB(255, 1, 17, 74),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
