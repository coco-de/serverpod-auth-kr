/// Kakao identity provider for the Serverpod authentication module
/// (`serverpod_auth_idp`).
///
/// Configure the provider via [KakaoIdpConfig] (or
/// [KakaoIdpConfigFromPasswords]) and expose [KakaoIdpEndpoint] from your
/// server to enable Kakao sign-in.
library;

export 'src/business/kakao_idp.dart';
export 'src/business/kakao_idp_admin.dart';
export 'src/business/kakao_idp_config.dart';
export 'src/business/kakao_idp_utils.dart'
    show KakaoAccountDetails, KakaoAuthSuccess, KakaoIdpUtils;
export 'src/endpoints/kakao_idp_endpoint.dart';
export 'src/exceptions/kakao_exceptions.dart';

// 아래 generated 모델은 `serverpod generate` 실행 후 생성된다.
// 생성 후 활성화하면 KakaoAccount 등 모델 타입을 외부에 노출할 수 있다.
// export 'src/generated/protocol.dart';
