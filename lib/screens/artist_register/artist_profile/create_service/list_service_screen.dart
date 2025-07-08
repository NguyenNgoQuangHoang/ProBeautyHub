import 'package:flutter/material.dart';
import 'create_service_screen.dart';
import 'package:booking_app/services/api_service.dart';

class ListServiceScreen extends StatefulWidget {
  const ListServiceScreen({super.key});

  @override
  State<ListServiceScreen> createState() => _ListServiceScreenState();
}

class _ListServiceScreenState extends State<ListServiceScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _serviceOptions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServiceOptions();
  }

  Future<void> _loadServiceOptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.getServiceOptions();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        List<Map<String, dynamic>> serviceOptions = [];

        // Handle different response formats
        if (data is List) {
          serviceOptions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // If data is wrapped in an object, look for common keys
          if (data['serviceOptions'] != null) {
            serviceOptions =
                List<Map<String, dynamic>>.from(data['serviceOptions']);
          } else if (data['data'] != null) {
            serviceOptions = List<Map<String, dynamic>>.from(data['data']);
          } else if (data['items'] != null) {
            serviceOptions = List<Map<String, dynamic>>.from(data['items']);
          } else {
            // If it's a single object, wrap it in a list
            serviceOptions = [Map<String, dynamic>.from(data)];
          }
        }

        setState(() {
          _serviceOptions = serviceOptions;
        });

        print('Loaded ${_serviceOptions.length} service options');
      } else {
        setState(() {
          _error = result['error'] ?? 'Lỗi không xác định';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
      });
      print('Error loading service options: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dịch vụ của tôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadServiceOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateServiceScreen(),
                  ),
                );

                // Refresh list if service was created
                if (result == true) {
                  _loadServiceOptions();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dịch vụ...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServiceOptions,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_serviceOptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có dịch vụ nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để tạo dịch vụ đầu tiên',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: "JacquesFrancois",
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServiceOptions,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
        itemCount: _serviceOptions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final serviceOption = _serviceOptions[index];
          return _buildServiceOptionCard(serviceOption);
        },
      ),
    );
  }

  Widget _buildServiceOptionCard(Map<String, dynamic> serviceOption) {
    final String name = serviceOption['name']?.toString() ?? 'Không có tên';
    final String description = serviceOption['description']?.toString() ?? '';
    final double price = (serviceOption['price'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = serviceOption['imageUrl']?.toString() ?? '';
    final String serviceName = serviceOption['serviceName']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildServiceImage(imageUrl),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "JacquesFrancois",
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (serviceName.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  serviceName,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 11,
                    fontFamily: "JacquesFrancois",
                  ),
                ),
              ),
            Text(
              '${price.toStringAsFixed(0)} VNĐ',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontFamily: "JacquesFrancois",
              ),
            ),
            if (description.isNotEmpty && description != 'string')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: "JacquesFrancois",
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.purple,
        ),
        onTap: () async {
          // TODO: Navigate to edit service screen
          // await loadingScreen(
          //   context,
          //   () => CreateOrEditServiceScreen(
          //     serviceOption: serviceOption,
          //   ),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chỉnh sửa dịch vụ: $name')),
          );
        },
      ),
    );
  }

  Widget _buildServiceImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.image,
          color: Colors.grey.shade400,
          size: 30,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.broken_image,
              color: Colors.grey.shade400,
              size: 30,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
