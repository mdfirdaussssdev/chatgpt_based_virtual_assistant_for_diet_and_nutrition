import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_provider.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_user.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/firebase_auth_provider.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/google_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());
  factory AuthService.google() => AuthService(GoogleAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String id,
    required String password,
  }) =>
      provider.createUser(
        id: id,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String id,
    required String password,
  }) =>
      provider.logIn(id: id, password: password);

  @override
  Future<AuthUser> logInWithGoogle() async {
    return provider.logInWithGoogle();
  }

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();
}
