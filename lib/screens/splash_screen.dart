import 'package:booking_app/screens/auth/login_screen.dart';
import 'package:booking_app/models/splash_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentIndex = 0;
  late PageController _controller;
  bool _isPrecached = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecached) {
      for (var content in contents) {
        precacheImage(AssetImage(content.image), context);
      }
      _isPrecached = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleButtonPress() async {
    if (currentIndex == contents.length - 1) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: Center(
            child: SpinKitFadingCircle(
              color: Colors.white,
              size: 45.0,
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        controller: _controller,
        itemCount: contents.length,
        onPageChanged: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, i) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                contents[i].image,
                fit: BoxFit.cover,
              ),

              // Overlay
              Container(
                color: contents[i].colorsplash.withOpacity(0.1),
              ),

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Logo top center
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "FLAW",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Josefin_Sans',
                              ),
                            ),
                            const SizedBox(width: 2),
                            Image.asset(
                              "assets/images/logo/Vector.png",
                              height: 40,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "ESS",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Josefin_Sans',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Main image icon
                      if (contents[i].icon != null &&
                          contents[i].icon!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 0), // Reduced padding
                          child: Image.asset(contents[i].icon!, height: 250),
                        ),

                      // Title
                      Text(
                        contents[i].description.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Josefin_Sans',
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description text
                      Text(
                        contents[i].content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.6,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Josefin_Sans',
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          contents.length,
                          (index) => buildDot(index),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        onPressed: handleButtonPress,
                        child: Text(
                          currentIndex == contents.length - 1
                              ? "BOOK NOW"
                              : "NEXT",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // // Sign In Text (only on last page)
                      // if (currentIndex == contents.length - 1)
                      //   const Text(
                      //     "Already a member? Sign In",
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       color: Colors.white,
                      //       fontFamily: 'Josefin_Sans',
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(right: 5),
    );
  }
}
