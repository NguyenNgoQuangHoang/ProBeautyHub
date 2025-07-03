import 'package:dio/dio.dart';
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

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối quá hạn, vui lòng thử lại';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu quá hạn, vui lòng thử lại';
      case DioExceptionType.receiveTimeout:
        return 'Nhận dữ liệu quá hạn, vui lòng thử lại';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 400) {
          return 'Dữ liệu không hợp lệ, vui lòng kiểm tra lại';
        } else if (error.response?.statusCode == 409) {
          return 'Email đã được sử dụng, vui lòng chọn email khác';
        } else if (error.response?.statusCode == 500) {
          return 'Lỗi máy chủ, vui lòng thử lại sau';
        }
        return 'Lỗi: ${error.response?.statusCode}';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối internet';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }
}
