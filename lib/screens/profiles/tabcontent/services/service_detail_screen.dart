import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/custom_row.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;

  const ServiceDetailScreen({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'vnd');
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(title,
              style: const TextStyle(
                fontFamily: "JacquesFrancois",
                fontWeight: FontWeight.bold,
              )),
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
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(icon: Icons.menu, label: "Dịch vụ", title: title),
                      const SizedBox(height: 25),
                      InfoRow(
                          icon: Icons.price_change,
                          label: "Giá",
                          title: currencyFormatter.format(price)),
                      const SizedBox(height: 25),
                      InfoRow(
                          icon: Icons.hourglass_bottom,
                          label: "Thời gian",
                          title: "60 phút"),
                      const SizedBox(height: 25),
                      InfoRow(
                          icon: Icons.edit,
                          label: "Mô tả",
                          title:
                              "Dịch vụ makeup đi tiệc chuyên nghiệp, sang trọng, bền lâu, giúp bạn tự tin tỏa sáng trong mọi sự kiện đặc biệt."),
                      const SizedBox(height: 25),
                      InfoRow(
                          icon: Icons.attach_file, label: "Hashtag", title: ""),
                      const SizedBox(height: 30),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
