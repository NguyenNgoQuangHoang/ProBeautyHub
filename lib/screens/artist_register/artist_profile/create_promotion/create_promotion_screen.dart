import 'package:booking_app/screens/artist_register/artist_profile/create_promotion/list_promotion_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePromotionScreen extends StatefulWidget {
  const CreatePromotionScreen({super.key});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _dateFormat.format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Tạo khuyến mãi mới',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputField('Tên chương trình', _nameController),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildDateField('Thời gian bắt đầu', _startDateController),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildDateField('Thời gian kết thúc', _endDateController),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildInputField('Giảm giá', _discountController),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildServiceSelector(context),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  loadingScreen(context, () => const ListPromotionScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade200,
                  minimumSize: Size(236, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Lưu',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "JacquesFrancois",
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F2F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
              fontFamily: "JacquesFrancois",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F2F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
              fontFamily: "JacquesFrancois",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13),
          border: InputBorder.none,
          suffixIcon:
              Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildServiceSelector(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F2F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text(
              'Dịch vụ áp dụng',
              style: TextStyle(
                  fontFamily: "JacquesFrancois",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
}
