import 'package:flutter/material.dart';

import './intro1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "demo",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(178, 187, 193, 1),
      body: Stack(
        children: [
          ClipPath(
            clipper: BackgroundClipper(),
            child: Container(
              color: Color.fromARGB(255, 1, 1, 36),
              height: 700,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 390),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 138, 158, 208),
                      Color.fromARGB(255, 78, 81, 118),
                      Color.fromARGB(255, 13, 13, 41)
                    ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                child: const Text(
                  'DORA',
                  style: TextStyle(
                    fontFamily: 'CrimsonText',
                    fontSize: 96,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/applogo.png',
                width: 440,
                height: 440,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 720),
                child: const Text(
                  '      AI Chatbot for depression,\n anxiety, and stress management.',
                  style: TextStyle(
                    fontFamily: 'Manjari',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(10, 45, 70, 1.0),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 500),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Intro1Page()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  fixedSize: const Size(250, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color.fromARGB(0, 255, 255, 255),
                      width: 2,
                    ),
                  ),
                  elevation: 10,
                  padding: const EdgeInsets.all(0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(7, 2, 66, 1),
                        Color.fromARGB(255, 3, 12, 62),
                        Color.fromARGB(255, 1, 9, 50),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 192, 216, 240),
                          Color.fromARGB(255, 177, 182, 201),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Say Hello to Dora....',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'CrimsonText',
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height * 0);
    path.lineTo(0, size.height + 90);
    path.lineTo(0, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
