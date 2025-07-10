import 'package:booking_app/screens/artist_register/artist_profile/create_promotion/create_promotion_screen.dart';
import 'package:booking_app/services/promotion_api_service.dart';
import 'package:flutter/material.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPopup = false;
  bool _isLoading = false;
  List<dynamic> _activePromotions = [];
  List<dynamic> _inactivePromotions = [];
  String? _error;
  final PromotionApiService _promotionApiService = PromotionApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _promotionApiService.getVouchers();
      if (result['success']) {
        final data = result['data'];
        List<dynamic> allVouchers = [];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('voucherDTOs')) {
            allVouchers = data['voucherDTOs'] ?? [];
          } else if (data.containsKey('vouchers')) {
            allVouchers = data['vouchers'] ?? [];
          } else if (data.containsKey('data')) {
            allVouchers = data['data'] ?? [];
          }
        } else if (data is List) {
          allVouchers = data;
        }

        final now = DateTime.now();
        _activePromotions = [];
        _inactivePromotions = [];

        for (var voucher in allVouchers) {
          final startDateStr = voucher['startDate']?.toString();
          final endDateStr = voucher['endDate']?.toString();

          bool isCurrentlyActive = true;

          if (startDateStr != null && endDateStr != null) {
            try {
              final startDate = DateTime.parse(startDateStr);
              final endDate = DateTime.parse(endDateStr);
              isCurrentlyActive =
                  now.isAfter(startDate) && now.isBefore(endDate);
            } catch (e) {
              isCurrentlyActive = true;
            }
          }

          if (isCurrentlyActive) {
            _activePromotions.add(voucher);
          } else {
            _inactivePromotions.add(voucher);
          }
        }
      } else {
        _error =
            result['error'] ?? 'Có lỗi xảy ra khi tải danh sách khuyến mãi';
      }
    } catch (e) {
      _error = 'Có lỗi xảy ra: $e';
      print('Error loading vouchers: $e');
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
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Khuyến mãi',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Đang hoạt động'),
            Tab(text: 'Đã kết thúc'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildPromotionTabContent(_activePromotions,
                  'Hiện tại chưa có khuyến mãi hoạt động nào'),
              _buildPromotionTabContent(_inactivePromotions,
                  'Hiện tại chưa có khuyến mãi đã kết thúc nào'),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showPopup) _buildPopupMenu(),
                const SizedBox(height: 10),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black),
                  ),
                  onPressed: () {
                    setState(() {
                      _showPopup = !_showPopup;
                    });
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionTabContent(
      List<dynamic> vouchers, String emptyMessage) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPromotions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Trống\n$emptyMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPromotions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          return _buildVoucherCard(voucher);
        },
      ),
    );
  }

  Widget _buildVoucherCard(dynamic voucher) {
    final code = voucher['code']?.toString() ?? 'NOCODE';
    final description = voucher['description']?.toString() ?? 'Không có mô tả';
    final discountValue = voucher['discountValue']?.toString() ?? '0';
    final discountType = voucher['discountType'] ?? 0;
    final startDate = voucher['startDate']?.toString() ?? '';
    final endDate = voucher['endDate']?.toString() ?? '';
    final maxUsage = voucher['maxUsage']?.toString() ?? '0';
    final currentUsage = voucher['currentUsage']?.toString() ?? '0';
    final minTotalAmount = voucher['minTotalAmount']?.toString() ?? '0';

    final now = DateTime.now();
    bool isCurrentlyActive = true;

    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      try {
        final startDateTime = DateTime.parse(startDate);
        final endDateTime = DateTime.parse(endDate);
        isCurrentlyActive =
            now.isAfter(startDateTime) && now.isBefore(endDateTime);
      } catch (e) {
        isCurrentlyActive = true;
      }
    }

    String discountText = '';
    if (discountType == 0) {
      discountText = 'Giảm $discountValue%';
    } else {
      discountText = 'Giảm $discountValueđ';
    }

    String formatCurrency(String amount) {
      try {
        final number = int.parse(amount);
        return '${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
      } catch (e) {
        return '$amountđ';
      }
    }

    String formatDate(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return dateString;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isCurrentlyActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCurrentlyActive ? 'Hoạt động' : 'Đã kết thúc',
                    style: TextStyle(
                      color: isCurrentlyActive
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_offer, size: 16, color: Colors.purple[600]),
                const SizedBox(width: 4),
                Text(
                  discountText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
            if (minTotalAmount != '0') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Đơn tối thiểu: ${formatCurrency(minTotalAmount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Đã dùng: $currentUsage/$maxUsage',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (startDate.isNotEmpty && endDate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Từ ${formatDate(startDate)} đến ${formatDate(endDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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

  Widget _buildPopupMenu() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPopupItem(
            icon: Icons.local_offer_outlined,
            label: 'Chương trình giảm giá',
            onTap: () {
              setState(() => _showPopup = false);
            },
          ),
          const SizedBox(height: 10),
          _buildPopupItem(
            icon: Icons.discount_outlined,
            label: 'Mã giảm giá',
            onTap: () {
              setState(() => _showPopup = false);
            },
          ),
          const SizedBox(height: 10),
          _buildPopupItem(
            icon: Icons.discount_outlined,
            label: 'Tạo mã khuyến mãi',
            onTap: () async {
              setState(() => _showPopup = false);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePromotionScreen()),
              );
              // Refresh promotions if a new one was created
              if (result == true) {
                _loadPromotions();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopupItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
