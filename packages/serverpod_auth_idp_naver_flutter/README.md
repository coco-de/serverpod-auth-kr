# serverpod_auth_idp_naver_flutter

Serverpod 의 Naver IdP(Identity Provider)와 연동하는 Flutter 클라이언트 패키지입니다.
Naver SDK / OAuth2 authorization code flow 로 authorization code 를 획득한 뒤,
서버의 Naver IdP 엔드포인트로 로그인을 위임합니다.

> **상태**: 스켈레톤. Naver SDK 호출부와 생성된 모듈 엔드포인트 호출부는 `TODO`
> 주석과 시그니처로만 표기되어 있습니다. 정본 `serverpod_auth_idp` 의 `github`
> provider 를 미러링했습니다.

## 구성 요소

| 항목 | 설명 |
|------|------|
| `NaverAuthController` | 인증 플로우 컨트롤러. `signIn()` → code 획득 → 서버 위임 → `updateSignedInUser`. |
| `NaverSignInButton` | Naver 브랜드 녹색(#03C75A) + 흰색 텍스트 로그인 버튼 위젯. |

## 사용 예시

```dart
import 'package:serverpod_auth_idp_naver_flutter/serverpod_auth_idp_naver_flutter.dart';

final controller = NaverAuthController(
  client: client,
  redirectUri: 'https://your-app.example.com/auth/naver/callback',
  onAuthenticated: () {
    // 인증 성공 처리 (홈으로 즉시 이동하지 말 것).
  },
  onError: (error) {
    // 사용자에게 오류 표시.
  },
);

NaverSignInButton(
  onPressed: controller.signIn,
  isLoading: controller.isLoading,
);
```

## 로그인 흐름

1. `flutter_naver_login` SDK(또는 OAuth2 웹 플로우)로 `code` + `state` 획득.
2. `endpoint.login(code, codeVerifier, redirectUri)` 로 서버에 위임 → `AuthSuccess`.
3. `client.auth.updateSignedInUser(authSuccess)` 로 클라이언트 인증 상태 갱신.

## 라이선스

BSD 3-Clause. `LICENSE` 파일 참조.
