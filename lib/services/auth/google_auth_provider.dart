import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'auth_provider.dart';
import 'auth_user.dart';

class GoogleAuthProvider implements AuthProvider {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;

  @override
  Future<void> initialize() async {
    // Initialization for Google Sign-In if needed.
    // Google Sign-In doesn't usually require special initialization.
  }

  @override
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    String? id,
    String? password,
  }) {
    throw UnimplementedError(
        'Google sign-in does not support id and password login');
  }

  @override
  Future<AuthUser> logInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final firebase.AuthCredential credential =
          firebase.GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return AuthUser.fromFirebase(userCredential.user!);
    } else {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> createUser({required String id, required String password}) {
    throw UnimplementedError(
        'Google Sign-In does not support creating users with email and password.');
  }

  @override
  Future<void> logOut() async {
    try {
      await _googleSignIn.signOut(); // Signs out from Google Sign-In
      await _firebaseAuth.signOut(); // Signs out from Firebase Authentication
    } catch (e) {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() {
    throw UnimplementedError(
        'Google Sign-In does not require email verification.');
  }
}
