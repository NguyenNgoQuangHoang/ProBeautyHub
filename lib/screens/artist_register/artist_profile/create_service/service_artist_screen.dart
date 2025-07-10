import 'package:booking_app/screens/artist_register/artist_profile/create_service/create_service_screen.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:flutter/material.dart';

class ServiceArtistScreen extends StatefulWidget {
  const ServiceArtistScreen({super.key});

  @override
  State<ServiceArtistScreen> createState() => _ServiceArtistScreenState();
}

class _ServiceArtistScreenState extends State<ServiceArtistScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _apiService.getServices();

      if (result['success']) {
        final data = result['data'];
        List<dynamic> services = [];

        // Handle different response structures
        if (data is Map<String, dynamic>) {
          if (data.containsKey('serviceDTOs')) {
            services = data['serviceDTOs'] ?? [];
          } else if (data.containsKey('services')) {
            services = data['services'] ?? [];
          } else if (data.containsKey('data')) {
            services = data['data'] ?? [];
          }
        } else if (data is List) {
          services = data;
        }

        setState(() {
          _services = services;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Có lỗi xảy ra khi tải dịch vụ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Có lỗi xảy ra: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshServices() async {
    await _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dịch vụ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshServices,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateServiceScreen(),
            ),
          );
          // Refresh services if a new service was created
          if (result == true) {
            _refreshServices();
          }
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey),
        ),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
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
              'Lỗi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red,
                fontFamily: "JacquesFrancois",
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshServices,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Trống',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: "JacquesFrancois")),
            SizedBox(height: 8),
            Text('Hiện tại chưa có dịch vụ nào',
                style: TextStyle(
                    color: Colors.black, fontFamily: "JacquesFrancois")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service['name'] ?? 'Không có tên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "JacquesFrancois",
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editService(service);
                        break;
                      case 'delete':
                        _deleteService(service);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (service['description'] != null &&
                service['description'].toString().isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                service['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: "JacquesFrancois",
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green),
                Text(
                  '${_formatPrice(service['price'])} VND',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontFamily: "JacquesFrancois",
                  ),
                ),
                Spacer(),
                Icon(Icons.schedule, size: 16, color: Colors.blue),
                Text(
                  '${service['duration'] ?? 0} phút',
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: "JacquesFrancois",
                  ),
                ),
              ],
            ),
            if (service['categoryName'] != null) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service['categoryName'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontFamily: "JacquesFrancois",
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    if (price is String) {
      try {
        price = double.parse(price);
      } catch (e) {
        return '0';
      }
    }
    if (price is int) {
      price = price.toDouble();
    }
    if (price is double) {
      return price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return '0';
  }

  void _editService(Map<String, dynamic> service) {
    // TODO: Navigate to edit service screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa dịch vụ: ${service['name']}')),
    );
  }

  void _deleteService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content:
              Text('Bạn có chắc chắn muốn xóa dịch vụ "${service['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeleteService(service);
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteService(Map<String, dynamic> service) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Đang xóa dịch vụ...'),
              ],
            ),
          );
        },
      );

      final result = await _apiService.deleteService(service['id']);

      // Hide loading dialog
      Navigator.of(context).pop();

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa dịch vụ: ${service['name']}'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the services list
        _refreshServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Có lỗi xảy ra khi xóa dịch vụ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog if still showing
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
