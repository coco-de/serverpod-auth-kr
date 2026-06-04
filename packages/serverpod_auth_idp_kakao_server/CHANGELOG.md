# Changelog

## 0.1.0

- Initial scaffold of the Kakao identity provider for `serverpod_auth_idp`.
- OAuth2 authorization code flow with PKCE (`code` + `codeVerifier`).
- `KakaoIdpConfig` / `KakaoIdpConfigFromPasswords` configuration.
- `KakaoIdp.login` flow: token exchange → authenticate → user profile creation → token issuance.
- `KakaoIdpEndpoint` exposing `login` and `hasAccount`.
- `KakaoAccount` model (`serverpod_auth_idp_kakao_account`).
