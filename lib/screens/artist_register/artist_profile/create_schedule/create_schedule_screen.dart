import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:booking_app/widgets/colors.dart';
import '../../../../widgets/custom_appbar.dart';
import '../../../../services/schedule_api_service.dart';

class UpdateDateScreen extends StatefulWidget {
  const UpdateDateScreen({super.key});

  @override
  State<UpdateDateScreen> createState() => _UpdateDateScreenState();
}

class _UpdateDateScreenState extends State<UpdateDateScreen> {
  DateTime _selectedDay = DateTime.now();
  int _selectedTimeIndex = 2;
  bool _isLoading = false;
  final ScheduleApiService _scheduleApiService = ScheduleApiService();

  // Các khung giờ
  final List<String> timeSlots = [
    "03:00 AM - 06:00 AM",
    "06:00 AM - 09:00 AM",
    "09:00 AM - 11:00 AM",
    "11:00 AM - 02:00 PM",
    "02:00 PM - 05:00 PM",
  ];

  // Mapping time slots to actual hours
  final List<Map<String, int>> timeSlotHours = [
    {"start": 3, "end": 6}, // 03:00 AM - 06:00 AM
    {"start": 6, "end": 9}, // 06:00 AM - 09:00 AM
    {"start": 9, "end": 11}, // 09:00 AM - 11:00 AM
    {"start": 11, "end": 14}, // 11:00 AM - 02:00 PM
    {"start": 14, "end": 17}, // 02:00 PM - 05:00 PM
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerIsScrolled) => [
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
                      'Update Schedule',
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
            const SizedBox(height: 10),
            // Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                },
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Time slots scroll wheel
            Expanded(
              child: Center(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.003,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedTimeIndex = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: timeSlots.length,
                    builder: (context, index) {
                      final isSelected = index == _selectedTimeIndex;
                      return Center(
                        child: Text(
                          timeSlots[index],
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 16,
                            fontFamily: "Baloo2",
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.black45,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Update schedule button
            GestureDetector(
              onTap: _isLoading ? null : _updateSchedule,
              child: Container(
                color: _isLoading
                    ? Colors.grey
                    : const Color.fromARGB(221, 87, 85, 85),
                padding: const EdgeInsets.symmetric(vertical: 18),
                height: 60,
                width: double.infinity,
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Update Schedule',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "JacquesFrancois",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSchedule() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get selected time slot hours
      final selectedTimeSlot = timeSlotHours[_selectedTimeIndex];

      // Create start and end DateTime
      final startDate = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        selectedTimeSlot["start"]!,
        0,
      );

      final endDate = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        selectedTimeSlot["end"]!,
        0,
      );

      // Create time request (status = 0 means available)
      final timeRequest = TimeRequest(
        startDate: startDate,
        endDate: endDate,
        status: 0, // 0 = available
      );

      // Call API
      final result = await _scheduleApiService.updateAvailability(
        timeRequests: [timeRequest],
      );

      if (result['success']) {
        _showSuccessDialog('Cập nhật lịch làm việc thành công!');
      } else {
        _showErrorDialog(result['error'] ?? 'Có lỗi xảy ra khi cập nhật lịch');
      }
    } catch (e) {
      _showErrorDialog('Có lỗi xảy ra: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thành công'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
