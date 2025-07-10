import 'package:flutter/material.dart';
import 'package:booking_app/services/promotion_api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final PromotionApiService _promotionApiService = PromotionApiService();
  String _result = '';
  bool _isLoading = false;

  Future<void> _testGetServices() async {
    setState(() {
      _isLoading = true;
      _result = 'Đang test API getServices...\n';
    });

    try {
      final result = await _promotionApiService.getServices();
      setState(() {
        _result += 'Kết quả getServices:\n';
        _result += 'Success: ${result['success']}\n';
        if (result['success']) {
          _result += 'Data: ${result['data']}\n';
          // Parse and show services
          final data = result['data'];
          if (data is Map<String, dynamic>) {
            if (data.containsKey('serviceDTOs')) {
              final services = data['serviceDTOs'] as List?;
              _result += 'Số lượng services: ${services?.length ?? 0}\n';
              if (services != null && services.isNotEmpty) {
                for (int i = 0; i < services.length && i < 3; i++) {
                  final service = services[i];
                  _result += 'Service ${i + 1}: ${service['name'] ?? 'N/A'}\n';
                }
              }
            }
          }
        } else {
          _result += 'Error: ${result['error']}\n';
        }
      });
    } catch (e) {
      setState(() {
        _result += 'Lỗi getServices: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetPromotions() async {
    setState(() {
      _isLoading = true;
      _result = 'Đang test API getPromotions...\n';
    });

    try {
      final result = await _promotionApiService.getPromotions();
      setState(() {
        _result += 'Kết quả getPromotions:\n';
        _result += 'Success: ${result['success']}\n';
        if (result['success']) {
          _result += 'Data: ${result['data']}\n';
          // Parse and show promotions
          final data = result['data'];
          if (data is Map<String, dynamic>) {
            if (data.containsKey('promotionDTOs')) {
              final promotions = data['promotionDTOs'] as List?;
              _result += 'Số lượng promotions: ${promotions?.length ?? 0}\n';
              if (promotions != null && promotions.isNotEmpty) {
                for (int i = 0; i < promotions.length && i < 3; i++) {
                  final promotion = promotions[i];
                  _result +=
                      'Promotion ${i + 1}: ${promotion['title'] ?? 'N/A'}\n';
                }
              }
            } else if (data.containsKey('promotions')) {
              final promotions = data['promotions'] as List?;
              _result += 'Số lượng promotions: ${promotions?.length ?? 0}\n';
            }
          } else if (data is List) {
            _result += 'Số lượng promotions: ${data.length}\n';
          }
        } else {
          _result += 'Error: ${result['error']}\n';
        }
      });
    } catch (e) {
      setState(() {
        _result += 'Lỗi getPromotions: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.purple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Get Services'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetPromotions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Get Promotions'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Chưa có kết quả...' : _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
