import 'package:serverpod_auth_idp_server/core.dart'
    show
        OAuth2PkceTokenResponse,
        OAuth2InvalidResponseException,
        OAuth2MissingAccessTokenException;

import '../exceptions/naver_exceptions.dart';

/// Details of the Naver Account.
///
/// All nullable fields are not guaranteed to be available from Naver's API,
/// since the user may decline to share their email or name.
typedef NaverAccountDetails = ({
  /// Naver's user identifier for this account.
  String userIdentifier,

  /// The email received from Naver (may be null if not consented).
  String? email,

  /// The user's name from Naver.
  String? name,

  /// The user's profile image URL.
  Uri? image,
});

/// Parses Naver's `GET /v1/nid/me` user info payload into [NaverAccountDetails].
///
/// [userInfo] is the **top-level** decoded JSON body from the user info
/// endpoint, which wraps the profile in a `response` object and carries a
/// top-level `resultcode`/`message` status.
///
/// This function is pure (no I/O, no database) so it can be unit tested in
/// isolation without code generation.
///
/// Throws:
/// - [NaverAccessTokenVerificationException] when `resultcode` is not `'00'`.
/// - [NaverUserInfoMissingDataException] when the `response` object or the
///   required `id` field is missing/empty.
NaverAccountDetails parseNaverProfile(final Map<String, dynamic> userInfo) {
  // Naver wraps the result code at the top level. Anything other than '00'
  // indicates a failed lookup (invalid/expired token, etc.).
  final resultCode = userInfo['resultcode'];
  if (resultCode != '00') {
    throw const NaverAccessTokenVerificationException();
  }

  final response = userInfo['response'] as Map<String, dynamic>?;
  if (response == null) {
    throw const NaverUserInfoMissingDataException();
  }

  final userId = response['id'] as String?;
  if (userId == null || userId.isEmpty) {
    throw const NaverUserInfoMissingDataException();
  }

  final email = response['email'] as String?;
  final name = response['name'] as String?;
  final profileImage = response['profile_image'] as String?;

  return (
    userIdentifier: userId,
    email: email?.toLowerCase(),
    name: name,
    image: profileImage != null ? Uri.tryParse(profileImage) : null,
  );
}

/// Parses Naver's OAuth2 token endpoint response into an
/// [OAuth2PkceTokenResponse].
///
/// Used as the `parseTokenResponse` callback for the provider's
/// `OAuth2PkceServerConfig`.
///
/// Throws:
/// - [OAuth2InvalidResponseException] when the body contains an `error`.
/// - [OAuth2MissingAccessTokenException] when no `access_token` is present.
OAuth2PkceTokenResponse parseNaverTokenResponse(
  final Map<String, dynamic> responseBody,
) {
  final error = responseBody['error'] as String?;
  if (error != null) {
    final errorDescription = responseBody['error_description'] as String?;
    throw OAuth2InvalidResponseException(
      'Invalid response from Naver:'
      ' $error${errorDescription != null ? ' - $errorDescription' : ''}',
    );
  }

  final accessToken = responseBody['access_token'] as String?;
  if (accessToken == null) {
    throw const OAuth2MissingAccessTokenException(
      'No access token in Naver response',
    );
  }

  return OAuth2PkceTokenResponse(accessToken: accessToken);
}
