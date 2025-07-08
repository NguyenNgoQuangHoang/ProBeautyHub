import 'package:booking_app/models/user_model.dart';
import 'package:booking_app/screens/artist_register/artist_profile/artist_profile_screen.dart';
import 'package:booking_app/screens/artist_register/splash_artist_screen.dart';
import 'package:booking_app/screens/auth/login_screen.dart';
import 'package:booking_app/services/user_storage.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger reload when dependencies change
    if (!_isLoading && _currentUser == null) {
      _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final localUser = await UserStorage.getUser();
    final token = await UserStorage.getToken();

    if (localUser == null || token == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy thông tin người dùng hoặc token.';
        _isLoading = false;
      });
      return;
    }

    final apiResult = await UserStorage.fetchUserProgress(
      userId: localUser.id ?? '',
      pageNumber: 1,
      pageSize: 1,
      token: token,
    );

    print('[fetchUserProgress] API response: $apiResult');

    if (apiResult['success'] == true &&
        apiResult['data'] != null &&
        apiResult['data']['users'] != null &&
        (apiResult['data']['users'] as List).isNotEmpty) {
      final userJson = (apiResult['data']['users'] as List).first;

      final mergedUser = UserModel.fromJson(userJson).copyWith(
        token: localUser.token,
        refreshToken: localUser.refreshToken,
        role: localUser.role,
        isSuccess: true,
      );

      setState(() {
        _currentUser = mergedUser;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = apiResult['error']?.toString() ??
            'Không lấy được dữ liệu người dùng.';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await UserStorage.clearUser();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadUserInfo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildRegisterBanner(),
              const SizedBox(height: 20),
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildCard(
                title: 'Mật khẩu',
                icon: Icons.lock_outline,
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
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Đăng xuất',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterBanner() {
    return GestureDetector(
      onTap: () async {
        if (_isLoading) return;

        final role = _currentUser?.role?.toLowerCase();
        print('[DEBUG] User role: ${_currentUser?.role}');

        if (role == '1' || role == 'artist') {
          loadingScreen(context, () => ArtistProfileScreen());
        } else if (role == '2' || role == 'customer') {
          loadingScreen(context, () => SplashArtistScreen());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Không xác định được vai trò người dùng')),
          );
        }
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: mySecondaryColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.handshake_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                'Tài Khoản Artist',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + Edit
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: _currentUser?.imageUrl != null &&
                          _currentUser!.imageUrl!.isNotEmpty
                      ? NetworkImage(_currentUser!.imageUrl!)
                      : null,
                  child: _currentUser?.imageUrl == null ||
                          _currentUser!.imageUrl!.isEmpty
                      ? Icon(Icons.person, size: 48, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 20, color: Colors.purple),
                      onPressed: _currentUser == null
                          ? null
                          : () async {
                              final nameController = TextEditingController(
                                  text: _currentUser?.name ?? '');
                              final phoneController = TextEditingController(
                                  text: _currentUser?.phoneNumber ?? '');
                              final addressController = TextEditingController(
                                  text: _currentUser?.address ?? '');
                              final tagNameController = TextEditingController(
                                  text: _currentUser?.tagName ?? '');
                              int gender = _currentUser?.gender ?? 0;
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  backgroundColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Avatar nhỏ
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundImage:
                                              _currentUser?.imageUrl != null &&
                                                      _currentUser!
                                                          .imageUrl!.isNotEmpty
                                                  ? NetworkImage(
                                                      _currentUser!.imageUrl!)
                                                  : null,
                                          child:
                                              _currentUser?.imageUrl == null ||
                                                      _currentUser!
                                                          .imageUrl!.isEmpty
                                                  ? Icon(Icons.person,
                                                      size: 32,
                                                      color: Colors.grey)
                                                  : null,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Cập nhật thông tin',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        const SizedBox(height: 16),
                                        _inputField(
                                            icon: Icons.person,
                                            label: 'Họ và Tên',
                                            controller: nameController),
                                        _inputField(
                                            icon: Icons.alternate_email,
                                            label: 'TagName',
                                            controller: tagNameController),
                                        _inputField(
                                            icon: Icons.phone,
                                            label: 'Số điện thoại',
                                            controller: phoneController),
                                        _inputField(
                                            icon: Icons.location_on,
                                            label: 'Nơi sống',
                                            controller: addressController),
                                        DropdownButtonFormField<int>(
                                          value: gender,
                                          decoration: InputDecoration(
                                            labelText: 'Giới tính',
                                            prefixIcon: Icon(Icons.transgender),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                                value: 1, child: Text('Nam')),
                                            DropdownMenuItem(
                                                value: 0, child: Text('Nữ')),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) gender = value;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                                child: const Text('Hủy'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                                child: const Text('Lưu'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              if (result == true) {
                                final token = await UserStorage.getToken();
                                if (token != null && _currentUser?.id != null) {
                                  final reqBody = {
                                    'id': _currentUser!.id!,
                                    'name': nameController.text.isNotEmpty
                                        ? nameController.text
                                        : (_currentUser?.name ?? ''),
                                    'tagName': tagNameController.text.isNotEmpty
                                        ? tagNameController.text
                                        : (_currentUser?.tagName ?? ''),
                                    'phoneNumber':
                                        phoneController.text.isNotEmpty
                                            ? phoneController.text
                                            : (_currentUser?.phoneNumber ?? ''),
                                    'gender': gender,
                                    'address': addressController.text.isNotEmpty
                                        ? addressController.text
                                        : (_currentUser?.address ?? ''),
                                    'imageUrl': null,
                                  };
                                  print(
                                      '[UPDATE PROFILE] Request body: $reqBody');
                                  await UserStorage.updateUserProfile(
                                    id: reqBody['id'] as String,
                                    name: reqBody['name'] as String,
                                    tagName: reqBody['tagName'] as String?,
                                    phoneNumber:
                                        reqBody['phoneNumber'] as String?,
                                    gender: reqBody['gender'] as int?,
                                    address: reqBody['address'] as String?,
                                    imagePath: reqBody['imageUrl'] as String?,
                                    token: token,
                                  );
                                  await _loadUserInfo();
                                }
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Name & Tag
            Text(_currentUser?.name ?? '',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (_currentUser?.tagName != null &&
                _currentUser!.tagName!.isNotEmpty)
              Text('@${_currentUser!.tagName}',
                  style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            // Info grid/list
            Column(
              children: [
                _infoRow(Icons.email, _currentUser?.email ?? 'Chưa cập nhật'),
                _infoRow(
                    Icons.phone, _currentUser?.phoneNumber ?? 'Chưa cập nhật'),
                _infoRow(Icons.location_on,
                    _currentUser?.address ?? 'Chưa cập nhật'),
                _infoRow(
                  _currentUser?.gender == 1 ? Icons.male : Icons.female,
                  _currentUser?.gender == 1 ? 'Nam' : 'Nữ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: mySecondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (icon != null)
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: Icon(icon, size: 16, color: Colors.black87),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildNavRow(String title, {bool hasDivider = true}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
        if (hasDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Bạn có chắc muốn đăng xuất?',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Đóng',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Đăng xuất',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(
      {required IconData icon,
      required String label,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
