import 'package:flutter/material.dart';

import './intro3.dart';
import './privacy.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _agreedToTerms = false;

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Intro3Page(),
            ),
          );
        },
        color: Colors.white,
      ),
      title: const Text(
        'Terms and Conditions',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 20, // Increase font size
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPage(),
              ),
            );
          },
          child: const Text(
            'Skip',
            style: TextStyle(
              color: Color.fromARGB(255, 75, 129, 255),
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
      backgroundColor: const Color.fromARGB(255, 1, 7, 55),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: ElevatedButton(
        onPressed: _agreedToTerms
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPage(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 1, 7, 55),
          padding: const EdgeInsets.symmetric(
              vertical: 12), // Increase button padding
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16, // Increase font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 62, 62, 62),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color.fromRGBO(102, 102, 102, 1),
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return CheckboxListTile(
      title: const Text(
        'I agree with terms and conditions',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color.fromRGBO(102, 102, 102, 1),
        ),
      ),
      value: _agreedToTerms,
      onChanged: (value) {
        setState(() {
          _agreedToTerms = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color.fromARGB(255, 15, 88, 214),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextSection(
                'Welcome to DORA!',
                'By using the app, you agree to our Terms and Conditions. Please read these terms carefully before accessing or using our app.',
              ),
              _buildTextSection(
                'Eligibility',
                'You must be at least 18 years old to use the app. By using the app, you confirm you meet this requirement.',
              ),
              _buildTextSection(
                'Use of the App',
                'The app offers a chatbot for mental health support and motivational posts. You may use the chatbot without an account, but an account is needed for posting.',
              ),
              _buildTextSection(
                'Account Creation',
                'To create an account, you need to provide a username, full name, birthday, bio, and profile picture. Ensure the information provided is accurate and up to date.',
              ),
              _buildTextSection(
                'User Conduct',
                'You must not harm, harass, or defame others through the app. Respect the privacy and confidentiality of others and avoid sharing sensitive information.',
              ),
              _buildTextSection(
                'Chatbot',
                'The chatbot offers support for mental health concerns but is not a substitute for professional advice. Seek immediate help from a healthcare provider if in crisis.',
              ),
              _buildTextSection(
                'Posts and Interaction',
                'You can create and share posts about mental health motivation. Interact with others by liking or commenting on their posts. Avoid posting offensive or illegal content.',
              ),
              _buildTextSection(
                'Privacy',
                'We handle user information according to our Privacy Policy. We take measures to protect user data but cannot guarantee complete security.',
              ),
              _buildTextSection(
                'Termination',
                'We reserve the right to suspend or terminate accounts that violate our Terms or engage in unlawful activities.',
              ),
              _buildTextSection(
                'Changes to Terms',
                'We may modify these Terms at any time. You will be notified of changes, and continued use of the app implies acceptance.',
              ),
              _buildTextSection(
                'Contact Us',
                'For questions or concerns, contact us at: mentalhealthdora@gmail.com',
              ),
              const Text(
                'These Terms and Conditions were last updated on April 25, 2024.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color.fromRGBO(92, 92, 92, 1),
                ),
              ),
              _buildCheckbox(),
              const SizedBox(height: 20),
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
