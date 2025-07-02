import 'package:booking_app/screens/book_services/payment_credit_screen.dart';
import 'package:flutter/material.dart';
import 'package:booking_app/widgets/colors.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_loading.dart';
import '../profiles/profiles_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> bookings = [
      {
        'service': 'Glam Makeup',
        'date': 'Monday, March 24, 2025',
        'time': '09:00 AM - 11:00 AM',
      },
      {
        'service': 'Glam Makeup',
        'date': 'Monday, March 29, 2025',
        'time': '06:00 AM - 09:00 AM',
      },
    ];

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
            // Sub-header
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
                      'Payment',
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
            // Address info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Phuong.Jame",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Baloo2",
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "0912345678",
                                style: TextStyle(
                                  fontFamily: "Baloo2",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "BS11 Vinhomes Grand Park\nPhuong Long Thanh My, TP Thu Duc,\nTP Ho Chi Minh",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontFamily: "Baloo2",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bookings list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              booking['service']!,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontFamily: "Baloo2",
                                fontSize: 16,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  booking['date']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Baloo2",
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  booking['time']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Baloo2",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: Divider(
                            color: const Color.fromARGB(255, 73, 73, 73),
                            // thickness: 1,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Total Payment summary
            Container(
              padding: const EdgeInsets.all(12),
              // color: Colors.white,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRowInfo('Total service', '\$800'),
                  _buildRowInfo('Discount', '\$80'),
                  const SizedBox(height: 8),
                  // Note
                  const Row(
                    children: [
                      Text(
                        "Note",
                        style: TextStyle(
                          fontFamily: "JacquesFrancois",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Color(0xFFEFEFEF),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontFamily: "JacquesFrancois",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Payment method",
                        style: TextStyle(fontFamily: "JacquesFrancois"),
                      ),
                      DropdownButton<String>(
                        items: const [
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text(
                              "Cash",
                              style: TextStyle(fontFamily: "JacquesFrancois"),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'card',
                            child: Text(
                              "Card",
                              style: TextStyle(fontFamily: "JacquesFrancois"),
                            ),
                          ),
                        ],
                        value: 'cash',
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Payment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: "JacquesFrancois",
                        ),
                      ),
                      const Text(
                        "\$780",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // fontFamily: "JacquesFrancois",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                loadingScreen(context, () => const PaymentCreditScreen());
              },
              child: Container(
                height: 60,
                color: const Color.fromARGB(255, 121, 119, 119),
                alignment: Alignment.center,
                child: const Text(
                  'PAYMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    fontFamily: "JacquesFrancois",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              // fontFamily: "JacquesFrancois",
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              // fontFamily: "JacquesFrancois",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
