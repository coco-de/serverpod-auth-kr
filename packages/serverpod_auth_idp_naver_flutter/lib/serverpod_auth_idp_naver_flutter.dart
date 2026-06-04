/// Flutter client for the Naver identity provider of `serverpod_auth_idp`.
///
/// Provides [NaverAuthController] (access-token flow → server
/// `loginWithAccessToken`), the SDK-agnostic [NaverSignInService] interface,
/// and a Naver-branded [NaverSignInButton].
library;

export 'src/naver_auth_controller.dart';
export 'src/naver_sign_in_button.dart';
export 'src/naver_sign_in_service.dart';
