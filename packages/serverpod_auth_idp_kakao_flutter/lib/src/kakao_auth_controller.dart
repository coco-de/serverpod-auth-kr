import 'package:flutter/widgets.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_kakao_client/serverpod_auth_idp_kakao_client.dart';

import 'kakao_sign_in_service.dart';

/// Controller that manages the Kakao authentication flow.
///
/// It is UI-agnostic ([ChangeNotifier]) and follows the **access token** flow:
/// the native Kakao SDK (via [KakaoSignInService]) returns an access token,
/// which is sent to the server's `loginWithAccessToken` endpoint; the resulting
/// [AuthSuccess] is applied to the client's auth session.
///
/// Example:
/// ```dart
/// final controller = KakaoAuthController(
///   client: client,
///   signInService: KakaoSdkSignInService(), // your KakaoSignInService impl
///   onAuthenticated: () {
///     // Do not navigate here directly; let your app react to auth state.
///   },
/// );
/// await controller.signIn();
/// ```
class KakaoAuthController extends ChangeNotifier {
  /// The Serverpod client instance (must have the Kakao IdP module wired in).
  final ServerpodClientShared client;

  /// SDK-agnostic provider of the Kakao access token.
  final KakaoSignInService signInService;

  /// Called when authentication succeeds.
  final VoidCallback? onAuthenticated;

  /// Called when an error that should be surfaced to the user occurs.
  final void Function(Object error)? onError;

  /// Creates a [KakaoAuthController].
  KakaoAuthController({
    required this.client,
    required this.signInService,
    this.onAuthenticated,
    this.onError,
  });

  KakaoAuthState _state = KakaoAuthState.idle;
  Object? _error;
  bool _disposed = false;

  /// The current state of the authentication flow.
  KakaoAuthState get state => _state;

  /// Whether a request is currently being processed.
  bool get isLoading => _state == KakaoAuthState.loading;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => client.auth.isAuthenticated;

  /// The current error, if the controller is in the error state.
  Object? get error => _state == KakaoAuthState.error ? _error : null;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Runs the Kakao sign-in flow: native login → server → client session.
  ///
  /// On success calls [onAuthenticated]; on failure transitions to the error
  /// state and calls [onError]. A user cancellation returns to [KakaoAuthState.idle].
  Future<void> signIn() async {
    if (_state == KakaoAuthState.loading) return;
    _setState(KakaoAuthState.loading);

    try {
      final String? accessToken = await signInService.obtainAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        // User cancelled or no token was obtained.
        _setState(KakaoAuthState.idle);
        return;
      }

      // Requires the serverpod_auth_idp_kakao module to be wired into the app
      // client; otherwise Serverpod throws when resolving the endpoint.
      final endpoint = client.getEndpointOfType<EndpointKakaoIdp>();
      final authSuccess = await endpoint.loginWithAccessToken(
        accessToken: accessToken,
      );
      await client.auth.updateSignedInUser(authSuccess);

      _setState(KakaoAuthState.authenticated);
      onAuthenticated?.call();
    } catch (error) {
      _handleAuthenticationError(error);
    }
  }

  void _handleAuthenticationError(final Object error) {
    _error = error;
    _setState(KakaoAuthState.error);
    debugPrint('[KakaoAuthController] Authentication error: $error');

    // StateError signals a programming/config issue — don't surface to users.
    if (error is! StateError) onError?.call(error);
  }

  void _setState(final KakaoAuthState newState) {
    if (_disposed) return;
    if (newState != KakaoAuthState.error) _error = null;
    _state = newState;
    notifyListeners();
  }
}

/// States of the Kakao authentication flow.
enum KakaoAuthState {
  /// Initial idle state.
  idle,

  /// A request is being processed.
  loading,

  /// The last request ended with an error (see [KakaoAuthController.error]).
  error,

  /// Authentication succeeded.
  authenticated,
}
