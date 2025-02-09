import 'package:flutter/material.dart';

class Constants {
  // static double _screenWidth = MediaQuery.of(context).size.width;
  // static double _screenHeight = MediaQuery.of(context).size.height;

// double _screenWidth = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width;
// double _screenHeight = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height;

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
