/// Abstraction over the native Kakao login SDK.
///
/// This package is SDK-agnostic: implement this interface with your preferred
/// Kakao login mechanism (e.g. the `kakao_flutter_sdk_user` package) and return
/// the OAuth2 **access token**, or `null` if the user cancelled.
///
/// The returned access token is sent to the server's `loginWithAccessToken`
/// endpoint, which calls Kakao's user API and creates/updates the user.
///
/// Example implementation with `kakao_flutter_sdk_user`:
/// ```dart
/// class KakaoSdkSignInService implements KakaoSignInService {
///   @override
///   Future<String?> obtainAccessToken() async {
///     final token = await isKakaoTalkInstalled()
///         ? await UserApi.instance.loginWithKakaoTalk()
///         : await UserApi.instance.loginWithKakaoAccount();
///     return token.accessToken;
///   }
/// }
/// ```
abstract class KakaoSignInService {
  /// Performs the native Kakao login and returns the OAuth2 access token,
  /// or `null` if the user cancelled / no token was obtained.
  Future<String?> obtainAccessToken();
}
