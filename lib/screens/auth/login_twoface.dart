import 'package:booking_app/home/main_layout.dart';
import 'package:booking_app/models/user_model.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:booking_app/services/user_storage.dart';
import 'package:fancy_popups_new/fancy_popups_new.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    String? userId;
    String? role;

    if (result['success'] == true || result['isSuccess'] == true) {
      UserModel? user = result['data'];
      String? token = user?.token;
      String? refreshToken = user?.refreshToken;

      // Nếu không có trong UserModel, thử lấy trực tiếp từ response
      token ??= result['token'];
      refreshToken ??= result['refreshToken'];

      print('Token found: ${token != null}');
      print('Token length: ${token?.length ?? 0}');

      if (token != null) {
        try {
          final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          userId = decodedToken['sub'];
          role = decodedToken[
              'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
          print('Decoded userId: $userId');
          print('Decoded role from token: $role');
        } catch (e) {
          print('Error decoding token: $e');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print('Token saved to SharedPreferences: auth_token');

        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
          print('Refresh token saved to SharedPreferences: refresh_token');
        }

        if (userId != null) {
          await prefs.setString('user_id', userId);
          print('UserId saved to SharedPreferences: $userId');
        }

        await UserStorage.saveTokenForEmail(widget.email, token);
        print('Token saved to UserStorage for email: ${widget.email}');
      } else {
        print('Warning: No token found in response');
      }

      UserModel finalUser = UserModel(
        token: token,
        refreshToken: refreshToken,
        email: widget.email,
        isSuccess: true,
        id: userId,
        name: user?.name ?? result['name'],
        address: user?.address ?? result['address'],
        phoneNumber: user?.phoneNumber ?? result['phoneNumber'],
        role: role?.toLowerCase() == 'artist'
            ? '1'
            : role?.toLowerCase() == 'customer'
                ? '2'
                : null,
      );

      await UserStorage.saveUser(finalUser);
      print('User saved to UserStorage');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } else {
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
