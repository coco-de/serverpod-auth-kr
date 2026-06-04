# serverpod_auth_idp_kakao_flutter

Flutter client for the Kakao identity provider of the Serverpod auth IdP module.

> **Status:** Skeleton. The Kakao SDK login call and the generated client
> endpoint call are marked with `TODO` and throw `UnimplementedError`.

## What's included

- `KakaoAuthController` — a `ChangeNotifier` that drives the Kakao sign-in flow,
  mirroring the canonical `GitHubAuthController`. It exposes `state`, `isLoading`,
  `isAuthenticated`, `error`, and a `signIn()` method.
- `KakaoSignInButton` — a Kakao-branded button (`#FEE500` background, black
  `카카오 로그인` label) with loading and disabled states.

## Flow

1. The controller uses `kakao_flutter_sdk_user` to log in and obtain an
   `authorization code` and a PKCE `codeVerifier`.
2. It calls the generated Kakao IdP endpoint:
   `endpoint.login(code: code, codeVerifier: codeVerifier, redirectUri: redirectUri)`.
3. On success it calls `client.auth.updateSignedInUser(authSuccess)`.

## Usage

```dart
final controller = KakaoAuthController(
  client: client,
  redirectUri: 'kakao{NATIVE_APP_KEY}://oauth',
  onAuthenticated: () {
    // 인증 완료 처리 (홈 화면 네비게이션은 여기서 하지 말 것).
  },
  onError: (error) {
    // 사용자에게 오류 표시.
  },
);

KakaoSignInButton(
  isLoading: controller.isLoading,
  onPressed: controller.signIn,
);
```

## Implementing the skeleton

Fill in `_signInWithKakaoSdk` and `_handleServerSideSignIn` in
`lib/src/kakao_auth_controller.dart` once the server package has been generated
with `serverpod generate`. The TODO comments contain the recommended SDK calls.
