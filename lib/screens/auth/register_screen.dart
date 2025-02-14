import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:what_car_ai_flutter/services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;

  Future<void> handleEmailSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await ref
          .read(authServiceProvider /*.notifier*/)
          .signUpWithEmail(email, password);
      ref
          .read(authServiceProvider /*.notifier*/)
          .signOut(); // Simulate sign-out for demonstration purposes
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

  Future<void> handleGoogleSignUp() async {
    setState(() {
      _loading = true;
    });

    try {
      await ref.read(authServiceProvider /*.notifier*/).signInWithGoogle();
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
  Future<void> handleAppleSignUp() async {
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
                      'Create Account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 24),
                    // Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(MdiIcons.email, color: Colors.grey),
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
                        prefixIcon: Icon(MdiIcons.lock, color: Colors.grey),
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showPassword ? MdiIcons.eyeOff : MdiIcons.eye,
                              color: Colors.grey),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Confirm Password Input
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(MdiIcons.lock, color: Colors.grey),
                        labelText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showConfirmPassword
                                  ? MdiIcons.eyeOff
                                  : MdiIcons.eye,
                              color: Colors.grey),
                          onPressed: () => setState(() =>
                              _showConfirmPassword = !_showConfirmPassword),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: handleEmailSignUp,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                          _loading ? 'Creating Account...' : 'Create Account'),
                    ),
                  ],
                ),
              ),
            ),
            // Social Sign Up
            SizedBox(height: 24),
            Text(
              'Or sign up with',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google
                ElevatedButton.icon(
                  onPressed: handleGoogleSignUp,
                  icon: Icon(MdiIcons.google, color: Colors.red),
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
                    onPressed: handleAppleSignUp,
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
            // Terms and Privacy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  children: [
                    TextSpan(text: 'By signing up, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.pushNamed(context, '/terms'),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => Navigator.pushNamed(context, '/privacy'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? '),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth/login'),
                  child: Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
