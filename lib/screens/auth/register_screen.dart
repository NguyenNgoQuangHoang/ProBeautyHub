import 'package:booking_app/home/main_layout.dart';
import 'package:booking_app/screens/artist_register/register_succes_artist_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/custom_text_field.dart';
import 'package:fancy_popups_new/fancy_popups_new.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isFormValid = false;

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8E1E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'CREATE AN ACCOUNT',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Baloo2",
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              loadingScreen(context, () => const MainLayout());
            },
            child: Row(
              children: const [
                Text('Skip',
                    style: TextStyle(color: Colors.black, fontSize: 11)),
                Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'First Name',
                      hintText: 'First name',
                      controller: _firstNameController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Please enter first name'
                              : null,
                      onChanged: (_) => _validateForm(),
                    ),
                    CustomTextField(
                      label: 'Last Name',
                      hintText: 'Last name',
                      controller: _lastNameController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Please enter last name'
                              : null,
                      onChanged: (_) => _validateForm(),
                    ),
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter email';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                          return 'Invalid email';
                        return null;
                      },
                      onChanged: (_) => _validateForm(),
                    ),
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'At least 6 characters'
                          : null,
                      onChanged: (_) => _validateForm(),
                    ),
                    CustomTextField(
                      label: 'Confirm password',
                      hintText: 'Confirm password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (value) => value != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                      onChanged: (_) => _validateForm(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        MyFancyPopup(
                                      bodyStyle: const TextStyle(
                                          fontFamily: "OpenSans",
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold),
                                      heading: "Đăng ký thành công !",
                                      body:
                                          "Điều này có nghĩa là bạn đã tạo tài khoản thành công. Bây giờ bạn có thể đăng nhập và sử dụng dịch vụ của chúng tôi.",
                                      onClose: () {
                                        loadingScreen(
                                            context, () => const MainLayout());
                                      },
                                      type: Type.success,
                                      buttonColor: Colors.orangeAccent,
                                      buttonText: "Tiếp tục",
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: const Text("Đăng ký"),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already a member? ',
                              style: TextStyle(
                                  fontSize: 13, fontFamily: "Baloo2")),
                          GestureDetector(
                            onTap: () {
                              // Navigate to sign in
                            },
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontFamily: "Baloo2",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(
                          onPressed: () {},
                          backgroundColor: const Color(0xFF1877F2),
                          icon: FontAwesomeIcons.facebookF,
                        ),
                        const SizedBox(width: 15),
                        _socialButton(
                          onPressed: () {},
                          backgroundColor: Colors.black,
                          icon: FontAwesomeIcons.apple,
                        ),
                        const SizedBox(width: 15),
                        _socialButton(
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          icon: FontAwesomeIcons.google,
                          iconColor: Colors.red,
                          hasBorder: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'By signing up you agree to our Terms & Conditions and our Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFFF8E1E9),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
    Color iconColor = Colors.white,
    bool hasBorder = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: hasBorder ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Center(
          child: FaIcon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
