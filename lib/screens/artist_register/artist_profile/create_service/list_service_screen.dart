import 'package:flutter/material.dart';
import 'create_or_edit_service_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';

class ListServiceScreen extends StatelessWidget {
  const ListServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = List.generate(4, (index) {
      return {
        'title': 'Makeup đi tiệc',
        'duration': '60',
        'price': '200,000 vnd',
        'description': 'Dịch vụ makeup đi tiệc chuyên...',
        'image': 'assets/images/model_makeup.png',
        'hashtags': ['#Trangdiem', '#Ditiec'],
      };
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dịch vụ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      service['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    service['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "JacquesFrancois",
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${service['duration']} phút - ${service['price']}',
                        style: const TextStyle(
                            color: Colors.black, fontFamily: "JacquesFrancois"),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['description'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black, fontFamily: "JacquesFrancois"),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.purple,
                  ),
                  onTap: () async {
                    await loadingScreen(
                      context,
                      () => CreateOrEditServiceScreen(
                        imagePath: service['image'],
                        title: service['title'],
                        price: service['price'],
                        duration: service['duration'],
                        description: service['description'],
                        hashtags: List<String>.from(service['hashtags']),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black),
              ),
              onPressed: () {},
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
