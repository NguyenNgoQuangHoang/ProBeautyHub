import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

import 'artist_profile/artist_profile_screen.dart';

class RegisterSuccesArtistScreen extends StatefulWidget {
  const RegisterSuccesArtistScreen({super.key});

  @override
  State<RegisterSuccesArtistScreen> createState() =>
      _RegisterSuccesArtistScreenState();
}

class _RegisterSuccesArtistScreenState
    extends State<RegisterSuccesArtistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
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
                          color: Colors.black)),
                  Image.asset("assets/images/entypo_flower.png",
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
                          color: Colors.black))
                ],
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Check mark circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Success text
                    const Text(
                      'Đăng kí thành công',
                      style: TextStyle(
                        fontFamily: "JacquesFrancois",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description text
                    const Text(
                      'Trang artist đã được khởi tạo thành công, vui lòng thiết lập dịch vụ, bài viết để tiếp cận đến khách hàng.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "JacquesFrancois",
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      loadingScreen(context, () => ArtistProfileScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCA90C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tiếp tục',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
