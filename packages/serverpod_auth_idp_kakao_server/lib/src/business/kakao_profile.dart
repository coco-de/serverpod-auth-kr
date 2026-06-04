import 'package:serverpod_auth_idp_server/core.dart'
    show
        OAuth2PkceTokenResponse,
        OAuth2InvalidResponseException,
        OAuth2MissingAccessTokenException;

import '../exceptions/kakao_exceptions.dart';

/// Details of the Kakao Account.
///
/// All nullable fields are not guaranteed to be available from Kakao's API,
/// since the user may decline the corresponding consent items.
typedef KakaoAccountDetails = ({
  /// Kakao's user identifier for this account (stringified numeric `id`).
  String userIdentifier,

  /// The email received from Kakao (may be null if not consented).
  String? email,

  /// The user's nickname from Kakao.
  String? name,

  /// The user's profile image URL.
  Uri? image,
});

/// Parses Kakao's `GET /v2/user/me` user info payload into
/// [KakaoAccountDetails].
///
/// [userInfo] is the decoded JSON body from the user info endpoint. The numeric
/// top-level `id` is required; `email`, `nickname` and `profile_image_url` live
/// under `kakao_account` / `kakao_account.profile` and depend on the user's
/// consent (so they may be absent).
///
/// This function is pure (no I/O, no database) so it can be unit tested in
/// isolation without code generation.
///
/// Throws [KakaoUserInfoMissingDataException] when the required `id` is missing.
KakaoAccountDetails parseKakaoProfile(final Map<String, dynamic> userInfo) {
  final userId = userInfo['id'];
  if (userId == null) {
    throw const KakaoUserInfoMissingDataException();
  }

  final kakaoAccount = userInfo['kakao_account'] as Map<String, dynamic>?;
  final email = kakaoAccount?['email'] as String?;

  final profile = kakaoAccount?['profile'] as Map<String, dynamic>?;
  final nickname = profile?['nickname'] as String?;
  final profileImageUrl = profile?['profile_image_url'] as String?;

  return (
    userIdentifier: userId.toString(),
    email: email?.toLowerCase(),
    name: nickname,
    image: profileImageUrl != null ? Uri.tryParse(profileImageUrl) : null,
  );
}

/// Parses Kakao's OAuth2 token endpoint response into an
/// [OAuth2PkceTokenResponse].
///
/// Used as the `parseTokenResponse` callback for the provider's
/// `OAuth2PkceServerConfig`.
///
/// Throws:
/// - [OAuth2InvalidResponseException] when the body contains an `error`.
/// - [OAuth2MissingAccessTokenException] when no `access_token` is present.
OAuth2PkceTokenResponse parseKakaoTokenResponse(
  final Map<String, dynamic> responseBody,
) {
  final error = responseBody['error'] as String?;
  if (error != null) {
    final errorDescription = responseBody['error_description'] as String?;
    throw OAuth2InvalidResponseException(
      'Invalid response from Kakao:'
      ' $error${errorDescription != null ? ' - $errorDescription' : ''}',
    );
  }

  final accessToken = responseBody['access_token'] as String?;
  if (accessToken == null) {
    throw const OAuth2MissingAccessTokenException(
      'No access token in Kakao response',
    );
  }

  return OAuth2PkceTokenResponse(accessToken: accessToken);
}
