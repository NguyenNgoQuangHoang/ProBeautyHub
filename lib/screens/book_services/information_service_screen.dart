import 'package:booking_app/screens/book_services/choose_date_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/custom_row.dart';
import '../../widgets/custom_loading.dart';

class InformationServiceScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final num price;

  const InformationServiceScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
  });

  @override
  State<InformationServiceScreen> createState() =>
      _InformationServiceScreenState();
}

class _InformationServiceScreenState extends State<InformationServiceScreen> {
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: 'VND',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: myPrimaryColor,
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontFamily: "JacquesFrancois",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: Image.asset(
                widget.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(
                    icon: Icons.menu,
                    label: "Dịch vụ",
                    title: widget.title,
                  ),
                  const SizedBox(height: 25),
                  InfoRow(
                    icon: Icons.price_change,
                    label: "Giá",
                    title: currencyFormatter.format(widget.price),
                  ),
                  const SizedBox(height: 25),
                  const InfoRow(
                    icon: Icons.hourglass_bottom,
                    label: "Thời gian",
                    title: "60 phút",
                  ),
                  const SizedBox(height: 25),
                  const InfoRow(
                    icon: Icons.edit,
                    label: "Mô tả",
                    title:
                        "Dịch vụ makeup đi tiệc chuyên nghiệp, sang trọng, bền lâu, giúp bạn tự tin tỏa sáng trong mọi sự kiện đặc biệt.",
                  ),
                  const SizedBox(height: 25),
                  const InfoRow(
                    icon: Icons.attach_file,
                    label: "Hashtag",
                    title: "#makeup #party #glam",
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        loadingScreen(
                          context,
                          () => ChooseDateScreen(),
                        );
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
                        'Đặt lịch',
                        style: TextStyle(
                            fontFamily: "JacquesFrancois", fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
