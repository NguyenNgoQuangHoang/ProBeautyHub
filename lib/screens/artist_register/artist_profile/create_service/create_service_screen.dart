import 'package:booking_app/screens/artist_register/artist_profile/create_service/list_service_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  _CreateServiceScreenState createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
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
            child: Text('Tạo mới',
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
            SizedBox(height: 20),
            buildInputField('Tên dịch vụ', controller: _nameController),
            buildInputField('Giá', controller: _priceController),
            Row(
              children: [
                Expanded(
                  child: buildInputField('Thời gian làm việc',
                      controller: _timeController),
                ),
                SizedBox(width: 8),
                Text('phút', style: TextStyle(fontFamily: "JacquesFrancois")),
              ],
            ),
            buildInputField('Hashtag', controller: _hashtagController),
            buildInputField('Mô tả chi tiết',
                controller: _descriptionController, maxLines: 5),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  loadingScreen(context, () => ListServiceScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: myPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Lưu',
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
