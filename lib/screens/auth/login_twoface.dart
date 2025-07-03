import 'package:flutter/material.dart';
import 'package:booking_app/home/main_layout.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:booking_app/services/user_storage.dart';
import 'package:booking_app/models/user_model.dart';
import 'package:fancy_popups_new/fancy_popups_new.dart';

class TwoFactorScreen extends StatefulWidget {
  final String email;

  const TwoFactorScreen({super.key, required this.email});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isFormValid = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.verifyTwoFactorCode(
      email: widget.email,
      twoFactorCode: _codeController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      UserModel user = result['data'];

      // Lưu thông tin user vào local storage (bây giờ có token)
      await UserStorage.saveUser(user);

      // Hiển thị thông báo thành công và chuyển vào app
      showDialog(
        context: context,
        builder: (BuildContext context) => MyFancyPopup(
          bodyStyle: const TextStyle(
              fontFamily: "OpenSans",
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
          heading: "Xác thực thành công !",
          body: "Chào mừng ${user.name ?? user.email} quay trở lại!",
          onClose: () {
            loadingScreen(context, () => const MainLayout());
          },
          type: Type.success,
          buttonColor: Colors.orangeAccent,
          buttonText: "Tiếp tục",
        ),
      );
    } else {
      // Hiển thị thông báo lỗi
      showDialog(
        context: context,
        builder: (BuildContext context) => MyFancyPopup(
          bodyStyle: const TextStyle(
              fontFamily: "OpenSans",
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
          heading: "Xác thực thất bại !",
          body:
              result['error'] ?? result['message'] ?? "Mã xác thực không đúng",
          onClose: () {
            Navigator.of(context).pop();
          },
          type: Type.error,
          buttonColor: Colors.red,
          buttonText: "Thử lại",
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'Two-Factor Authentication',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Email',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mã xác thực đã được gửi tới email của bạn. Vui lòng kiểm tra và nhập mã bên dưới.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Verification Code',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) {
                    return 'Code must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_isFormValid && !_isLoading) ? _verifyCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFormValid ? Colors.pink : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'VERIFY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: Implement resend code functionality
                },
                child: const Text(
                  'Gửi lại mã xác thực',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
