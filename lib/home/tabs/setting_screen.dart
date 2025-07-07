import 'package:booking_app/screens/artist_register/splash_artist_screen.dart';
import 'package:booking_app/screens/auth/login_screen.dart';
import 'package:booking_app/services/user_storage.dart';
import 'package:booking_app/models/user_model.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await UserStorage.getUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshUserInfo() async {
    setState(() {
      _isLoading = true;
    });
    await _loadUserInfo();
  }

  Future<void> _logout() async {
    try {
      // Xóa thông tin user khỏi storage
      await UserStorage.clearUser();

      // Chuyển về màn hình login và xóa tất cả màn hình trước đó
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshUserInfo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  loadingScreen(context, () => SplashArtistScreen());
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: mySecondaryColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.handshake_outlined, size: 15),
                              SizedBox(width: 8),
                              Text(
                                'Tài Khoản Artist',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "JacquesFrancois"),
                              ),
                            ],
                          ),
                          const Icon(Icons.chevron_right, size: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: 'Thông tin cá nhân',
                icon: Icons.edit_note,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _buildInfoRow('Họ và Tên',
                              _currentUser?.name ?? 'Chưa cập nhật'),
                          _buildInfoRow('Điện thoại',
                              _currentUser?.phoneNumber ?? 'Chưa cập nhật'),
                          _buildInfoRow(
                              'Email', _currentUser?.email ?? 'Chưa cập nhật'),
                          _buildInfoRow('Nơi sống',
                              _currentUser?.address ?? 'Chưa cập nhật',
                              hasDivider: false),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: 'Mật khẩu',
                icon: Icons.edit_note,
                padding: const EdgeInsets.all(12),
                child: const SizedBox(height: 0),
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: 'Thông tin khác',
                child: Column(
                  children: [
                    _buildNavRow('Về chúng tôi'),
                    _buildNavRow('Liên hệ hợp tác'),
                    _buildNavRow('Hotline'),
                    _buildNavRow('Điều khoản sử dụng'),
                    _buildNavRow('Chính sách quyền riêng tư',
                        hasDivider: false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      backgroundColor: Colors.white,
                      titlePadding:
                          const EdgeInsets.only(top: 24, left: 24, right: 24),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      actionsPadding: const EdgeInsets.only(
                          bottom: 16, right: 16, left: 16),
                      title: const Text(
                        "Bạn có chắc muốn đăng xuất?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "JacquesFrancois",
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "Đóng",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: "JacquesFrancois",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Đóng dialog trước
                                  _logout(); // Thực hiện đăng xuất
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "Chắc chắn",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: "JacquesFrancois",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: mySecondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: "JacquesFrancois",
                    )),
                const Spacer(),
                if (icon != null)
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(icon, size: 16),
                  )
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool hasDivider = true}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: "JacquesFrancois")),
            Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "JacquesFrancois"),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
        if (hasDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          )
      ],
    );
  }

  Widget _buildNavRow(String title, {bool hasDivider = true}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "JacquesFrancois",
                    color: Colors.black87)),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
        if (hasDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          )
      ],
    );
  }
}
