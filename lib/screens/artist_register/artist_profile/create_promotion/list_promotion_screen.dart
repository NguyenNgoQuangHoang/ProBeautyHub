import 'package:flutter/material.dart';

class ListPromotionScreen extends StatelessWidget {
  const ListPromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Khuyến mãi',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Đang hoạt động'),
              Tab(text: 'Đã kết thúc'),
            ],
          ),
        ),
        body: Stack(
          children: [
            const TabBarView(
              children: [
                _PromotionList(isActive: true),
                _PromotionList(isActive: false),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Builder(
                builder: (context) {
                  return FloatingActionButton(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black),
                    ),
                    onPressed: () {
                      final RenderBox button =
                          context.findRenderObject() as RenderBox;
                      final RenderBox overlay = Overlay.of(context)
                          .context
                          .findRenderObject() as RenderBox;
                      final Offset position =
                          button.localToGlobal(Offset.zero, ancestor: overlay);

                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          position.dx - 160,
                          position.dy - 120,
                          position.dx,
                          position.dy,
                        ),
                        items: [
                          PopupMenuItem(
                            child: _buildPopupItem(
                              icon: Icons.local_offer_outlined,
                              label: 'Chương trình giảm giá',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to discount program screen
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: _buildPopupItem(
                              icon: Icons.discount_outlined,
                              label: 'Mã giảm giá',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to voucher screen
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.black),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionList extends StatelessWidget {
  final bool isActive;

  const _PromotionList({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> promotions = List.generate(5, (index) {
      return {
        'title': 'Sale giữa năm',
        'date': '23/03/2025 - 01/04/2025',
        'status': 'Sắp diễn ra',
      };
    });

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: promotions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final promo = promotions[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_outlined, color: Colors.brown),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JacquesFrancois',
                      ),
                    ),
                    Text(
                      promo['date']!,
                      style: const TextStyle(
                        fontFamily: 'JacquesFrancois',
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        // TODO: Cancel action
                      },
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(
                          color: Colors.orange,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0CE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promo['status']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.purple),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildPopupItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black)),
      ],
    ),
  );
}
