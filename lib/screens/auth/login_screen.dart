import 'package:booking_app/home/main_layout.dart';
import 'package:booking_app/screens/auth/register_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

import '../../home/tabs/home_screen.dart';

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

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                // onPressed: () {},
                onPressed: _isFormValid
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          loadingScreen(context, () => const MainLayout());
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFormValid ? Colors.pink : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    color:
                        Colors.white, // đổi sang trắng cho dễ đọc trên nền hồng
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
