import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentApiService {
  static const String baseUrl =
      'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
  late Dio _dio;

  AppointmentApiService() {
    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getAppointments() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      // Try GET request first
      try {
        Response response = await _dio.get(
          '/appointment/get-appointment',
          options: Options(
            headers: {
              'accept': '*/*',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        print('Get appointments response (GET): ${response.data}');
        
        return {
          'success': true,
          'data': response.data,
          'statusCode': response.statusCode,
        };
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          // Method not allowed, try POST
          print('GET not allowed, trying POST...');
        } else {
          throw e; // Re-throw other errors
        }
      }

      // If GET fails with 405, try POST
      Map<String, dynamic> requestData = {
        'command': 'get-appointment',
      };

      Response response = await _dio.post(
        '/appointment/get-appointment',
        data: requestData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Get appointments response (POST): ${response.data}');

      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('DioException in getAppointments: ${e.response?.data}');
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
        'data': e.response?.data, // Include response data for debugging
      };
    } catch (e) {
      print('Error getting appointments: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
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
        return 'Lỗi từ máy chủ: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Yêu cầu bị hủy';
      case DioExceptionType.connectionError:
        return 'Lỗi kết nối, vui lòng kiểm tra lại kết nối mạng';
      case DioExceptionType.badCertificate:
        return 'Lỗi chứng chỉ bảo mật';
      default:
        return 'Đã xảy ra lỗi không xác định: ${error.message}';
    }
  }
}
