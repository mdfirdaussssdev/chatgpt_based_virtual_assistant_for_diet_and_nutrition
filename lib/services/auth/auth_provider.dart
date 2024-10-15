import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String id,
    required String password,
  });
  Future<AuthUser> logInWithGoogle();
  Future<AuthUser> createUser({
    required String id,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String toEmail});
}
