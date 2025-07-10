import 'package:flutter/material.dart';
import '../../../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final ApiService _apiService = ApiService();
  final currencyFormatter = NumberFormat.currency(symbol: 'VND');
  
  List<dynamic> _services = [];
  List<dynamic> _filteredServices = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _filteredServices = services; // Initialize filtered services
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

  void _filterServices() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredServices = _services;
      } else {
        _filteredServices = _services.where((service) {
          final name = (service['name'] ?? service['title'] ?? '').toString().toLowerCase();
          final description = (service['description'] ?? '').toString().toLowerCase();
          final category = (service['categoryName'] ?? service['category'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          
          return name.contains(query) || 
                 description.contains(query) || 
                 category.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang tải dịch vụ...',
              style: TextStyle(
                fontFamily: "JacquesFrancois",
                color: Colors.grey[600],
              ),
            ),
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
              'Lỗi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: "JacquesFrancois",
                ),
                textAlign: TextAlign.center,
              ),
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
          children: [
            Icon(Icons.spa, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có dịch vụ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hiện tại chưa có dịch vụ nào được cung cấp',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: "JacquesFrancois",
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshServices,
              child: Text('Làm mới'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterServices();
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dịch vụ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300!),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return _buildServiceItem(service, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service, BuildContext context) {
    // Get service data with fallback values
    final title = service['name'] ?? service['title'] ?? 'Không có tên';
    final price = _parsePrice(service['price']);
    final imageUrl = service['imageUrl'] ?? service['image'] ?? 'assets/images/content.png';
    final description = service['description'] ?? '';
    final duration = service['duration'] ?? 0;
    final categoryName = service['categoryName'] ?? service['category'] ?? '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              title: title,
              price: price,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: imageUrl.startsWith('assets/')
                    ? Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImagePlaceholder();
                        },
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "JacquesFrancois",
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "JacquesFrancois",
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: "JacquesFrancois",
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (duration > 0) ...[
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${duration}p',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "JacquesFrancois",
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (categoryName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: "JacquesFrancois",
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: Icon(
        Icons.spa,
        color: Colors.grey[400],
        size: 30,
      ),
    );
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  String _formatPrice(double price) {
    if (price == 0) return 'Miễn phí';
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    ) + ' VND';
  }
}
