# E2E 실행 런북 (실 Kakao/Naver OAuth)

실제 Kakao/Naver 로그인 → 서버 `loginWithAccessToken` → 사용자 생성까지의 **인터랙티브 E2E**를 디바이스에서 실행하는 절차. (로그인 자체는 사람이 디바이스에서 수행)

## 0. 사전 준비 (콘솔 키)

`docs/oauth-setup.md` 따라 발급:
- Kakao: REST API 키(server `kakaoClientId`), **Native 앱 키**(client `KakaoSdk.init`), (선택) Client Secret
- Naver: Client ID/Secret(server), Client ID/Secret + URL scheme(client)

## 1. 서버 기동 (provider 등록)

호스트 serverpod 앱(또는 통합 대상)에서:

```dart
AuthServices.set(
  identityProviderBuilders: [
    // ... 기존 provider
    KakaoIdpConfigFromPasswords(),  // kakaoClientId/Secret 읽음
    NaverIdpConfigFromPasswords(),  // naverClientId/Secret 읽음
  ],
);
```

`config/passwords.yaml` (gitignore):
```yaml
shared:
  kakaoClientId: '<KAKAO_REST_API_KEY>'
  kakaoClientSecret: '<KAKAO_CLIENT_SECRET>'   # 활성화한 경우만
  naverClientId: '<NAVER_CLIENT_ID>'
  naverClientSecret: '<NAVER_CLIENT_SECRET>'
```

`serverpod generate` → 마이그레이션 적용 → 서버 실행.

## 2. 클라이언트 (디바이스)

각 flutter 패키지의 `example/lib/`에 SDK 연동 `SignInService` 구현 제공:
- `FlutterNaverLoginSignInService` (flutter_naver_login)
- `KakaoSdkSignInService` (kakao_flutter_sdk_user)

앱 시작 시:
```dart
KakaoSdk.init(nativeAppKey: '<KAKAO_NATIVE_APP_KEY>');
```

네이티브 설정(필수):
- **Kakao**: Android KeyHash 등록 + iOS URL scheme(`kakao{NATIVE_APP_KEY}`), `AndroidManifest`/`Info.plist`
- **Naver**: Android `strings.xml`(client id/secret/name) + iOS `Info.plist`(URL scheme `naver{...}`)

로그인 화면:
```dart
final controller = NaverAuthController(   // 또는 KakaoAuthController
  client: client,
  signInService: FlutterNaverLoginSignInService(),
  onAuthenticated: () { /* 인증 상태 반영 */ },
  onError: (e) { /* 사용자 알림 */ },
);
// 버튼
NaverSignInButton(onPressed: controller.signIn, isLoading: controller.isLoading);
```

## 3. 실행 (사람이 디바이스에서)

```bash
cd packages/serverpod_auth_idp_naver_flutter/example   # 또는 _kakao
flutter run   # 실 디바이스/에뮬레이터
```

1. 버튼 탭 → 네이티브 Kakao/Naver 로그인 → 계정 인증 (사람)
2. SDK가 access token 반환 → `loginWithAccessToken(accessToken)` 호출
3. 서버가 `openapi.naver.com/v1/nid/me` / `kapi.kakao.com/v2/user/me` 호출 → `{Provider}Account` + `AuthUser` + `UserProfile` 생성 → 세션 발급
4. `controller.isAuthenticated == true`, `onAuthenticated` 호출

## 4. 검증 (서버 DB)

```sql
SELECT * FROM serverpod_auth_idp_naver_account ORDER BY created DESC LIMIT 5;
SELECT * FROM serverpod_auth_core_user ORDER BY id DESC LIMIT 5;
SELECT * FROM serverpod_auth_core_profile ORDER BY id DESC LIMIT 5;
```
신규 로그인 시 row 생성, 동일 계정 재로그인 시 AuthUser 재사용(account row 1개) 확인.

## 대안 — 서버 단독 토큰 검증 (앱/디바이스 없이)

디바이스 없이 서버 round-trip만 확인하려면, OAuth playground 등으로 **실 access token**을 1회 발급해 서버 endpoint를 직접 호출:

```bash
# 토큰은 단명 시크릿 — 로컬에서만, 커밋/로그 금지
curl -X POST http://localhost:8080/naverIdp/loginWithAccessToken \
  -H 'Content-Type: application/json' \
  -d '{"accessToken":"<REAL_NAVER_ACCESS_TOKEN>"}'
# → AuthSuccess 응답 + DB에 사용자 생성 확인
```

> ⚠️ access token은 단명 시크릿입니다. 채팅/커밋/로그에 남기지 마세요.

## 자동 검증 현황 (이미 통과)

| 레벨 | 상태 |
|------|------|
| 순수 파싱(단위) | ✅ naver 10 / kakao 9 |
| authenticate(withServerpod, 실 DB, userinfo 목킹) | ✅ naver 3 / kakao 3 |
| beta.9 소스 호환 | ✅ analyze 0 + 단위 통과 |
| SDK SignInService 컴파일 | ✅ flutter analyze 0 (example) |
| **실 OAuth 라운드트립** | ⏳ 본 런북으로 사람이 디바이스 실행 |
