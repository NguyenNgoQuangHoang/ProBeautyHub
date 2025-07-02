import 'package:booking_app/screens/artist_register/artist_profile/create_post/list_post_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_service/list_service_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _timeController = TextEditingController();
  final _hashtagController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
            child: Text('Tạo post mới',
                style: TextStyle(
                    color: Colors.black, fontFamily: "JacquesFrancois"))),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.grey),
                  Text('Thêm ảnh hoặc video',
                      style: TextStyle(
                          color: Colors.grey, fontFamily: "JacquesFrancois")),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildInputField('Tên caption', controller: _nameController),
            buildInputField('Gắn hastag', controller: _priceController),
            buildInputField('Mô hình dịch vụ', controller: _hashtagController),
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  loadingScreen(context, () => ListPostScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: myPrimaryColor,
                  minimumSize: Size(236, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  // maximumSize: Size(236, 46)),
                ),
                child: Text(
                  'Đăng bài',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "JacquesFrancois",
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

  Widget buildInputField(String hint,
      {TextEditingController? controller, int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: mySecondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontFamily: "JacquesFrancois"),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
