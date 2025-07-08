import 'dart:convert';

import 'package:dio/dio.dart';
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

  /// Call /api/UserProgress/get-user API
  static Future<Map<String, dynamic>> fetchUserProgress({
    required String userId,
    int? role,
    int pageNumber = 1,
    int pageSize = 10,
    required String token,
  }) async {
    try {
      Dio dio = Dio();
      dio.options.baseUrl =
          'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      FormData formData = FormData.fromMap({
        'UserId': userId,
        if (role != null) 'Role': role,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      });

      print('[fetchUserProgress] Request body: ${formData.fields}');

      final response = await dio.post(
        '/UserProgress/get-user',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unknown error: $e',
        'statusCode': null,
      };
    }
  }

  /// Cập nhật profile người dùng
  static Future<Map<String, dynamic>> updateUserProfile({
    required String id,
    required String name,
    String? tagName,
    String? phoneNumber,
    int? gender,
    String? address,
    String? imagePath, // Đường dẫn file ảnh trên thiết bị
    required String token,
  }) async {
    try {
      Dio dio = Dio();
      dio.options.baseUrl =
          'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      FormData formData = FormData.fromMap({
        'Id': id,
        'Name': name,
        if (tagName != null) 'TagName': tagName,
        if (phoneNumber != null) 'PhoneNumber': phoneNumber,
        if (gender != null) 'Gender': gender,
        if (address != null) 'Address': address,
        'ImageUrl': (imagePath != null && imagePath.isNotEmpty)
            ? await MultipartFile.fromFile(imagePath,
                filename: imagePath.split('/').last)
            : '', // Luôn truyền ImageUrl, nếu không có thì truyền chuỗi rỗng
      });

      print('[updateUserProfile] Request body: ${formData.fields}');

      final response = await dio.put(
        '/api/user-account/update-profile',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('[updateUserProfile] Response: ${response.data}');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unknown error: $e',
        'statusCode': null,
      };
    }
  }

  /// Fetch all artists from /api/UserProgress/get-information-artist
  static Future<Map<String, dynamic>> fetchAllArtists({
    required String token,
  }) async {
    try {
      Dio dio = Dio();
      dio.options.baseUrl =
          'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.get(
        '/UserProgress/get-information-artist',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unknown error: $e',
        'statusCode': null,
      };
    }
  }

  /// Fetch artist advanced information by artistId
  static Future<Map<String, dynamic>> fetchArtistAdvancedInformation({
    required String artistId,
    required String token,
  }) async {
    try {
      Dio dio = Dio();
      dio.options.baseUrl =
          'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      FormData formData = FormData.fromMap({
        'ArtistId': artistId,
      });

      final response = await dio.post(
        '/artist-progress/get-artist-advanced-information',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print(
          '[fetchArtistAdvancedInformation] Response data: \\n${response.data}');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.message,
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unknown error: $e',
        'statusCode': null,
      };
    }
  }
}