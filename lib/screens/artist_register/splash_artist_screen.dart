import 'package:booking_app/screens/artist_register/register_artist_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:booking_app/screens/auth/register_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashArtistScreen extends StatelessWidget {
  const SplashArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/splash_artist.png',
            fit: BoxFit.cover,
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("FLAW",
                          style: TextStyle(
                              fontSize: 24,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(5.0, 5.0),
                                ),
                              ],
                              // fontFamily: "Josefin_Sans",
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Image.asset("assets/images/logo/Vector.png",
                          width: 24, height: 24),
                      Text("ESS",
                          style: TextStyle(
                              fontSize: 24,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(5.0, 5.0),
                                ),
                              ],
                              // fontFamily: "Josefin_Sans",
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                    ],
                  ),

                  const Spacer(),

                  const SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText(
                        'Welcome to',
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontFamily: "Arsenal-Bold"),
                      ),
                    ],
                    isRepeatingAnimation: true,
                    repeatForever: true,
                    // pause: const Duration(milliseconds: 500),
                  ),

                  const SizedBox(height: 10),

                  AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText(
                        'Makeup Artist',
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontFamily: "Arsenal-Bold",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    isRepeatingAnimation: true,
                    repeatForever: true,
                    // pause: const Duration(milliseconds: 1000),
                  ),

                  const Spacer(),

                  // Terms text
                  const Text(
                    "Bằng việc bấm Tiếp tục, bạn đã đồng ý với Điều khoản sử dụng và Chính sách quyền riêng tư của FLAWLESS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontFamily: "Arsenal-Bold",
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      loadingScreen(
                          context, () => const RegisterArtistScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB487C2),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(236, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Tiếp tục",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
