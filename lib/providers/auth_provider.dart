import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:treeroute/providers/providers.dart';

class AuthState {
  final sb.Session? session;
  final bool isLoading;
  final bool isInitialized;
  final bool isMagicLinkSent;
  final String? error;

  get isSignedIn => session != null;

  const AuthState({
    this.session,
    this.isLoading = false,
    this.isInitialized = false,
    this.isMagicLinkSent = false,
    this.error,
  });

  factory AuthState.preInit() => const AuthState(isInitialized: false);
  factory AuthState.initial() => const AuthState(isInitialized: true);
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(sb.Session session) =>
      AuthState(session: session);
  factory AuthState.magicLinkSent() => const AuthState(isMagicLinkSent: true);
  factory AuthState.error(String error) => AuthState(error: error);
}

class AuthProvider extends StateNotifier<AuthState> {
  final sb.GoTrueClient _client = sb.Supabase.instance.client.auth;

  // on init
  AuthProvider(Ref ref) : super(AuthState.preInit()) {
    _client.onAuthStateChange.listen((event) {
      if (event.event == sb.AuthChangeEvent.signedIn) {
        state = AuthState.authenticated(event.session!);
        ref.read(userProvider.notifier).getUser();
      } else if (event.event == sb.AuthChangeEvent.signedOut) {
        state = AuthState.initial();
      } else if (event.event == sb.AuthChangeEvent.userUpdated) {
        state = AuthState.authenticated(event.session!);
        ref.read(userProvider.notifier).getUser();
      } else if (event.event == sb.AuthChangeEvent.passwordRecovery) {
        state = AuthState.magicLinkSent();
      } else if (event.event == sb.AuthChangeEvent.userDeleted) {
        state = AuthState.initial();
      }
    });

    sb.SupabaseAuth.instance.initialSession.then((initialSession) {
      if (initialSession != null) {
        state = AuthState.authenticated(initialSession);
        ref.read(userProvider.notifier).getUser();
      } else {
        state = AuthState.initial();
      }
    }).onError((error, stackTrace) {
      state = AuthState.error(error.toString());
    });
  }

  void setAuthenticated(sb.Session session) {
    state = AuthState.authenticated(session);
  }

  Future<void> setInitial() async {
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

  void logOut() async {
    await _client.signOut();
    setInitial();
  }

  Future<void> sendMagicLink(String email) async {
    setLoading();

    try {
      await _client.signInWithOtp(
        email: email,
        emailRedirectTo: "https://treeroute.org/login-callback",
      );
      setMagicLinkSent();
    } on sb.AuthException catch (e) {
      setError(e.message);
    } catch (e) {
      setError(e.toString());
    }
  }
}
