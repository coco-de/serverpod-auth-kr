import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:serverpod_auth_idp_kakao_flutter/serverpod_auth_idp_kakao_flutter.dart';

/// Concrete [KakaoSignInService] backed by the `kakao_flutter_sdk_user` SDK.
///
/// Wire this into [KakaoAuthController]:
/// ```dart
/// final controller = KakaoAuthController(
///   client: client,
///   signInService: KakaoSdkSignInService(),
///   onAuthenticated: () { /* react to auth state */ },
/// );
/// ```
///
/// Requires `KakaoSdk.init(nativeAppKey: '<NATIVE_APP_KEY>')` at app start and
/// native setup per the Kakao SDK docs (Android KeyHash / iOS URL scheme).
class KakaoSdkSignInService implements KakaoSignInService {
  @override
  Future<String?> obtainAccessToken() async {
    // Prefer the KakaoTalk app login when available, otherwise fall back to the
    // Kakao account (web) login.
    final installed = await isKakaoTalkInstalled();
    final OAuthToken token = installed
        ? await UserApi.instance.loginWithKakaoTalk()
        : await UserApi.instance.loginWithKakaoAccount();

    final accessToken = token.accessToken;
    return accessToken.isEmpty ? null : accessToken;
  }
}
