import 'package:booking_app/screens/artist_register/artist_profile/create_promotion/create_promotion_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              _buildEmptyTabContent(),
              _buildEmptyTabContent(),
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

  Widget _buildEmptyTabContent() {
    return const Center(
      child: Text(
        'Trống\nHiện tại chưa có khuyến mãi  nào',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
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
            onTap: () {
              loadingScreen(context, () => const CreatePromotionScreen());
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
