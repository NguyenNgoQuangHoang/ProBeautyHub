import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<void> loadingScreen(
    BuildContext context, Widget Function() screenBuilder) async {
  // Show a custom dialog with blur background
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Loading",
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => Center(
      child: const Center(
        child: SpinKitFadingCircle(
          color: Colors.white,
          size: 45.0,
        ),
      ),
    ),
  );

  // Wait a bit to simulate loading
  await Future.delayed(const Duration(milliseconds: 500));

  // Close loading dialog
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }

  // Navigate to target screen
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => screenBuilder()),
  );
}
