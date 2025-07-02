import 'package:booking_app/home/main_layout.dart';
import 'package:flutter/material.dart';

import '../../widgets/colors.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_loading.dart';
import '../profiles/profiles_screen.dart';

class PaymentCreditScreen extends StatelessWidget {
  const PaymentCreditScreen({super.key});

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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CustomPaint(
                    painter: DashedRectPainter(
                      color: Colors.grey.shade400,
                      dashLength: 6,
                      gapLength: 4,
                      radius: 10,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            'Payment\nMethod',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "JacquesFrancois",
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCardIcon('assets/images/Mastercard.png'),
                                _buildCardIcon('assets/images/Visa.png'),
                                _buildCardIcon('assets/images/Amex.png'),
                                _buildCardIcon('assets/images/Discover.png'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Credit Card Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: "JacquesFrancois",
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: 'Name on card',
                        hint: 'Meet Patel',
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                          label: 'Card number', hint: '0000 0000 0000 0000'),
                      const SizedBox(height: 10),
                      const Text(
                        'Card expiration',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: '',
                              items: List.generate(12, (i) => '${i + 1}'),
                              hint: 'Month',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              label: '',
                              items: ['2025', '2026', '2027'],
                              hint: 'Year',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                          label: 'Card Security Code',
                          hint: 'Code',
                          suffixIcon: Icons.help_outline),
                      const SizedBox(height: 20),
                      const Text(
                        'Billing address',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdown(
                          label: 'Country',
                          items: ['Vietnam', 'USA', 'UK'],
                          hint: 'Country'),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      loadingScreen(context, () => MainLayout());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: myPrimaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(236, 46),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Thanh toán',
                      style: TextStyle(
                          fontFamily: "JacquesFrancois", fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildCardIcon(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF5F5F5),
      ),
      child: Image.asset(assetPath, height: 28, width: 28),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 3.0,
    this.radius = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

Widget _buildTextField(
    {required String label, String? hint, IconData? suffixIcon}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      TextField(
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
      ),
    ],
  );
}

Widget _buildDropdown(
    {required String label,
    required List<String> items,
    required String hint}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty)
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        hint: Text(hint),
        items: items.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {},
      ),
    ],
  );
}
