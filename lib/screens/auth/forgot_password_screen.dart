import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/screens/auth/_layout.dart';
import 'package:what_car_ai_flutter/services/auth_service.dart';
// import 'package:what_car_flutter/constants.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your email address')));
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Password reset email sent. Please check your inbox.')));
      context.pop();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AuthLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Forgot Password?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Enter your email address and we\'ll send you instructions to reset your password.',
              style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.grey),
                labelText: 'Email',
                filled: true,
                fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme.primaryColor, // Matches React Native's `bg-primary`
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(_loading ? 'Sending...' : 'Send Reset Link'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
