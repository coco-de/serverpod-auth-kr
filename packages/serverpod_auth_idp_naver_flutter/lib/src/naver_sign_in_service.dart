/// Abstraction over the native Naver login SDK.
///
/// This package is SDK-agnostic: implement this interface with your preferred
/// Naver login mechanism (e.g. the `flutter_naver_login` package) and return
/// the OAuth2 **access token**, or `null` if the user cancelled.
///
/// The returned access token is sent to the server's `loginWithAccessToken`
/// endpoint, which calls Naver's user info API and creates/updates the user.
///
/// Example implementation with `flutter_naver_login`:
/// ```dart
/// class FlutterNaverLoginService implements NaverSignInService {
///   @override
///   Future<String?> obtainAccessToken() async {
///     final result = await FlutterNaverLogin.logIn();
///     if (result.status != NaverLoginStatus.loggedIn) return null;
///     final token = await FlutterNaverLogin.currentAccessToken;
///     return token.accessToken;
///   }
/// }
/// ```
abstract class NaverSignInService {
  /// Performs the native Naver login and returns the OAuth2 access token,
  /// or `null` if the user cancelled / no token was obtained.
  Future<String?> obtainAccessToken();
}
