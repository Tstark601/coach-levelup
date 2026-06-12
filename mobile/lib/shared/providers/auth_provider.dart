import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state — listens to Supabase auth session changes
final authStateProvider = StreamProvider<Session?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session);
});

/// Current Supabase user
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Auth service for login, register, logout
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _client = Supabase.instance.client;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.levelupcreator://login-callback',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String? get currentAccessToken {
    return _client.auth.currentSession?.accessToken;
  }

  bool get isAuthenticated {
    return _client.auth.currentUser != null;
  }
}
