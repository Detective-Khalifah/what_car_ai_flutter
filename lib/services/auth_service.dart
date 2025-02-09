import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:apple_sign_in/apple_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (error) {
      throw handleError(error);
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (error) {
      throw handleError(error);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In canceled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (error) {
      print('Google Sign In Error: $error');
      throw handleError(error);
    }
  }

/*
  Future<User?> signInWithApple() async {
    try {
      final credential = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.fullAccess])
      ]);

      if (credential == null) {
        throw Exception('Apple Sign-In canceled');
      }

      final appleCredential =
          AppleAuthProvider.credential(credential.identityToken!);

      final result = await _auth.signInWithCredential(appleCredential);
      return result.user;
    } catch (error) {
      print('Apple Sign In Error: $error');
      throw handleError(error);
    }
  }
  */

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      throw handleError(error);
    }
  }

  dynamic handleError(error) {
    String message = 'An error occurred';
    switch (error.code) {
      case 'auth/invalid-email':
        message = 'Invalid email address';
        break;
      case 'auth/user-disabled':
        message = 'This account has been disabled';
        break;
      case 'auth/user-not-found':
        message = 'User not found';
        break;
      case 'auth/wrong-password':
        message = 'Invalid password';
        break;
      case 'auth/email-already-in-use':
        message = 'Email already in use';
        break;
      case 'auth/weak-password':
        message = 'Password is too weak';
        break;
      case 'auth/invalid-credential':
        message = 'Invalid authentication credential';
        break;
      case 'auth/operation-not-allowed':
        message = 'This authentication method is not enabled';
        break;
      case 'auth/user-disabled':
        message = 'This user account has been disabled';
        break;
      case 'auth/user-not-found':
        message = 'No user found for this credential';
        break;
      default:
        message = error.message;
    }
    return Exception(message);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      switch (error /*.code*/) {
        case 'auth/invalid-email':
          throw Exception('Invalid email address');
        case 'auth/user-not-found':
          throw Exception('No account exists with this email');
        default:
          throw Exception('Failed to send reset email. Please try again.');
      }
    }
  }
}

Provider<AuthService> authServiceProvider =
    Provider<AuthService>((ref) => AuthService());
