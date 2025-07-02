import 'dart:io';
import 'package:booking_app/screens/artist_register/register_succes_artist_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_text_field_artist.dart';

class RegisterArtistScreen extends StatefulWidget {
  const RegisterArtistScreen({super.key});

  @override
  State<RegisterArtistScreen> createState() => _RegisterArtistScreenState();
}

class _RegisterArtistScreenState extends State<RegisterArtistScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for each input field
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();

  // Track whether form is valid
  bool _isFormValid = false;

  // For profile image
  File? _profileImage;

  // Validate form and update button state
  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen for changes in required fields to check form validity
    [
      _nameController,
      _phoneController,
      _addressController,
      _areaController,
      _usernameController
    ].forEach((controller) {
      controller.addListener(_validateForm);
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to free memory
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent layout shifting when keyboard appears
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode
                .onUserInteraction, // Show validation errors on input
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildLogo(), // Logo section

                const SizedBox(height: 30),
                _buildProfileIcon(),

                const SizedBox(height: 30),

                CustomTextFormFieldArtist(
                  hintText: 'Tên hiển thị',
                  controller: _nameController,
                  validator: _requiredValidator('Vui lòng nhập tên hiển thị'),
                ),
                const SizedBox(height: 15),

                CustomTextFormFieldArtist(
                  hintText: 'Điện thoại',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: _requiredValidator('Vui lòng nhập số điện thoại'),
                ),
                const SizedBox(height: 15),

                CustomTextFormFieldArtist(
                  hintText: 'Địa chỉ làm việc',
                  controller: _addressController,
                  suffixIcon: const Icon(Icons.location_on_outlined,
                      color: Colors.grey),
                  validator:
                      _requiredValidator('Vui lòng nhập địa chỉ làm việc'),
                ),
                const SizedBox(height: 15),

                CustomTextFormFieldArtist(
                  hintText: 'Khu vực hoạt động',
                  controller: _areaController,
                  suffixIcon: const Icon(Icons.location_city_outlined,
                      color: Colors.grey),
                  validator:
                      _requiredValidator('Vui lòng nhập khu vực hoạt động'),
                ),

                const SizedBox(height: 15),

                // Username input
                CustomTextFormFieldArtist(
                  hintText: 'Username',
                  controller: _usernameController,
                  validator: _requiredValidator('Vui lòng nhập username'),
                ),
                const SizedBox(height: 15),

                // Email input (optional)
                CustomTextFormFieldArtist(
                  hintText: 'Email (không bắt buộc)',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                // Experience details (multi-line input)
                CustomTextFormFieldArtist(
                  hintText: 'Viết thông tin kinh nghiệm của bạn',
                  controller: _experienceController,
                  maxLines: 4,
                ),
                const SizedBox(height: 30),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              loadingScreen(context,
                                  () => const RegisterSuccesArtistScreen());
                              debugPrint("Form is valid");
                            }
                          }
                        : null, // Disabled if form is invalid
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE93D8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(236, 46),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tiếp tục'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // App logo made of 2 texts and an image
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _shadowedText("FLAW"),
        const SizedBox(width: 8),
        Image.asset("assets/images/entypo_flower.png", width: 24, height: 24),
        const SizedBox(width: 8),
        _shadowedText("ESS"),
      ],
    );
  }

  // Logo text with shadow styling
  Widget _shadowedText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(5.0, 5.0),
          ),
        ],
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  } // Circular placeholder avatar icon with edit option

  Widget _buildProfileIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
            image: _profileImage != null
                ? DecorationImage(
                    image: FileImage(_profileImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _profileImage == null
              ? const Icon(Icons.person_outline,
                  size: 50, color: Colors.black54)
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                setState(() {
                  _profileImage = File(image.path);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFCE93D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to create required field validators
  String? Function(String?) _requiredValidator(String errorText) {
    return (value) {
      if (value == null || value.trim().isEmpty) return errorText;
      return null;
    };
  }
}
