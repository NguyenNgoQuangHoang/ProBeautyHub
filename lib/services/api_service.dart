import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl =
      'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
  late Dio _dio;

  ApiService() {
    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    int gender = 1, // 1 for male, 0 for female, default to male
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'Name': '$firstName $lastName',
        'Tagname': firstName.toLowerCase(),
        'PhoneNumber': phoneNumber ?? '',
        'Gender': gender,
        'Email': email,
        'Password': password,
        'ConfirmPassword': confirmPassword,
      });

      Response response = await _dio.post(
        '/user-account/register',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
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
      return {
        'success': false,
        'error': _handleError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Đã xảy ra lỗi không xác định: $e',
        'statusCode': null,
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'Email': email,
        'Password': password,
      });

      Response response = await _dio.post(
        '/user-account/login',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Parse response thành UserModel
      UserModel user = UserModel.fromJson(response.data);

      return {
        'success': user.isSuccess,
        'data': user,
        'message': user.message ??
            (user.isSuccess ? 'Đăng nhập thành công' : user.errorMessage),
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Đã xảy ra lỗi không xác định: $e',
        'statusCode': null,
      };
    }
  }

  Future<Map<String, dynamic>> verifyTwoFactorCode({
    required String email,
    required String twoFactorCode,
  }) async {
    try {
      final response = await _dio.post(
        '/user-account/verify-twofactor-code',
        data: {
          'email': email,
          'twoFactorCode': twoFactorCode,
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Parse response thành UserModel
      UserModel user = UserModel.fromJson(response.data);

      return {
        'success': user.isSuccess,
        'data': user,
        'token': response.data['token'], // Thêm token trực tiếp từ response
        'refreshToken': response
            .data['refreshToken'], // Thêm refreshToken trực tiếp từ response
        'isSuccess':
            response.data['isSuccess'], // Thêm isSuccess trực tiếp từ response
        'message': user.message ??
            (user.isSuccess ? 'Xác thực thành công' : user.errorMessage),
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Đã xảy ra lỗi không xác định: $e',
        'statusCode': null,
      };
    }
  }

  // Get cities with authorization
  Future<Map<String, dynamic>> getCities() async {
    try {
      // Get token from storage
      final token = await _getStoredToken();

      if (token == null) {
        print('Warning: No token found for getCities request');
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      print('Making getCities request with token');
      Response response = await _dio.get(
        '/area/get-city',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('getCities response status: ${response.statusCode}');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print(
          'DioException in getCities: ${e.response?.statusCode} - ${e.message}');
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
      print('Error getting cities: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  // Get districts by city name
  Future<Map<String, dynamic>> getDistricts(String cityName) async {
    try {
      // Get token from storage
      final token = await _getStoredToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      Response response = await _dio.post(
        '/area/get-districts',
        data: {
          'city': cityName,
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
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
      print('Error getting districts: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  // Get services with authorization
  Future<Map<String, dynamic>> getServices() async {
    try {
      // Get token from storage
      final token = await _getStoredToken();

      if (token == null) {
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      // Create form data
      FormData formData = FormData.fromMap({
        'Id': '',
        'Name': '',
        'CategoryId': '',
      });

      Response response = await _dio.post(
        '/service/get-service',
        data: formData,
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
      print('Error getting services: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  // Register artist with multipart form data - supports both File and XFile
  Future<Map<String, dynamic>> registerArtist({
    required String userId,
    required String certificateJson,
    required String areaId,
    required int minPrice,
    required int maxPrice,
    required bool termsAccepted,
    required int yearsOfExperience,
    required bool acceptUrgentBooking,
    required String commonCosmetics,
    required List<String> interestedServiceIds,
    required dynamic cccdFrontImage, // Can be File or XFile
    required dynamic cccdBackImage, // Can be File or XFile
    required List<dynamic> portfolioImages, // Can contain File or XFile
  }) async {
    try {
      // Get token from storage
      final token = await _getStoredToken();

      // Create form data
      FormData formData = FormData();

      // Helper function to create MultipartFile from dynamic image
      Future<MultipartFile> createMultipartFile(
          dynamic image, String filename) async {
        if (image is XFile) {
          // For XFile (web and mobile)
          final bytes = await image.readAsBytes();
          return MultipartFile.fromBytes(
            bytes,
            filename: filename,
          );
        } else if (image is File) {
          // For File (mobile only)
          return await MultipartFile.fromFile(
            image.path,
            filename: filename,
          );
        } else {
          throw Exception('Unsupported image type: ${image.runtimeType}');
        }
      }

      // Add CCCD images
      formData.files.add(MapEntry(
        'CCCDFrontImage',
        await createMultipartFile(cccdFrontImage, 'cccd_front.jpg'),
      ));

      formData.files.add(MapEntry(
        'CCCDBackImage',
        await createMultipartFile(cccdBackImage, 'cccd_back.jpg'),
      ));

      // Add portfolio images
      for (int i = 0; i < portfolioImages.length; i++) {
        formData.files.add(MapEntry(
          'PortfolioImages',
          await createMultipartFile(portfolioImages[i], 'portfolio_$i.jpg'),
        ));
      }

      // Create query parameters
      Map<String, dynamic> queryParams = {
        'UserId': userId,
        'CertificateJson': certificateJson,
        'AreaId': areaId,
        'MinPrice': minPrice,
        'MaxPrice': maxPrice,
        'TermsAccepted': termsAccepted,
        'YearsOfExperience': yearsOfExperience,
        'AcceptUrgentBooking': acceptUrgentBooking,
        'CommonCosmetics': commonCosmetics,
        'InterestedServiceIds': interestedServiceIds.join(','),
      };

      Response response = await _dio.post(
        '/user-account/register-artist',
        data: formData,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': token != null ? 'Bearer $token' : null,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error registering artist: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  // Helper method to get stored token
  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print(
          'Getting stored token: ${token != null ? "Token found" : "Token not found"}');
      if (token != null) {
        print('Token length: ${token.length}');
        print('Token preview: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Helper method to get userId from JWT token
  Future<String?> getUserIdFromToken() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        print('No token found to decode');
        return null;
      }

      // Decode JWT token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Lấy userId từ trường 'sub'
      String? userId = decodedToken['sub'];
      print('Decoded userId from token: $userId');

      return userId;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
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
