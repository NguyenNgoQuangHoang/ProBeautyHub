import 'package:booking_app/screens/artist_register/artist_profile/create_service/create_service_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

class ServiceArtistScreen extends StatefulWidget {
  const ServiceArtistScreen({super.key});

  @override
  State<ServiceArtistScreen> createState() => _ServiceArtistScreenState();
}

class _ServiceArtistScreenState extends State<ServiceArtistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dịch vụ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Trống',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: "JacquesFrancois")),
            SizedBox(height: 8),
            Text('Hiện tại chưa có dịch vụ nào',
                style: TextStyle(
                    color: Colors.black, fontFamily: "JacquesFrancois")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadingScreen(context, () => CreateServiceScreen());
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey),
        ),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
