import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromotionApiService {
  static const String baseUrl =
      'https://flawless-a2exc2hwcge8bbfz.canadacentral-01.azurewebsites.net/api';
  late Dio _dio;

  PromotionApiService() {
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
        print('Token found for promotion API, length: ${token.length}');
      } else {
        print('No token found in storage for promotion API');
      }
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getServices() async {
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
        '/service/get-service',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Get services response: ${response.data}');

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

  Future<Map<String, dynamic>> createPromotion({
    required String serviceId,
    required String title,
    required String description,
    required double discountPercent,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      FormData formData = FormData.fromMap({
        'ServiceId': serviceId,
        'Title': title,
        'Description': description,
        'DiscountPercent': discountPercent,
        'StartDate': startDate.toIso8601String(),
        'EndDate': endDate.toIso8601String(),
      });

      Response response = await _dio.post(
        '/promotion/create',
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
          'message': 'Tạo khuyến mãi thành công',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Tạo khuyến mãi thất bại',
        };
      }
    } catch (e) {
      print('Error creating promotion: $e');
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

  Future<Map<String, dynamic>> getPromotions() async {
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
        '/voucher/get-voucher',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Get promotions response: ${response.data}');

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
      print('Error getting promotions: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> getVouchers() async {
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
        '/voucher/get-voucher',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Get vouchers response: ${response.data}');

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
      print('Error getting vouchers: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> createVoucher({
    required String serviceOptionId,
    required int voucherType,
    required int currentUsage,
    required DateTime endDate,
    required int minTotalAmount,
    required int discountStype,
    required String code,
    required int discountValue,
    required DateTime startDate,
    required String creatorId,
    required int discountType,
    required String description,
    required int minQuantity,
    required int maxUsage,
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
      FormData formData = FormData.fromMap({
        'ServiceOptionId': serviceOptionId,
        'VoucherType': voucherType,
        'CurrentUsage': currentUsage,
        'EndDate': endDate.toIso8601String(),
        'MinTotalAmount': minTotalAmount,
        'DiscountStype': discountStype,
        'Code': code,
        'DiscountValue': discountValue,
        'StartDate': startDate.toIso8601String(),
        'CreatordId': creatorId,
        'DiscountType': discountType,
        'Description': description,
        'MinQuantity': minQuantity,
        'MaxUsage': maxUsage,
      });
      Response response = await _dio.post(
        '/voucher/create-voucher',
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
          'message': 'Tạo voucher thành công',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Tạo voucher thất bại',
        };
      }
    } catch (e) {
      print('Error creating voucher: $e');
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

  String _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      switch (statusCode) {
        case 400:
          return 'Yêu cầu không hợp lệ';
        case 401:
          return 'Không có quyền truy cập';
        case 403:
          return 'Bị cấm truy cập';
        case 404:
          return 'Không tìm thấy dữ liệu';
        case 500:
          return 'Lỗi máy chủ';
        default:
          return 'Lỗi: ${e.response!.data}';
      }
    } else {
      return 'Lỗi kết nối: ${e.message}';
    }
  }
}
