import 'package:booking_app/screens/artist_register/artist_profile/create_service/create_service_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

import 'create_post_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Hiện tại chưa có bài viết nào',
                style: TextStyle(
                    color: Colors.black, fontFamily: "JacquesFrancois")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadingScreen(context, () => CreatePostScreen());
        },
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
