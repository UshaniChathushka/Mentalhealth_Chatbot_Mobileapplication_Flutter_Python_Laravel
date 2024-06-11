import 'package:flutter/material.dart';

import './addprofile.dart';
import 'api_service.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({Key? key, required this.email}) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  String? otpError;

  @override
  void dispose() {
    otpControllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  Future<void> verifyOtp(BuildContext context) async {
    final otp = otpControllers.map((controller) => controller.text).join('');
    otpError = validateOtp(otp);

    if (otpError != null) {
      setState(() {});
      return;
    }

    try {
      await ApiService.verifyOtp(email: widget.email, otp: otp);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddProfilePage(email: widget.email),
        ),
      );
    } catch (error) {
      otpError = 'Error verifying OTP: $error';
      setState(() {});
    }
  }

  String? validateOtp(String value) {
    if (value.isEmpty ||
        value.length != 4 ||
        !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Invalid OTP format. It must contain exactly 4 digits.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OTP Verification',
          style: TextStyle(
            color: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              MainAxisAlignment.start, // Aligns elements to the start (top)
          children: [
            // Display the logo image with a top padding of 70 units
            Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Image.asset('assets/otp.png', width: 150, height: 150),
            ),

            const SizedBox(height: 30),

            // Display the text "Enter OTP"
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // Row to hold the OTP input fields
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          focusNodes[index].unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index].unfocus();
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40.0),

            // Button to verify the OTP
            ElevatedButton(
              onPressed: () => verifyOtp(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(7, 3, 76, 1),
              ),
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
