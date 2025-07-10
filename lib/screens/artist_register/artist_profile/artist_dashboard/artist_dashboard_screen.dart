import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/appointment_api_service.dart';

class ArtistDashboardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> bookingData;
  final VoidCallback onViewAllPress;
  final Function(Map<String, dynamic>) onBookingPress;

  const ArtistDashboardScreen({
    super.key,
    required this.bookingData,
    required this.onViewAllPress,
    required this.onBookingPress,
  });

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen> {
  final AppointmentApiService _appointmentApiService = AppointmentApiService();
  
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Use passed data first, then load from API
    _appointments = widget.bookingData;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _appointmentApiService.getAppointments();
      
      if (result['success']) {
        final data = result['data'];
        List<Map<String, dynamic>> appointments = [];
        
        // Handle different response structures
        if (data is Map<String, dynamic>) {
          if (data.containsKey('appointments')) {
            final appointmentList = data['appointments'] as List<dynamic>;
            appointments = appointmentList.cast<Map<String, dynamic>>();
            print('Found appointments in data.appointments: ${appointments.length}');
          } else if (data.containsKey('data')) {
            final appointmentList = data['data'] as List<dynamic>;
            appointments = appointmentList.cast<Map<String, dynamic>>();
            print('Found appointments in data.data: ${appointments.length}');
          }
        } else if (data is List) {
          appointments = data.cast<Map<String, dynamic>>();
          print('Found appointments as direct list: ${appointments.length}');
        }

        print('Loaded ${appointments.length} appointments');
        for (var apt in appointments.take(3)) {
          print('Appointment: ${apt['customerName']} - Status: ${apt['status']}');
        }

        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Có lỗi xảy ra khi tải lịch hẹn';
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

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  final Color primary = const Color(0xFFBD9EB7);
  final Color background = const Color(0xFFFCF5FA);
  final Color textPrimary = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color white = Colors.white;
  final Color black = Colors.black;

  String formatDate(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) return '';
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM HH:mm').format(date);
    } catch (e) {
      return dateString ?? '';
    }
  }

  String formatCurrency(dynamic amount) {
    try {
      if (amount == null) return '0₫';
      int value = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
      final formatCurrency = NumberFormat.currency(symbol: '₫');
      return formatCurrency.format(value);
    } catch (e) {
      return '${amount ?? 0}₫';
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'canceled':
      case 'cancelled':
        return 'Đã hủy';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'refunded':
        return Colors.purple;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.grey;
      default:
        return textSecondary;
    }
  }

  List<Map<String, dynamic>> get sortedAppointments {
    final sorted = List<Map<String, dynamic>>.from(_appointments);
    sorted.sort((a, b) {
      final dateA = DateTime.tryParse(a['appointmentDate'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['appointmentDate'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA); // Most recent first
    });
    return sorted;
  }

  String get appointmentSummary {
    if (_appointments.isEmpty) return 'Chưa có lịch hẹn';
    final total = _appointments.length;
    final pending = _appointments.where((a) => a['status']?.toString().toLowerCase() == 'pending').length;
    final completed = _appointments.where((a) => a['status']?.toString().toLowerCase() == 'completed').length;
    
    return 'Tổng: $total | Chờ: $pending | Hoàn thành: $completed';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primary),
              SizedBox(height: 16),
              Text(
                'Đang tải lịch hẹn...',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Lỗi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshAppointments,
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final pending = _appointments.where((b) => b['status']?.toString().toLowerCase() == 'pending').length;
    final confirmed = _appointments.where((b) => b['status']?.toString().toLowerCase() == 'confirmed').length;
    final completed = _appointments.where((b) => b['status']?.toString().toLowerCase() == 'completed').length;
    final cancelled = _appointments.where((b) => {
      'canceled', 'cancelled', 'refunded', 'rejected'
    }.contains(b['status']?.toString().toLowerCase())).length;

    print('Statistics: Pending: $pending, Confirmed: $confirmed, Completed: $completed, Cancelled: $cancelled');

    return Scaffold(
      backgroundColor: background,
      body: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lịch hẹn",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  TextButton(
                    onPressed: widget.onViewAllPress,
                    child: Text("Xem tất cả", style: TextStyle(color: primary)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildStatCard("Chờ xác nhận", pending),
                    buildStatCard("Đã xác nhận", confirmed),
                    buildStatCard("Hoàn thành", completed),
                    buildStatCard("Đã hủy", cancelled),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text("Lịch hẹn gần đây",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary)),
              SizedBox(height: 8),
              if (_appointments.isEmpty)
                Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có lịch hẹn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hiện tại chưa có lịch hẹn nào',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ...sortedAppointments.take(3).map((item) => _buildAppointmentCard(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String label, int value) {
    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: textPrimary)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => widget.onBookingPress(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: primary),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['customerName'] ?? "Khách hàng #${item['id']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimary),
                        ),
                        if (item['appointmentDetails'] != null && 
                            item['appointmentDetails'].isNotEmpty)
                          Text(
                            item['appointmentDetails'][0]['serviceOptionName'] ?? 'Dịch vụ',
                            style: TextStyle(color: textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(item['status'] ?? '').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusText(item['status'] ?? ''),
                    style: TextStyle(
                        color: getStatusColor(item['status'] ?? ''),
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Details
            Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: textSecondary),
              SizedBox(width: 8),
              Text(formatDate(item['appointmentDate'] ?? DateTime.now().toString()),
                  style: TextStyle(color: textSecondary)),
            ]),
            SizedBox(height: 6),
            Row(children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(item['address'] ?? 'Không có địa chỉ',
                    style: TextStyle(color: textSecondary),
                    maxLines: 1),
              ),
            ]),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatCurrency(item['totalAmountAfterDiscount'] ?? item['totalAmount'] ?? 0),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
                Icon(Icons.chevron_right,
                    size: 16, color: textSecondary),
              ],
            ),
            if (item['note'] != null && item['note'].toString().isNotEmpty) ...[
              SizedBox(height: 6),
              Row(children: [
                Icon(Icons.note_outlined, size: 16, color: textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(item['note'],
                      style: TextStyle(color: textSecondary, fontSize: 12),
                      maxLines: 1),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
