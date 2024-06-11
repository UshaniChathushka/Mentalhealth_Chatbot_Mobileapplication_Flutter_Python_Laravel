import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import './intro2.dart';

class Intro1Page extends StatefulWidget {
  const Intro1Page({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _Intro1PageState createState() => _Intro1PageState();
}

class _Intro1PageState extends State<Intro1Page> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro1.mp4');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                    const Positioned(
                      top: 400,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Center(
                          child: Text(
                            'Therapy for busy people',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 580,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const Center(
                          child: Column(
                            children: [
                              Text(
                                'Dora helps tranquility in hectic times. Elevate well-being with quick and effective therapy check-ins.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Manjari',
                                  fontSize: 22,
                                  color: Color.fromARGB(196, 255, 255, 255),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 650),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Intro2Page()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(169, 0, 0, 0),
                  backgroundColor: const Color.fromARGB(255, 252, 252, 252),
                  fixedSize: const Size(250, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
