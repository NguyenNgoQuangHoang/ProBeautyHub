import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingContent {
  final String image;
  final String description;
  final String content;
  final Color colorsplash;
  final String? icon;

  OnboardingContent({
    required this.image,
    required this.description,
    required this.content,
    required this.colorsplash,
    required this.icon,
  });
}

final List<OnboardingContent> contents = [
  OnboardingContent(
    image: 'assets/images/splash/spl1.png',
    colorsplash: const Color.fromARGB(255, 131, 166, 194),
    description: "WELCOME TO FLAWLESS",
    content: "Transforming your beauty into pure elegance",
    icon: "",
  ),
  OnboardingContent(
    image: 'assets/images/splash/spl2.png',
    colorsplash: const Color.fromARGB(255, 239, 145, 102),
    description: "FIND A SERVICE",
    content:
        "Many makeup styles and professional makeup. Quickly search from popular styles and gradually find your style. Great experience is your choice.",
    icon: "assets/images/splash/icon1.png",
  ),
  OnboardingContent(
    image: 'assets/images/splash/spl3.png',
    colorsplash: const Color.fromARGB(255, 134, 216, 165),
    description: "FIND A SERVICE",
    content:
        "Many makeup styles and professional makeup. Quickly search from popular styles and gradually find your style. Great experience is your choice.",
    icon: "assets/images/splash/icon2.png",
  ),
  OnboardingContent(
    image: 'assets/images/splash/spl4.png',
    colorsplash: const Color.fromARGB(255, 134, 216, 165),
    description: "YOUR SPOT. YOUR TIME",
    content:
        "Flexible time and location selection within the operating area. Save your time and create the most convenience and comfort for you. Your time is our care.",
    icon: "assets/images/splash/icon3.png",
  ),
];
