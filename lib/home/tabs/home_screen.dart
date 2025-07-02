import 'package:flutter/material.dart';

import '../../widgets/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String selectedLocation = '';
  bool isDropdownOpen = false;
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'Make Up Style',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "AbhayaLibre",
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            // Select location
            Container(
              color: myPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isDropdownOpen = !isDropdownOpen;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedLocation.isEmpty
                          ? 'Select location'
                          : selectedLocation,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Icon(
                      isDropdownOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    ),
                  ],
                ),
              ),
            ),

            // Animated Dropdown
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Visibility(
                visible: isDropdownOpen,
                maintainState: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isDropdownOpen ? 1.0 : 0.0,
                  child: _buildLocationDropdownContent(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Nội dung chính
            if (selectedLocation == 'Da Nang')
              _buildMainContent()
            else
              _buildNoServiceMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdownContent() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD5B4C8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                minimumSize: const Size(313, 35),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'ENABLE GPS SERVICE',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ENTER YOUR ADDRESS',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'Start enter your address',
              hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black45),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedLocation = 'Da Nang';
                  isDropdownOpen = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                minimumSize: const Size(313, 35),
              ),
              child: const Text(
                'FIND SERVICES',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: Colors.white,
      child: Column(
        children: [
          _buildPostContent("post1"),
          const SizedBox(height: 20),
          _buildPostContent("post2"),
        ],
      ),
    );
  }

  Widget _buildPostContent(String tag) {
    return Container(
      // padding: const EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black12),
      //   borderRadius: BorderRadius.circular(10),
      //   color: Colors.white,
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 13,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Sweet makeup Store',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1A5),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Left image
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/images/model_makeup.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Right image
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/images/model_makeup.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Text
              Positioned(
                top: 15,
                right: 15,
                child: Text(
                  "Make Up\nStyle",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = myGradient.createShader(
                        const Rect.fromLTWH(0, 0, 200, 70),
                      ),
                    fontFamily: "AguafinaScript",
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Actions
          Row(
            children: const [
              Icon(Icons.favorite_border, size: 28),
              SizedBox(width: 30),
              Icon(Icons.chat_bubble_outline, size: 26),
              SizedBox(width: 30),
              Icon(Icons.send, size: 26),
            ],
          ),
          const SizedBox(height: 5),
          const Text('100 likes',
              style: TextStyle(fontWeight: FontWeight.bold)),

          // Caption
          const SizedBox(height: 3),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Sweet makeup Store ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        'Great make up to complete a perfect day. Learn more but other layouts'),
              ],
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '#makeup #makeupdynamic #vietnam',
            style: TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 3),
          Text(
            'View 14 comments',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 3),
          const Text(
            '21/03/2025 13:33',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoServiceMessage() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Text(
          'Oops! Flawless does not service your current location.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
