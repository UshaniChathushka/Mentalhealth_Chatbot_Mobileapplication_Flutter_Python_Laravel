import 'package:flutter/material.dart';

import './signup.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy and Security',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 2, 5, 51),
                Color.fromRGBO(4, 12, 74, 1),
                Color.fromARGB(255, 1, 3, 28),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255), // White
              Color.fromARGB(255, 255, 255, 255), // White
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                child: Image.asset(
                  'assets/privacy.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'DORA respects your privacy.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color.fromARGB(255, 10, 10, 10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'The mobile app DORA is designed to protect user privacy and security, specifically for those dealing with mental health issues. The app provides a chatbot feature that allows users to engage in one-time conversations without creating an account or storing chat history. Users can create an account to access motivational mental health posts and follow other users. The app safeguards user data by only displaying usernames publicly and allowing admin control over user-generated content.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 150),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignupPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          backgroundColor: const Color.fromRGBO(7, 3, 76, 1),
        ),
        child: const Text('Continue'),
      ),
    );
  }
}
