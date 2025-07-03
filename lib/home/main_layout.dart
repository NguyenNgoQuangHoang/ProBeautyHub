import 'package:booking_app/screens/profiles/profiles_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../widgets/colors.dart';
import '../widgets/custom_appbar.dart';
import 'tabs/appointment_screen.dart';
import 'tabs/search_screen/search_screen.dart';
import 'tabs/home_screen.dart';
import 'tabs/setting_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final items = [
    const Icon(Icons.home),
    const Icon(Icons.search),
    const Icon(Icons.calendar_today),
    const Icon(Icons.menu),
  ];
  int index = 0;
  final screen = [
    const HomeScreen(),
    const SearchScreen(),
    const AppointmentsScreen(),
    const SettingScreen(),
  ];

  bool isMessageOpen = false;

  // get screen => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Title
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerIsScrolled) => [
          CustomSliverAppBar(
            onProfileTap: () {
              loadingScreen(context, () => ProfilesScreen());
            },
          ),
        ],
        body: screen[index],
      ),
      //NavigationBar
      bottomNavigationBar: CurvedNavigationBar(
        color: myPrimaryColor,
        buttonBackgroundColor: myPrimaryColor,
        height: 70,
        animationCurve: Curves.decelerate,
        backgroundColor: Colors.transparent,
        items: items,
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }
}

// // o tin nhan
