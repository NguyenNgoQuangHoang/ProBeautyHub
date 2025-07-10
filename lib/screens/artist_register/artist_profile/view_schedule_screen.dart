import 'package:flutter/material.dart';
import 'package:booking_app/widgets/colors.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../services/schedule_api_service.dart';
import 'package:intl/intl.dart';

class ViewScheduleScreen extends StatefulWidget {
  const ViewScheduleScreen({super.key});

  @override
  State<ViewScheduleScreen> createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  final ScheduleApiService _scheduleApiService = ScheduleApiService();
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _scheduleApiService.getArtistSchedule();

      if (result['success']) {
        setState(() {
          _schedules = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Có lỗi xảy ra';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Có thể làm việc';
      case 1:
        return 'Bận';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildScheduleCard(dynamic schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: _getStatusColor(schedule['status'] ?? 0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(schedule['status'] ?? 0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(schedule['status'] ?? 0),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Từ: ${_formatDateTime(schedule['startDate'] ?? '')}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Đến: ${_formatDateTime(schedule['endDate'] ?? '')}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomSliverAppBar(backgroundColor: myPrimaryColor),
        ],
        body: Column(
          children: [
            // Header
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
                      'Lịch làm việc của tôi',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "JacquesFrancois",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: GestureDetector(
                      onTap: _loadSchedules,
                      child: const Icon(
                        Icons.refresh,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSchedules,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : _schedules.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có lịch làm việc nào',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadSchedules,
                              child: ListView.builder(
                                itemCount: _schedules.length,
                                itemBuilder: (context, index) {
                                  return _buildScheduleCard(_schedules[index]);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_schedule').then((_) {
            // Refresh schedules when returning from create schedule
            _loadSchedules();
          });
        },
        backgroundColor: myPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
