# serverpod_auth_idp_kakao_flutter — example

`kakao_flutter_sdk_user` 기반 `KakaoSignInService` 참조 구현.

- [`lib/kakao_sdk_sign_in_service.dart`](lib/kakao_sdk_sign_in_service.dart) — `KakaoSdkSignInService`

`KakaoAuthController(signInService: KakaoSdkSignInService())`로 연결.
앱 시작 시 `KakaoSdk.init(nativeAppKey: '<NATIVE_APP_KEY>')` 필수.

실 OAuth E2E 실행 절차: [`../../../docs/e2e-runbook.md`](../../../docs/e2e-runbook.md)
네이티브 설정(Kakao KeyHash/URL scheme): [`../../../docs/oauth-setup.md`](../../../docs/oauth-setup.md)
