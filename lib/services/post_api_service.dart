import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PostApiService {
  static const String baseUrl =
      'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
  late Dio _dio;

  PostApiService() {
    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        print('Token found, length: ${token.length}');
        print('Token preview: ${token.substring(0, 20)}...');
      } else {
        print('No token found in storage');
      }
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get userId from JWT token
  Future<String?> _getUserIdFromToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print('No token found to decode');
        return null;
      }

      // Use jwt_decoder to decode the token
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] as String?;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getPosts() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      Response response = await _dio.post(
        '/post/get-post',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'error': 'Token đã hết hạn. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }
      return {
        'success': false,
        'error': _handleError(e),
        'data': null,
      };
    } catch (e) {
      print('Error getting posts: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    required String tags,
    String? serviceOptionId,
    XFile? imageFile,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      // Get author ID from token
      final authorId = await _getUserIdFromToken();
      if (authorId == null) {
        throw Exception('Không thể lấy thông tin tác giả');
      }

      FormData formData = FormData.fromMap({
        'Title': title,
        'Content': content,
        'Tags': tags,
        'AuthorId': authorId,
        if (serviceOptionId != null) 'ServiceOptionId': serviceOptionId,
      });

      // Add image if provided
      if (imageFile != null) {
        String fileName = imageFile.name;
        if (kIsWeb) {
          // For web
          final bytes = await imageFile.readAsBytes();
          formData.files.add(MapEntry(
            'ImageFile',
            MultipartFile.fromBytes(
              bytes,
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            ),
          ));
        } else {
          // For mobile
          formData.files.add(MapEntry(
            'ImageFile',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType('image', 'jpeg'),
            ),
          ));
        }
      }

      Response response = await _dio.post(
        '/post/create-post',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Tạo bài đăng thành công',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Tạo bài đăng thất bại',
        };
      }
    } catch (e) {
      print('Error creating post: $e');
      if (e is DioException) {
        return {
          'success': false,
          'message': _handleError(e),
        };
      } else {
        return {
          'success': false,
          'message': e.toString(),
        };
      }
    }
  }

  Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String title,
    required String content,
    required String tags,
    String? serviceOptionId,
    XFile? thumbnailFile,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      FormData formData = FormData.fromMap({
        'Id': postId,
        'Title': title,
        'Content': content,
        'Tags': tags,
        if (serviceOptionId != null) 'ServiceOptionId': serviceOptionId,
      });

      // Add thumbnail image if provided
      if (thumbnailFile != null) {
        String fileName = thumbnailFile.name;
        if (kIsWeb) {
          // For web
          final bytes = await thumbnailFile.readAsBytes();
          formData.files.add(MapEntry(
            'ThumbnailFile',
            MultipartFile.fromBytes(
              bytes,
              filename: fileName,
              contentType: MediaType('image', 'png'),
            ),
          ));
        } else {
          // For mobile
          formData.files.add(MapEntry(
            'ThumbnailFile',
            await MultipartFile.fromFile(
              thumbnailFile.path,
              filename: fileName,
              contentType: MediaType('image', 'png'),
            ),
          ));
        }
      }

      Response response = await _dio.post(
        '/post/update-post',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Cập nhật bài đăng thành công',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Cập nhật bài đăng thất bại',
        };
      }
    } catch (e) {
      print('Error updating post: $e');
      if (e is DioException) {
        return {
          'success': false,
          'message': _handleError(e),
        };
      } else {
        return {
          'success': false,
          'message': e.toString(),
        };
      }
    }
  }

  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      FormData formData = FormData.fromMap({
        'Id': postId,
      });

      Response response = await _dio.post(
        '/post/delete-post',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Xóa bài đăng thành công',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Xóa bài đăng thất bại',
        };
      }
    } catch (e) {
      print('Error deleting post: $e');
      if (e is DioException) {
        return {
          'success': false,
          'message': _handleError(e),
        };
      } else {
        return {
          'success': false,
          'message': e.toString(),
        };
      }
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối quá hạn, vui lòng thử lại';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu quá hạn, vui lòng thử lại';
      case DioExceptionType.receiveTimeout:
        return 'Nhận dữ liệu quá hạn, vui lòng thử lại';
      case DioExceptionType.badResponse:
        return 'Lỗi từ máy chủ: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Yêu cầu bị hủy';
      case DioExceptionType.connectionError:
        return 'Lỗi kết nối, vui lòng kiểm tra lại kết nối mạng';
      default:
        return 'Đã xảy ra lỗi không xác định: ${error.message}';
    }
  }
}
