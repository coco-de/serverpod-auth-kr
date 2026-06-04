import 'package:flutter/widgets.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_naver_client/serverpod_auth_idp_naver_client.dart';

import 'naver_sign_in_service.dart';

/// Controller that manages the Naver authentication flow.
///
/// It is UI-agnostic ([ChangeNotifier]) and follows the **access token** flow:
/// the native Naver SDK (via [NaverSignInService]) returns an access token,
/// which is sent to the server's `loginWithAccessToken` endpoint; the resulting
/// [AuthSuccess] is applied to the client's auth session.
///
/// Example:
/// ```dart
/// final controller = NaverAuthController(
///   client: client,
///   signInService: FlutterNaverLoginService(), // your NaverSignInService impl
///   onAuthenticated: () {
///     // Do not navigate here directly; let your app react to auth state.
///   },
/// );
/// await controller.signIn();
/// ```
class NaverAuthController extends ChangeNotifier {
  /// The Serverpod client instance (must have the Naver IdP module wired in).
  final ServerpodClientShared client;

  /// SDK-agnostic provider of the Naver access token.
  final NaverSignInService signInService;

  /// Called when authentication succeeds.
  final VoidCallback? onAuthenticated;

  /// Called when an error that should be surfaced to the user occurs.
  final void Function(Object error)? onError;

  /// Creates a [NaverAuthController].
  NaverAuthController({
    required this.client,
    required this.signInService,
    this.onAuthenticated,
    this.onError,
  });

  NaverAuthState _state = NaverAuthState.idle;
  Object? _error;
  bool _disposed = false;

  /// The current state of the authentication flow.
  NaverAuthState get state => _state;

  /// Whether a request is currently being processed.
  bool get isLoading => _state == NaverAuthState.loading;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => client.auth.isAuthenticated;

  /// The current error, if the controller is in the error state.
  Object? get error => _state == NaverAuthState.error ? _error : null;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Runs the Naver sign-in flow: native login → server → client session.
  ///
  /// On success calls [onAuthenticated]; on failure transitions to the error
  /// state and calls [onError]. A user cancellation returns to [NaverAuthState.idle].
  Future<void> signIn() async {
    if (_state == NaverAuthState.loading) return;
    _setState(NaverAuthState.loading);

    try {
      final String? accessToken = await signInService.obtainAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        // User cancelled or no token was obtained.
        _setState(NaverAuthState.idle);
        return;
      }

      // Requires the serverpod_auth_idp_naver module to be wired into the app
      // client; otherwise Serverpod throws when resolving the endpoint.
      final endpoint = client.getEndpointOfType<EndpointNaverIdp>();
      final authSuccess = await endpoint.loginWithAccessToken(
        accessToken: accessToken,
      );
      await client.auth.updateSignedInUser(authSuccess);

      _setState(NaverAuthState.authenticated);
      onAuthenticated?.call();
    } catch (error) {
      _handleAuthenticationError(error);
    }
  }

  void _handleAuthenticationError(final Object error) {
    _error = error;
    _setState(NaverAuthState.error);
    debugPrint('[NaverAuthController] Authentication error: $error');

    // StateError signals a programming/config issue — don't surface to users.
    if (error is! StateError) onError?.call(error);
  }

  void _setState(final NaverAuthState newState) {
    if (_disposed) return;
    if (newState != NaverAuthState.error) _error = null;
    _state = newState;
    notifyListeners();
  }
}

/// States of the Naver authentication flow.
enum NaverAuthState {
  /// Initial idle state.
  idle,

  /// A request is being processed.
  loading,

  /// The last request ended with an error (see [NaverAuthController.error]).
  error,

  /// Authentication succeeded.
  authenticated,
}
