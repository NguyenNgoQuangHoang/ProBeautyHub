import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArtistDashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> bookingData;
  final VoidCallback onViewAllPress;
  final Function(Map<String, dynamic>) onBookingPress;

  ArtistDashboardScreen({
    required this.bookingData,
    required this.onViewAllPress,
    required this.onBookingPress,
  });

  final Color primary = const Color(0xFFBD9EB7);
  final Color background = const Color(0xFFFCF5FA);
  final Color textPrimary = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color white = Colors.white;
  final Color black = Colors.black;

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM HH:mm', 'vi_VN').format(date);
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'upcoming':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return textSecondary;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'upcoming':
        return 'Sắp tới';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = bookingData.where((b) => b['status'] == 'upcoming').length;
    final completed =
        bookingData.where((b) => b['status'] == 'completed').length;
    final cancelled =
        bookingData.where((b) => b['status'] == 'cancelled').length;

    final recentBookings = bookingData.take(3).toList();

    return Scaffold(
      backgroundColor: background,
      body: Padding(
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
                  onPressed: onViewAllPress,
                  child: Text("Xem tất cả", style: TextStyle(color: primary)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                buildStatCard("Chưa thực hiện", pending),
                buildStatCard("Đã hoàn thành", completed),
                buildStatCard("Đã hủy", cancelled),
              ],
            ),
            SizedBox(height: 16),
            Text("Lịch hẹn gần đây",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
            SizedBox(height: 8),
            ...recentBookings.map((item) => GestureDetector(
                  onTap: () => onBookingPress(item),
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
                                    Text("Khách hàng #${item['id']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary)),
                                    Text(item['service']),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(item['status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                getStatusText(item['status']),
                                style: TextStyle(
                                    color: getStatusColor(item['status']),
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
                          Text(formatDate(item['appointmentDate']),
                              style: TextStyle(color: textSecondary)),
                        ]),
                        SizedBox(height: 6),
                        Row(children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: textSecondary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(item['address'],
                                style: TextStyle(color: textSecondary),
                                maxLines: 1),
                          ),
                        ]),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatCurrency(item['totalAmount']),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary)),
                            Icon(Icons.chevron_right,
                                size: 16, color: textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard(String label, int value) {
    return Expanded(
      child: Container(
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
      ),
    );
  }
}
