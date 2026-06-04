/// Exception thrown when verifying the Kakao access token fails.
///
/// This is raised when the authorization code could not be exchanged for an
/// access token, or when Kakao's user API rejects the access token.
class KakaoAccessTokenVerificationException implements Exception {
  /// Creates a new [KakaoAccessTokenVerificationException].
  const KakaoAccessTokenVerificationException();

  @override
  String toString() =>
      'KakaoAccessTokenVerificationException: '
      'Failed to verify the Kakao access token.';
}

/// Exception thrown when the user info from Kakao is missing required data.
///
/// At minimum a non-empty `userIdentifier` is required to authenticate a user.
class KakaoUserInfoMissingDataException implements Exception {
  /// Creates a new [KakaoUserInfoMissingDataException].
  const KakaoUserInfoMissingDataException();

  @override
  String toString() =>
      'KakaoUserInfoMissingDataException: '
      'The user info received from Kakao is missing required data.';
}
