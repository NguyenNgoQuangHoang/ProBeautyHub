import 'package:booking_app/screens/book_services/information_service_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom_appbar.dart';
import '../profiles/profiles_screen.dart';

class ChooseServiceScreen extends StatefulWidget {
  const ChooseServiceScreen({super.key});

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  // Danh sách các dịch vụ
  final List<Map<String, dynamic>> services = [
    {
      "title": "Makeup nhẹ nhàng",
      "image": "assets/images/test.png",
      "price": 200000,
    },
    {
      "title": "Makeup dự tiệc",
      "image": "assets/images/test.png",
      "price": 350000,
    },
    {
      "title": "Makeup cô dâu",
      "image": "assets/images/test.png",
      "price": 500000,
    },
    {
      "title": "Makeup sân khấu",
      "image": "assets/images/test.png",
      "price": 450000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VND',
    );
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
        body: Stack(
          children: [
            Column(
              children: [
                // Sub-header
                Container(
                  color: myPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, size: 18),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Choose Service',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "JacquesFrancois",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // List of services
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: Column(
                      children: List.generate(services.length, (index) {
                        final service = services[index];
                        return GestureDetector(
                          onTap: () {
                            loadingScreen(
                              context,
                              () => InformationServiceScreen(
                                title: service['title'],
                                imageUrl: service['image'],
                                price: service['price'],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(service['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        service['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: "JacquesFrancois",
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 8,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter
                                            .format(service['price']),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: "JacquesFrancois",
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 8,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            // Cancel booking button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 70,
                  color: const Color.fromARGB(221, 61, 60, 60),
                  alignment: Alignment.center,
                  child: const Text(
                    'Cancel booking artist',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: "JacquensFrancois",
                      fontSize: 16,
                    ),
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
