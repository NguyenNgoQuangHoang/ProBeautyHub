import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import 'package:intl/intl.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatelessWidget {
  ServiceListScreen({super.key});

  final currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'vnd');
  final List<ServiceModel> services = [
    ServiceModel(
      title: "Makeup đi tiệc",
      price: 200000,
      imageUrl: "assets/images/content.png",
    ),
    ServiceModel(
      title: "Makeup đi tiệc",
      price: 180000,
      imageUrl: "assets/images/content.png",
    ),
    ServiceModel(
      title: "Makeup đi tiệc",
      price: 179000,
      imageUrl: "assets/images/content.png",
    ),
    ServiceModel(
      title: "Makeup đi tiệc",
      price: 200000,
      imageUrl: "assets/images/content.png",
    ),
    ServiceModel(
      title: "Makeup đi tiệc",
      price: 200000,
      imageUrl: "assets/images/content.png",
    ),
    ServiceModel(
      title: "Makeup đi tiệc",
      price: 200000,
      imageUrl: "assets/images/content.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceItem(services[index], context);
        },
      ),
    );
  }

  Widget _buildServiceItem(ServiceModel service, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              title: service.title,
              price: service.price,
              imageUrl: service.imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                service.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "JacquesFrancois",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(service.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: "JacquesFrancois",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
