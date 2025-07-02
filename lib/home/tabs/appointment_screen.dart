import 'package:flutter/material.dart';
import '../../widgets/colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: myPrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'APPOINTMENTS',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "JacquesFrancois",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'CURRENT'),
                Tab(text: 'PAST'),
              ],
            ),
          ),

          // TAB VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTab(),
                _buildPastTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildInfoRow('Status', 'Paid', color: Colors.green),
              _buildInfoRow('Payment method', 'VISA', bold: true),
              _buildInfoRow('Total Amount', '780\$'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Booking Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildBookingCard(
          status: 'Confirmed',
          statusColor: Colors.green,
          name: 'Alexander Stubb',
          service: 'Glam Makeup',
          price: '\$200',
          date: 'Monday, March 24, 2025',
          time: '09:00 AM - 11:00 AM',
        ),
        _buildBookingCard(
          status: 'Processing',
          statusColor: Colors.blue,
          name: 'Alexander Stubb',
          service: 'Glam Makeup',
          price: '\$200',
          date: 'Monday, March 29, 2025',
          time: '06:00 AM - 09:00 AM',
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: myPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () => showBottomSheet(context),
            child: const Text('Rebook',
                style: TextStyle(fontSize: 17, color: Colors.black)),
          ),
        )
      ],
    );
  }

  Widget _buildPastTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('March 2025',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        _buildPastCard(
          status: 'Completed',
          statusColor: Colors.green,
          name: 'Alexander Stubb',
          service: 'Glam Makeup',
          date: 'Monday, March 24, 2025',
          time: '09:00 AM - 11:00 AM',
        ),
        _buildPastCard(
          status: 'Canceled',
          statusColor: Colors.red,
          name: 'Jonathan Jame',
          service: 'EveryDay Makeup',
          date: 'Monday, March 24, 2025',
          time: '09:00 AM - 11:00 AM',
        ),
        _buildPastCard(
          status: 'Completed',
          statusColor: Colors.green,
          name: 'William Nguyen',
          service: 'EveryDay Makeup',
          date: 'Monday, March 24, 2025',
          time: '09:00 AM - 11:00 AM',
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required String status,
    required Color statusColor,
    required String name,
    required String service,
    required String price,
    required String date,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: statusColor, size: 16),
                const SizedBox(width: 5),
                Text(status,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(service,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(price),
                  ],
                )
              ],
            ),
            const SizedBox(height: 4),
            Text(date),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            const Divider(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('8XtTU9W45GH'),
                Icon(Icons.copy, size: 16),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPastCard({
    required String status,
    required Color statusColor,
    required String name,
    required String service,
    required String date,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status == 'Completed' ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(status, style: TextStyle(color: statusColor)),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(date),
            Text(time),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Evaluate',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: myPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('ReBook',
                        style: TextStyle(color: Colors.black)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Text('Total Amount',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('780\$',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Number Of Service'),
                        Text('2'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount'),
                        Text('20\$'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB390C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
