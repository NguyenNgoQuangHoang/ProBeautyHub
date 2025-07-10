import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeRequest {
  final DateTime startDate;
  final DateTime endDate;
  final int status; // 0: available, 1: busy, etc.

  TimeRequest({
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
    };
  }
}

class ScheduleApiService {
  static const String baseUrl =
      'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
  late Dio _dio;

  ScheduleApiService() {
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
        print('Token found for schedule API, length: ${token.length}');
      } else {
        print('No token found in storage for schedule API');
      }
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<String?> _getArtistIdFromToken() async {
    try {
      final token = await _getStoredToken();
      if (token == null) return null;

      // Decode JWT token to get artist ID
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = json.decode(resp);

      // Get user ID from sub claim
      final artistId = payloadMap['sub'] ??
          payloadMap[
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
      print('Artist ID from token: $artistId');
      return artistId;
    } catch (e) {
      print('Error getting artist ID from token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateAvailability({
    required List<TimeRequest> timeRequests,
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

      final artistId = await _getArtistIdFromToken();
      if (artistId == null) {
        return {
          'success': false,
          'error': 'Không thể lấy thông tin artist. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      final requestData = {
        'artistId': artistId,
        'timeRequests': timeRequests.map((tr) => tr.toJson()).toList(),
      };

      print('Update availability request: $requestData');

      Response response = await _dio.put(
        '/schedule-artist/update-availability',
        data: requestData,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Update availability response: ${response.data}');

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
      print('Error updating availability: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> getArtistSchedule() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Không tìm thấy token xác thực. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      final artistId = await _getArtistIdFromToken();
      if (artistId == null) {
        return {
          'success': false,
          'error': 'Không thể lấy thông tin artist. Vui lòng đăng nhập lại.',
          'data': null,
        };
      }

      Response response = await _dio.get(
        '/schedule-artist/get-schedule/$artistId',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Get artist schedule response: ${response.data}');

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
      print('Error getting artist schedule: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối quá thời gian chờ';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu quá thời gian chờ';
      case DioExceptionType.receiveTimeout:
        return 'Nhận dữ liệu quá thời gian chờ';
      case DioExceptionType.badResponse:
        if (e.response?.data != null) {
          return e.response!.data.toString();
        }
        return 'Lỗi từ server: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy';
      case DioExceptionType.unknown:
        return 'Lỗi kết nối mạng';
      default:
        return 'Có lỗi xảy ra: ${e.message}';
    }
  }
}
