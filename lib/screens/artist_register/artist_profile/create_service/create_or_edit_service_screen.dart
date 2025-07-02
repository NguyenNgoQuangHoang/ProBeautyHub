import 'package:flutter/material.dart';

class CreateOrEditServiceScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final String price;
  final String duration;
  final String description;
  final List<String> hashtags;

  const CreateOrEditServiceScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
    required this.hashtags,
  });

  @override
  State<CreateOrEditServiceScreen> createState() =>
      _CreateOrEditServiceScreenState();
}

class _CreateOrEditServiceScreenState extends State<CreateOrEditServiceScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.title);
    _priceController = TextEditingController(text: widget.price);
    _durationController = TextEditingController(text: widget.duration);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo mới',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "JacquesFrancois"),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildTextField(label: 'Tên dịch vụ', controller: _nameController),
            const SizedBox(height: 12),
            _buildTextField(label: 'Giá', controller: _priceController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Thời gian làm việc',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 19.0),
                  child: const Text('phút',
                      style: TextStyle(
                          fontFamily: "JacquesFrancois",
                          color: Colors.black54,
                          fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHashtagRow(),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Mô tả chi tiết',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final List<String> imagePaths = [
      widget.imagePath,
      widget.imagePath,
      widget.imagePath,
      widget.imagePath,
      widget.imagePath,
      widget.imagePath,
      widget.imagePath,
    ];

    return SizedBox(
      height: 130,
      child: Stack(
        children: List.generate(imagePaths.length, (index) {
          return Positioned(
            left: index * 40.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePaths[index],
                width: 100,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "JacquesFrancois",
                color: Color.fromARGB(255, 59, 58, 58))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHashtagRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hashtag',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "JacquesFrancois",
                color: Colors.black)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 10,
            children: widget.hashtags
                .map((tag) => Text(tag,
                    style: const TextStyle(
                        color: Colors.blue, fontFamily: "JacquesFrancois")))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade200,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(0, 48),
            ),
            child: const Text(
              'Sửa',
              style: TextStyle(fontFamily: "JacquesFrancois", fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(0, 48),
            ),
            child: const Text('Xóa',
                style: TextStyle(fontFamily: "JacquesFrancois", fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
