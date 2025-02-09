import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider =
    StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState.initial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = state.copyWith(isSignedIn: true, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception("Google Sign-In was cancelled");

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _auth.signInWithCredential(credential);
      state = state.copyWith(isSignedIn: true, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

/*
  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await _auth.signInWithCredential(credential);
      state = state.copyWith(isSignedIn: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
*/

  void signOut() {
    _auth.signOut();
    state = state.copyWith(isSignedIn: false, error: null);
  }
}

class AuthState {
  final bool isSignedIn;
  final String? error;

  AuthState({required this.isSignedIn, this.error});

  factory AuthState.initial() => AuthState(isSignedIn: false, error: null);

  AuthState copyWith({bool? isSignedIn, String? error}) {
    return AuthState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      error: error ?? this.error,
    );
  }
}
