import 'package:flutter/material.dart';
// import 'package:what_car_flutter/constants.dart'; // Import your theme constants

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
