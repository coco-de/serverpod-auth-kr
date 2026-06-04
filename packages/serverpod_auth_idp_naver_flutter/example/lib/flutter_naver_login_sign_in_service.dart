import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:serverpod_auth_idp_naver_flutter/serverpod_auth_idp_naver_flutter.dart';

/// Concrete [NaverSignInService] backed by the `flutter_naver_login` SDK.
///
/// Wire this into [NaverAuthController]:
/// ```dart
/// final controller = NaverAuthController(
///   client: client,
///   signInService: FlutterNaverLoginSignInService(),
///   onAuthenticated: () { /* react to auth state */ },
/// );
/// ```
///
/// Requires native setup per `flutter_naver_login` docs (Android `strings.xml`
/// / iOS `Info.plist` with the Naver Client ID/Secret + URL scheme).
class FlutterNaverLoginSignInService implements NaverSignInService {
  @override
  Future<String?> obtainAccessToken() async {
    final result = await FlutterNaverLogin.logIn();
    if (result.status != NaverLoginStatus.loggedIn) {
      // Cancelled by the user or an error occurred.
      return null;
    }

    final token = await FlutterNaverLogin.currentAccessToken;
    final accessToken = token.accessToken;
    return accessToken.isEmpty ? null : accessToken;
  }
}
