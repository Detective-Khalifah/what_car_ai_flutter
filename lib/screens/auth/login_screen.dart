import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:what_car_ai_flutter/providers/auth_provider.dart';
// import 'package:what_car_flutter/services/auth_service.dart';
// import 'package:what_car_flutter/providers/auth_provider.dart';
// import 'package:what_car_flutter/constants.dart'; // Import your theme constants

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  Future<void> handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() => _loading = true);

    try {
      await ref
          .read(authServiceProvider.notifier)
          .signInWithEmail(email, password);
      // ref
      //     .read(authServiceProvider.notifier)
      //     .signOut(); // Simulate sign-out for demonstration purposes

      // Navigate to dashboard only if login succeeds
      if (ref.read(authServiceProvider).isSignedIn) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> handleGoogleLogin() async {
    setState(() {
      _loading = true;
    });

    try {
      await ref.read(authServiceProvider.notifier).signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

/*
  Future<void> handleAppleLogin() async {
    setState(() {
      _loading = true;
    });

    try {
      await ref.read(authServiceProvider.notifier).signInWithApple();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 24),
                    Text(
                      'Welcome back',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 24),
                    // Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Password Input
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/auth/forgot-password'),
                        child: Text('Forgot Password?'),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Login Button
                    ElevatedButton(
                      onPressed: handleEmailLogin,
                      child: Text(_loading ? 'Signing in...' : 'Sign In'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Social Login
            SizedBox(height: 24),
            Text(
              'Or continue with',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google
                ElevatedButton.icon(
                  onPressed: handleGoogleLogin,
                  icon: Icon(Icons.g_mobiledata, color: Colors.red),
                  label: Text('Continue with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                ),
                SizedBox(width: 16),
                // Apple
                /*
                if (Platform.isIOS)
                  ElevatedButton.icon(
                    onPressed: handleAppleLogin,
                    icon: Icon(MdiIcons.apple, color: Colors.black),
                    label: Text('Continue with Apple'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                  ),
                  */
              ],
            ),
            SizedBox(height: 24),
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account? '),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/auth/register'),
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
