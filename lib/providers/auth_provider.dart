import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthState {
  final sb.User? user;
  final bool isLoading;
  final bool isMagicLinkSent;
  final String? error;

  get isSignedIn => user != null;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isMagicLinkSent = false,
    this.error,
  });

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(sb.User user) => AuthState(user: user);
  factory AuthState.magicLinkSent() => const AuthState(isMagicLinkSent: true);
  factory AuthState.error(String error) => AuthState(error: error);
}

class AuthProvider extends StateNotifier<AuthState> {
  final sb.GoTrueClient _client = sb.Supabase.instance.client.auth;

  AuthProvider(Ref ref) : super(AuthState.initial());

  void setAuthenticated(sb.User user) {
    state = AuthState.authenticated(user);
  }

  void setInitial() {
    state = AuthState.initial();
  }

  void setError(String error) {
    state = AuthState.error(error);
  }

  void setLoading() {
    state = AuthState.loading();
  }

  void setMagicLinkSent() {
    state = AuthState.magicLinkSent();
  }

  Future<void> sendMagicLink(String email) async {
    setLoading();

    try {
      await _client.signInWithOtp(
          email: email, emailRedirectTo: "org.treeroute.app://login-callback");
      setMagicLinkSent();
    } catch (e) {
      setError(e.toString());
    }
  }
}
