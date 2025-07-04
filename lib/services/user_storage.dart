import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserStorage {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  // Lưu token theo email để hỗ trợ multi-user
  static const String _emailTokenPrefix = 'token_for_';

  // Lưu thông tin người dùng
  static Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Lưu toàn bộ thông tin user
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      // Lưu riêng token để dễ truy cập
      if (user.token != null) {
        await prefs.setString(_tokenKey, user.token!);

        // Lưu token theo email để hỗ trợ multi-user
        if (user.email != null) {
          await saveTokenForEmail(user.email!, user.token!);
        }
      }

      if (user.refreshToken != null) {
        await prefs.setString(_refreshTokenKey, user.refreshToken!);
      }

      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Lấy thông tin người dùng
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }

      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Lấy token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Lấy refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  // Kiểm tra xem user đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    try {
      final user = await getUser();
      return user?.isLoggedIn ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Xóa thông tin người dùng (logout)
  static Future<bool> clearUser({String? email}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Nếu có email, chỉ xóa token cho email đó
      if (email != null) {
        await removeTokenForEmail(email);
      } else {
        // Xóa toàn bộ dữ liệu user
        await prefs.remove(_userKey);
        await prefs.remove(_tokenKey);
        await prefs.remove(_refreshTokenKey);

        // Xóa tất cả token theo email (có thể có nhiều user)
        final keys = prefs.getKeys();
        final emailTokenKeys =
            keys.where((key) => key.startsWith(_emailTokenPrefix));
        for (String key in emailTokenKeys) {
          await prefs.remove(key);
        }
      }

      return true;
    } catch (e) {
      print('Error clearing user: $e');
      return false;
    }
  }

  // Cập nhật token mới
  static Future<bool> updateTokens(String? token, String? refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }

      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }

      // Cập nhật trong user data nếu có
      final user = await getUser();
      if (user != null) {
        final updatedUser = UserModel(
          token: token ?? user.token,
          refreshToken: refreshToken ?? user.refreshToken,
          name: user.name,
          address: user.address,
          phoneNumber: user.phoneNumber,
          email: user.email,
          role: user.role,
          requiresTwoFactor: user.requiresTwoFactor,
          message: user.message,
          isSuccess: user.isSuccess,
          errorMessage: user.errorMessage,
        );
        await saveUser(updatedUser);
      }

      return true;
    } catch (e) {
      print('Error updating tokens: $e');
      return false;
    }
  }

  // Kiểm tra xem có token hợp lệ cho email cụ thể không
  static Future<bool> hasValidTokenForEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenKey = _emailTokenPrefix + email.toLowerCase();
      final token = prefs.getString(tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking token for email: $e');
      return false;
    }
  }

  // Lưu token cho email cụ thể
  static Future<bool> saveTokenForEmail(String email, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenKey = _emailTokenPrefix + email.toLowerCase();
      await prefs.setString(tokenKey, token);
      return true;
    } catch (e) {
      print('Error saving token for email: $e');
      return false;
    }
  }

  // Lấy token cho email cụ thể
  static Future<String?> getTokenForEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenKey = _emailTokenPrefix + email.toLowerCase();
      return prefs.getString(tokenKey);
    } catch (e) {
      print('Error getting token for email: $e');
      return null;
    }
  }

  // Xóa token cho email cụ thể
  static Future<bool> removeTokenForEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenKey = _emailTokenPrefix + email.toLowerCase();
      await prefs.remove(tokenKey);
      return true;
    } catch (e) {
      print('Error removing token for email: $e');
      return false;
    }
  }
}
