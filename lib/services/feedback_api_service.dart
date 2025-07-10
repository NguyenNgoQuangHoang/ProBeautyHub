import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackApiService {
  static const String baseUrl =
      'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
  late Dio _dio;

  FeedbackApiService() {
    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> getFeedback({
    String? id,
    String? userId,
    String? artistId,
    String? serviceOptionId,
    String? appoinmentId,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      // Create JSON request body
      Map<String, dynamic> requestData = {
        'id': id,
        'userId': userId,
        'artistId': artistId,
        'serviceOptionId': serviceOptionId,
        'appoinmentId': appoinmentId,
      };

      print('Sending feedback request: $requestData');

      Response response = await _dio.post(
        '/feedback/get-feedback',
        data: requestData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Get feedback response (POST): ${response.data}');

      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('DioException in getFeedback: ${e.response?.data}');
      
      // Kiểm tra có lỗi đặc biệt về feedback không tìm thấy không
      final responseData = e.response?.data;
      if (responseData != null && 
          responseData is Map && 
          responseData['errorMessage'] != null && 
          responseData['errorMessage'].toString().contains('Feedback not found')) {
        return {
          'success': false,
          'error': 'Không tìm thấy đánh giá nào cho artist này',
          'data': e.response?.data,
        };
      }
      
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
      print('Error getting feedback: $e');
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
