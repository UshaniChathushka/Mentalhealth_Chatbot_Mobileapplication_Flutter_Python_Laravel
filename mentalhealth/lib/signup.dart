import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './login.dart';
import './otp.dart';
import './welcome.dart';
import '/api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> signUp(BuildContext context) async {
    // Perform validation
    emailError = validateEmail(emailController.text);
    passwordError = validatePassword(passwordController.text);
    confirmPasswordError =
        validateConfirmPassword(confirmPasswordController.text);

    // If any validation fails, don't proceed with signup
    if (emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      setState(() {}); // Trigger a rebuild to display validation errors
      return;
    }

    // Continue with signup logic
    // Call the signUp method from the ApiService
    try {
      final String token = await ApiService.signUp(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          password_confirmation: confirmPasswordController.text);

      // Store token in SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);

      // Signup successful, navigate to OTP verification page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(email: emailController.text),
        ),
      );

      // Assuming you get the user_id after signup
    } catch (error) {
      // Signup failed, handle errors
      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  // Validate email
  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    } else {
      return null;
    }
  }

  // Validate password: 8 characters with 1 uppercase letter and 3 digits
  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 8 ||
        !RegExp(r'^(?=.*[A-Z])(?=(?:.*?[0-9]){3,})').hasMatch(value)) {
      return 'Invalid password format. It must be at least \n8 characters with 1 uppercase letter and 3 digits.';
    }
    return null;
  }

  // Validate confirm password matches password
  String? validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Confirm Password is required';
    } else if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void goToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomePage(
          email: '',
        ), // Navigate to WelcomePage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/signimg3.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 40.0, 40.0, 00.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed:
                            goToWelcome, // Call the function when the button is pressed
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 193.0),
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      hintText: 'Enter Name',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    onChanged: (_) {
                      setState(() {
                        emailError = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      hintText: 'Enter Email',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorText: emailError,
                      errorStyle: TextStyle(
                        color: emailError != null
                            ? Colors.red
                            : const Color.fromARGB(0, 0, 0, 0),
                      ),
                      suffixIcon: const Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText:
                        _obscurePassword, // Use a boolean to toggle visibility
                    obscuringCharacter: '.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    onChanged: (_) {
                      setState(() {
                        passwordError = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorText: passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText:
                        _obscureConfirmPassword, // Use a boolean to toggle visibility
                    obscuringCharacter: '.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    onChanged: (_) {
                      setState(() {
                        confirmPasswordError = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorText: confirmPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => signUp(context),
                      child: const Text('Sign up'),
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 173, 172, 172),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 6, 39, 205),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
