import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../business/naver_idp.dart';

/// Endpoint for Naver Account-based authentication.
///
/// This endpoint exposes methods for logging in users using Naver
/// authorization codes.
///
/// The canonical upstream provider extends `IdpBaseEndpoint`, which is not part
/// of the public API. This endpoint therefore extends Serverpod's [Endpoint]
/// directly and delegates the authentication flow to the configured [NaverIdp]
/// instance.
///
/// If you would like to modify the authentication flow, consider extending
/// this class and overriding the relevant methods.
class NaverIdpEndpoint extends Endpoint {
  /// Accessor for the configured Naver Idp instance.
  ///
  /// By default this uses the global instance configured in [AuthServices].
  /// If you want to use a different instance, override this getter.
  NaverIdp get naverIdp => AuthServices.instance.naverIdp;

  /// {@template naver_idp_endpoint.login}
  /// Validates a Naver authorization code and either logs in the associated
  /// user or creates a new user account if the Naver account ID is not yet
  /// known.
  ///
  /// This method exchanges the `authorization code` for an `access token`,
  /// then authenticates the user.
  ///
  /// If a new user is created an associated `UserProfile` is also created.
  ///
  /// [codeVerifier] is optional because Naver does not document PKCE support.
  /// {@endtemplate}
  Future<AuthSuccess> login(
    final Session session, {
    required final String code,
    final String? codeVerifier,
    required final String redirectUri,
  }) async {
    return naverIdp.login(
      session,
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    );
  }

  /// Determines whether the current session has an associated Naver account.
  Future<bool> hasAccount(final Session session) async =>
      naverIdp.hasAccount(session);
}
