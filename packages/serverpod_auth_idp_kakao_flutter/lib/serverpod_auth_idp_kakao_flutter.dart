/// Flutter client for the Kakao identity provider of `serverpod_auth_idp`.
///
/// Provides [KakaoAuthController] (access-token flow → server
/// `loginWithAccessToken`), the SDK-agnostic [KakaoSignInService] interface,
/// and a Kakao-branded [KakaoSignInButton].
library;

export 'src/kakao_auth_controller.dart';
export 'src/kakao_sign_in_button.dart';
export 'src/kakao_sign_in_service.dart';
