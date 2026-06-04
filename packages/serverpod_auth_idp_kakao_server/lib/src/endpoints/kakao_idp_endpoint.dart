import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../business/kakao_idp.dart';

/// Endpoint for Kakao account-based authentication.
///
/// This endpoint exposes methods for logging in users using Kakao
/// authorization codes.
///
/// `IdpBaseEndpoint` is not part of the public API, therefore this endpoint
/// extends Serverpod's [Endpoint] directly and delegates to the configured
/// [KakaoIdp] instance.
///
/// If you would like to modify the authentication flow, consider extending
/// this class and overriding the relevant methods.
class KakaoIdpEndpoint extends Endpoint {
  /// Accessor for the configured Kakao Idp instance.
  ///
  /// By default this uses the global instance configured in [AuthServices].
  /// If you want to use a different instance, override this getter.
  KakaoIdp get kakaoIdp => AuthServices.instance.kakaoIdp;

  /// Validates a Kakao authorization code and either logs in the associated
  /// user or creates a new user account if the Kakao account ID is not yet
  /// known.
  ///
  /// This method exchanges the `authorization code` for an `access token`
  /// using PKCE, then authenticates the user.
  ///
  /// The [code] is the authorization code returned by Kakao's OAuth flow, the
  /// [codeVerifier] is the PKCE code verifier used to generate the code
  /// challenge, and the [redirectUri] must match the redirect URI used in the
  /// authorization request.
  ///
  /// If a new user is created an associated user profile is also created.
  Future<AuthSuccess> login(
    final Session session, {
    required final String code,
    required final String codeVerifier,
    required final String redirectUri,
  }) async {
    return kakaoIdp.login(
      session,
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    );
  }

  /// Determines whether the current session has an associated Kakao account.
  Future<bool> hasAccount(final Session session) async =>
      kakaoIdp.hasAccount(session);
}
