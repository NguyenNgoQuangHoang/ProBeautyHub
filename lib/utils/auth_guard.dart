import 'package:flutter/material.dart';
import '../services/user_storage.dart';
import '../screens/auth/login_screen.dart';
import '../home/main_layout.dart';

class AuthGuard {
  static Future<Widget> getInitialScreen() async {
    bool isLoggedIn = await UserStorage.isLoggedIn();
    return isLoggedIn ? const MainLayout() : const LoginScreen();
  }

  static Future<void> logout(BuildContext context) async {
    await UserStorage.clearUser();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  static Future<bool> checkAuthAndRedirect(BuildContext context) async {
    bool isLoggedIn = await UserStorage.isLoggedIn();
    if (!isLoggedIn && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return false;
    }
    return true;
  }
}
