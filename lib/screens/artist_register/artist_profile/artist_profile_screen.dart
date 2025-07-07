import 'package:booking_app/screens/artist_register/artist_profile/create_post/post_screen.dart';
import 'package:booking_app/screens/profiles/tabcontent/post_article_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/artist_dashboard/artist_dashboard_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_post/post_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_promotion/promotion_screen.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_schedule/create_schedule_screen.dart';
import 'package:booking_app/screens/profiles/profiles_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

import 'create_post/create_post_screen.dart';
import 'create_service/service_artist_screen.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
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
      body: Column(
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
                        "LỊCH HẸN",
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
                                      bookingData: [], // Truyền dữ liệu thật vào đây nếu có
                                      onViewAllPress: () {}, // hoặc xử lý riêng
                                      onBookingPress:
                                          (booking) {}, // xử lý khi nhấn vào từng booking
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildAppointmentCard('Chờ xác nhận'),
                      buildAppointmentCard('Đã xác nhận'),
                      buildAppointmentCard('Hoàn thành'),
                      buildAppointmentCard('Đã hủy'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // Quản lý trang
          Expanded(
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Widget buildAppointmentCard(String title) {
    return Container(
      width: 80,
      height: 80,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 228, 222, 227),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "10",
            style: TextStyle(
              fontSize: 18,
              fontFamily: "JacquesFrancois",
              color: Color(0xFFE6A57E),
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
