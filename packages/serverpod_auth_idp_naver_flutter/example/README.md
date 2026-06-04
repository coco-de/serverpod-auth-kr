# serverpod_auth_idp_naver_flutter — example

`flutter_naver_login` 기반 `NaverSignInService` 참조 구현.

- [`lib/flutter_naver_login_sign_in_service.dart`](lib/flutter_naver_login_sign_in_service.dart) — `FlutterNaverLoginSignInService`

`NaverAuthController(signInService: FlutterNaverLoginSignInService())`로 연결.

실 OAuth E2E 실행 절차: [`../../../docs/e2e-runbook.md`](../../../docs/e2e-runbook.md)
네이티브 설정(Naver Client ID/Secret, URL scheme): [`../../../docs/oauth-setup.md`](../../../docs/oauth-setup.md)
