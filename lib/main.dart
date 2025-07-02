import 'package:booking_app/home/main_layout.dart';
import 'package:booking_app/screens/artist_register/artist_profile/create_promotion/promotion_screen.dart'
    show PromotionScreen;

import 'package:booking_app/screens/artist_register/splash_artist_screen.dart';
import 'package:booking_app/screens/profiles/profiles_screen.dart';
import 'package:booking_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import 'screens/artist_register/artist_profile/artist_profile_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const SplashScreen(),
  ));
}
