# Changelog

## 0.1.0

- Initial release.
- Naver identity provider mirroring the upstream Serverpod GitHub OAuth2
  provider.
- OAuth2 authorization-code login flow against `nid.naver.com` token endpoint
  and `openapi.naver.com/v1/nid/me` user info endpoint.
- `NaverIdpConfig` / `NaverIdpConfigFromPasswords`, `NaverIdp`, `NaverIdpUtils`,
  `NaverIdpAdmin`, and `NaverIdpEndpoint`.
- `NaverAccount` model (`serverpod_auth_idp_naver_account` table).
