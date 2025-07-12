import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../../services/appointment_api_service.dart';
import '../../../../providers/auth_provider.dart';

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
  String? _userId; // Lưu trữ userId của artist hiện tại

  @override
  void initState() {
    super.initState();
    // Use passed data first, then load from API
    _appointments = widget.bookingData;
    _getUserIdAndLoadAppointments();
  }

  // Lấy userId từ các nguồn khả dụng
  Future<void> _getUserIdAndLoadAppointments() async {
    try {
      // Thử lấy từ SharedPreferences trước
      String? userId = await _getUserIdFromPrefs();
      
      // Nếu không có, thử lấy từ AuthProvider
      if ((userId == null || userId.isEmpty) && mounted) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.currentUser?.id != null && authProvider.currentUser!.id!.isNotEmpty) {
            userId = authProvider.currentUser!.id;
            print('Found user ID from AuthProvider: $userId');
          }
        } catch (providerError) {
          print('Cannot access AuthProvider: $providerError');
        }
      }

      if (mounted) {
        setState(() {
          _userId = userId;
        });
      }
      
      print('Using artist ID for appointments: $_userId');
      await _loadAppointments();
    } catch (e) {
      print('Error getting user ID: $e');
      // Vẫn tải appointments để không bị lỗi UI
      await _loadAppointments();
    }
  }

  Future<String?> _getUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Thử lấy từ các khóa phổ biến
      final userId = prefs.getString('user_id') ?? 
                   prefs.getString('userId') ?? 
                   prefs.getString('id') ??
                   prefs.getString('user_data');
      
      if (userId != null && userId.isNotEmpty) {
        if (userId.startsWith('{')) {
          // Có thể là JSON string, thử parse ra
          try {
            final Map<String, dynamic> userData = jsonDecode(userId);
            final extractedId = userData['id'];
            if (extractedId != null) {
              print('Found user ID from JSON: $extractedId');
              return extractedId.toString();
            }
          } catch (e) {
            print('Error parsing user data JSON: $e');
          }
        } else {
          print('Found user ID: $userId');
          return userId;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user ID from prefs: $e');
      return null;
    }
  }

  Future<void> _loadAppointments() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      print('Loading appointments for artist: $_userId');
      
      // Chỉ gọi API nếu có userId (artistId)
      if (_userId == null || _userId!.isEmpty) {
        print('No artist ID available, skipping API call');
        if (mounted) {
          setState(() {
            _appointments = []; // Xóa dữ liệu cũ
            _isLoading = false;
            _error = 'Không tìm thấy thông tin artist';
          });
        }
        return;
      }
      
      // Gọi API với artistId (chính là userId của artist hiện tại)
      print('Calling getAppointments API with artistId: $_userId');
      final result = await _appointmentApiService.getAppointments(
        artistId: _userId, // Truyền userId làm artistId
      );
      print('API response received: ${result['success']}');
      
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
          } else if (data.containsKey('items')) {
            final appointmentList = data['items'] as List<dynamic>;
            appointments = appointmentList.cast<Map<String, dynamic>>();
            print('Found appointments in data.items: ${appointments.length}');
          }
        } else if (data is List) {
          appointments = data.cast<Map<String, dynamic>>();
          print('Found appointments as direct list: ${appointments.length}');
        }

        print('Loaded ${appointments.length} appointments for artist $_userId');
        
        // Debug: In thông tin một số appointment đầu tiên
        for (var apt in appointments.take(3)) {
          print('Appointment: ${apt['customerName']} - Status: ${apt['status']} - Date: ${apt['appointmentDate']}');
        }

        if (mounted) {
          setState(() {
            _appointments = appointments;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = result['error'] ?? 'Có lỗi xảy ra khi tải lịch hẹn';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Exception in _loadAppointments: $e');
      if (mounted) {
        setState(() {
          _error = 'Có lỗi xảy ra: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshAppointments() async {
    // Khi làm mới, cố gắng lấy lại userId để đảm bảo đúng artist hiện tại
    await _getUserIdAndLoadAppointments();
  }

  // Hiển thị dialog xác nhận hủy lịch hẹn
  Future<void> _showCancelConfirmationDialog(Map<String, dynamic> appointment) async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận hủy lịch hẹn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
              SizedBox(height: 8),
              Text(
                'Khách hàng: ${appointment['customerName'] ?? 'Không rõ'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Ngày: ${formatDate(appointment['appointmentDate'])}',
                style: TextStyle(color: textSecondary),
              ),
              if (appointment['appointmentDetails'] != null && 
                  appointment['appointmentDetails'].isNotEmpty)
                Text(
                  'Dịch vụ: ${appointment['appointmentDetails'][0]['serviceOptionName'] ?? 'Không rõ'}',
                  style: TextStyle(color: textSecondary),
                ),
              SizedBox(height: 8),
              Text(
                'Lưu ý: Hành động này không thể hoàn tác.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hủy lịch hẹn'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      await _cancelAppointment(appointment);
    }
  }

  // Xử lý hủy lịch hẹn
  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Đang hủy lịch hẹn...'),
              ],
            ),
          );
        },
      );

      final appointmentId = appointment['id']?.toString();
      if (appointmentId == null || appointmentId.isEmpty) {
        Navigator.of(context).pop(); // Đóng loading dialog
        _showErrorDialog('Không tìm thấy ID lịch hẹn');
        return;
      }

      final result = await _appointmentApiService.cancelAppointment(appointmentId);
      
      Navigator.of(context).pop(); // Đóng loading dialog

      if (result['success']) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy lịch hẹn thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh danh sách lịch hẹn
        await _refreshAppointments();
      } else {
        _showErrorDialog(result['error'] ?? 'Có lỗi xảy ra khi hủy lịch hẹn');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Đóng loading dialog nếu còn mở
      _showErrorDialog('Có lỗi xảy ra: $e');
    }
  }

  // Hiển thị dialog lỗi
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
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
                  Text("Lịch hẹn của tôi",
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
              SizedBox(height: 4),
              Text(appointmentSummary,
                  style: TextStyle(
                      fontSize: 12,
                      color: textSecondary)),
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
                        _userId != null 
                            ? 'Hiện tại chưa có lịch hẹn nào cho artist này'
                            : 'Không thể tải lịch hẹn, vui lòng đăng nhập lại',
                        style: TextStyle(color: textSecondary),
                        textAlign: TextAlign.center,
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
    final canCancel = ['pending', 'confirmed'].contains(item['status']?.toString().toLowerCase());
    
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
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
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
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
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
                    if (canCancel) ...[
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showCancelConfirmationDialog(item),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ],
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
            // Hiển thị tooltip cho nút hủy nếu có thể hủy
            if (canCancel) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Nhấn vào biểu tượng hủy để hủy lịch hẹn',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
