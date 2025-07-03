import 'package:booking_app/home/main_layout.dart';
import 'package:booking_app/screens/auth/register_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:booking_app/services/user_storage.dart';
import 'package:booking_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fancy_popups_new/fancy_popups_new.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFormValid = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      UserModel user = result['data'];

      // Lưu thông tin user vào local storage
      await UserStorage.saveUser(user);

      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        builder: (BuildContext context) => MyFancyPopup(
          bodyStyle: const TextStyle(
              fontFamily: "OpenSans",
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
          heading: "Đăng nhập thành công !",
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
          heading: "Đăng nhập thất bại !",
          body: result['error'] ??
              result['message'] ??
              "Đã xảy ra lỗi không xác định",
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    bool isLoggedIn = await UserStorage.isLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'LOGIN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Email field
              const Text('Email',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password field
              const Text('Password',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: (_isFormValid && !_isLoading) ? _login : null,
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
                        'LOGIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Sign Up Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to signup screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Sign up',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Social login options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialLoginButton('assets/facebook_icon.png',
                      color: Colors.blue, icon: Icons.facebook),
                  _socialLoginButton('assets/apple_icon.png',
                      color: Colors.black, icon: Icons.apple),
                  _socialLoginButton('assets/google_icon.png',
                      color: Colors.white, icon: Icons.g_mobiledata),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton(String assetName,
      {required Color color, required IconData icon}) {
    return InkWell(
      onTap: () {
        // Handle social login
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color == Colors.white ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
