import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:booking_app/widgets/colors.dart';
import '../../../../widgets/custom_appbar.dart';

class UpdateDateScreen extends StatefulWidget {
  const UpdateDateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateDateScreen> createState() => _UpdateDateScreenState();
}

class _UpdateDateScreenState extends State<UpdateDateScreen> {
  DateTime _selectedDay = DateTime.now();
  int _selectedTimeIndex = 2;

  // Các khung giờ
  final List<String> timeSlots = [
    "03:00 AM - 06:00 AM",
    "06:00 AM - 09:00 AM",
    "09:00 AM - 11:00 AM",
    "11:00 AM - 02:00 PM",
    "02:00 PM - 05:00 PM",
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
              onTap: () {
                final formattedDate =
                    DateFormat('dd/MM/yyyy').format(_selectedDay);
                final selectedTime = timeSlots[_selectedTimeIndex];

                // Return selected date & time
                Navigator.pop(context, {
                  "date": formattedDate,
                  "time": selectedTime,
                });
              },
              child: Container(
                color: const Color.fromARGB(221, 87, 85, 85),
                padding: const EdgeInsets.symmetric(vertical: 18),
                height: 60,
                width: double.infinity,
                child: const Center(
                  child: Text(
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
}
