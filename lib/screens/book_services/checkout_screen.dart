import 'dart:ui';

import 'package:booking_app/screens/book_services/payment_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_appbar.dart';
import '../profiles/profiles_screen.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  // Dummy data
  final List<Map<String, String>> bookings = [
    {
      'artist': 'Alexander Stubb',
      'date': 'Monday, March 24, 2025',
      'time': '09:00 AM - 11:00 AM',
      'price': '\$200',
      'image': 'assets/images/test.png',
    },
    {
      'artist': 'Alexander Stubb',
      'date': 'Monday, March 29, 2025',
      'time': '06:00 AM - 09:00 AM',
      'price': '\$200',
      'image': 'assets/images/test.png',
    },
  ];

  final Set<int> selectedItems = {};

  void _toggleSelection(int index) {
    setState(() {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerIsScrolled) => [
          CustomSliverAppBar(
            backgroundColor: myPrimaryColor,
            onProfileTap: () {
              loadingScreen(context, () => ProfilesScreen());
            },
          ),
        ],
        body: Column(
          children: [
            Container(
              color: myPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Check bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "JacquesFrancois",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox
                          Checkbox(
                            value: selectedItems.contains(index),
                            onChanged: (_) => _toggleSelection(index),
                          ),
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 3.0,
                                    sigmaY: 3.0,
                                  ),
                                  child: Image.asset(
                                    booking['image']!,
                                    width: 140,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Text(
                                  'Glam Makeup',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: "JacquesFrancois",
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),
                          // Info column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  booking['date']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontFamily: "JacquesFrancois",
                                  ),
                                ),
                                Text(
                                  booking['time']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontFamily: "JacquesFrancois",
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  booking['price']!,
                                  style: const TextStyle(
                                    fontFamily: "JacquesFrancois",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Check out button
            GestureDetector(
              onTap: () {
                loadingScreen(context, () => PaymentScreen());
              },
              child: Container(
                height: 60,
                color: const Color.fromARGB(255, 126, 125, 125),
                alignment: Alignment.center,
                child: const Text(
                  'CHECK OUT',
                  style: TextStyle(
                    fontFamily: "JacquesFrancois",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
