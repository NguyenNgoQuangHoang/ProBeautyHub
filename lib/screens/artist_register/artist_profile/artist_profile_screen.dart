import 'package:booking_app/screens/artist_register/artist_profile/create_post/post_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/artist_dashboard/artist_dashboard_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_promotion/promotion_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_schedule/create_schedule_screen.dart';
import 'package:booking_app/screens/profiles/profiles_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:booking_app/services/appointment_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../providers/auth_provider.dart';

import 'create_service/service_artist_screen.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  final AppointmentApiService _appointmentApiService = AppointmentApiService();
  
  Map<String, int> _appointmentCounts = {
    'Pending': 0,
    'Confirmed': 0,
    'Completed': 0,
    'Refunded': 0,
  };
  
  bool _isLoadingAppointments = true;
  List<dynamic> _appointments = [];
  String? _userId; // Lưu trữ userId của artist hiện tại

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _isLoadingAppointments = true;
      });

      print('Loading appointments for artist: $_userId');
      
      // Chỉ gọi API nếu có userId (artistId)
      if (_userId == null || _userId!.isEmpty) {
        print('No artist ID available, skipping API call');
        setState(() {
          _appointments = []; // Xóa dữ liệu cũ
          _isLoadingAppointments = false;
          _processAppointmentCounts([]); // Reset counts
        });
        return;
      }

      // Gọi API với artistId (chính là userId của artist hiện tại)
      print('Calling getAppointments API with artistId: $_userId');
      final result = await _appointmentApiService.getAppointments(
        artistId: _userId, // Truyền userId làm artistId
      );
      
      if (result['success']) {
        final data = result['data'];
        List<dynamic> appointments = [];
        
        // Handle different response structures
        if (data is Map<String, dynamic>) {
          if (data.containsKey('appointments')) {
            appointments = data['appointments'] ?? [];
          } else if (data.containsKey('data')) {
            appointments = data['data'] ?? [];
          } else if (data.containsKey('items')) {
            appointments = data['items'] ?? [];
          }
        } else if (data is List) {
          appointments = data;
        }

        print('Loaded ${appointments.length} appointments for artist $_userId');
        _processAppointmentCounts(appointments);
        
        setState(() {
          _appointments = appointments;
          _isLoadingAppointments = false;
        });
      } else {
        print('Failed to load appointments: ${result['error']}');
        setState(() {
          _appointments = [];
          _processAppointmentCounts([]);
          _isLoadingAppointments = false;
        });
      }
    } catch (e) {
      print('Exception in _loadAppointments: $e');
      setState(() {
        _appointments = [];
        _processAppointmentCounts([]);
        _isLoadingAppointments = false;
      });
    }
  }

  Future<void> _refreshAppointments() async {
    // Khi làm mới, cố gắng lấy lại userId để đảm bảo đúng artist hiện tại
    await _getUserIdAndLoadAppointments();
  }

  void _processAppointmentCounts(List<dynamic> appointments) {
    // Reset counts
    _appointmentCounts = {
      'Pending': 0,
      'Confirmed': 0,
      'Completed': 0,
      'Cancelled': 0, // Thay đổi từ 'Refunded' thành 'Cancelled'
    };
    
    // Count appointments by status
    for (var appointment in appointments) {
      final status = appointment['status']?.toString().toLowerCase() ?? '';
      if (status == 'pending') {
        _appointmentCounts['Pending'] = _appointmentCounts['Pending']! + 1;
      } else if (status == 'confirmed') {
        _appointmentCounts['Confirmed'] = _appointmentCounts['Confirmed']! + 1;
      } else if (status == 'completed') {
        _appointmentCounts['Completed'] = _appointmentCounts['Completed']! + 1;
      } else if (['canceled', 'cancelled', 'refunded', 'rejected'].contains(status)) {
        _appointmentCounts['Cancelled'] = _appointmentCounts['Cancelled']! + 1;
      }
    }
    
    print('Appointment counts: $_appointmentCounts');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mySecondaryColor,
      appBar: AppBar(
        backgroundColor: myPrimaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
          // Profile header
          Container(
            color: myPrimaryColor,
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
              title: Text('Demi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: "JacquesFrancois",
                      color: Colors.yellow)),
              subtitle: Text(
                '100 người theo dõi',
                style: TextStyle(
                    color: Colors.white70, fontFamily: "JacquesFrancois"),
              ),
              trailing: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilesScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Xem trang",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "JacquesFrancois",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Lịch hẹn
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "LỊCH HẸN CỦA TÔI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "JacquesFrancois",
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ArtistDashboardScreen(
                                      bookingData: _appointments.cast<Map<String, dynamic>>(), // Truyền dữ liệu thật từ API
                                      onViewAllPress: () {},
                                      onBookingPress: (booking) {},
                                    )),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "Xem tất cả",
                              style: TextStyle(
                                color: Color(0xFFE6A57E),
                                fontFamily: "JacquesFrancois",
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios,
                                size: 14, color: Color(0xFFE6A57E)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _isLoadingAppointments
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                SizedBox(height: 8),
                                Text(
                                  _userId != null 
                                      ? 'Đang tải lịch hẹn...'
                                      : 'Đang lấy thông tin artist...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _appointments.isEmpty && _userId == null
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.grey, size: 32),
                                    SizedBox(height: 8),
                                    Text(
                                      'Không thể tải lịch hẹn',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Vui lòng đăng nhập lại',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildAppointmentCard('Chờ xác nhận', 'Pending'),
                              buildAppointmentCard('Đã xác nhận', 'Confirmed'),
                              buildAppointmentCard('Hoàn thành', 'Completed'),
                              buildAppointmentCard('Đã hủy', 'Cancelled'),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // Quản lý trang
          Container(
            height: MediaQuery.of(context).size.height * 0.6, // Set fixed height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
            ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "QUẢN LÝ TRANG",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontFamily: "JacquesFrancois",
                      ),
                    ),
                    SizedBox(height: 8),
                    buildMenuItem(Icons.image, "Bài viết (100)", onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostScreen()),
                      );
                    }),
                    buildMenuItem(Icons.image, "Lịch", onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateDateScreen()),
                      );
                    }),
                    buildMenuItem(Icons.image, "Khuyến mãi", onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PromotionScreen()),
                      );
                    }),
                    buildMenuItem(Icons.design_services, "Dịch vụ", onTap: () {
                      loadingScreen(context, () => ServiceArtistScreen());
                    }),
                    buildMenuItem(Icons.person_outline, "Tài khoản"),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppointmentCard(String title, String status) {
    final count = _appointmentCounts[status] ?? 0;
    
    return GestureDetector(
      onTap: () {
        // Filter appointments by status and navigate to detail screen
        List<Map<String, dynamic>> filteredAppointments;
        
        if (status == 'Cancelled') {
          // For cancelled, include all cancelled-like statuses
          filteredAppointments = _appointments
              .where((apt) => {
                'canceled', 'cancelled', 'refunded', 'rejected'
              }.contains(apt['status']?.toString().toLowerCase()))
              .toList()
              .cast<Map<String, dynamic>>();
        } else {
          // For other statuses, exact match
          final statusToMatch = status.toLowerCase();
          filteredAppointments = _appointments
              .where((apt) => apt['status']?.toString().toLowerCase() == statusToMatch)
              .toList()
              .cast<Map<String, dynamic>>();
        }
            
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDashboardScreen(
              bookingData: filteredAppointments,
              onViewAllPress: () {},
              onBookingPress: (booking) {},
            ),
          ),
        );
      },
      child: Container(
        width: 85,
        height: 80,
        margin: EdgeInsets.only(right: 8, left: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 228, 222, 227),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: count > 0 ? Color(0xFFE6A57E) : Colors.transparent,
            width: count > 0 ? 1 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontFamily: "JacquesFrancois",
                color: Color(0xFFE6A57E),
                fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: "JacquesFrancois",
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "JacquesFrancois",
              color: Colors.black,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap, // ⬅ cho phép click
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
        ),
      ],
    );
  }
}
