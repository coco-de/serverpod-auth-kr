/// Naver identity provider for Serverpod's authentication module.
///
/// This library mirrors the upstream GitHub OAuth2 provider, adapted for
/// Naver Login (NID). It exposes the configuration, business logic, and
/// endpoint required to authenticate users with their Naver accounts.
library;

export 'src/business/naver_idp.dart';
export 'src/business/naver_idp_admin.dart';
export 'src/business/naver_idp_config.dart';
// Re-exports the [NaverAccountDetails] / [NaverAuthSuccess] records and the
// [NaverIdpUtils] helper.
export 'src/business/naver_idp_utils.dart';
export 'src/endpoints/naver_idp_endpoint.dart';
export 'src/exceptions/naver_exceptions.dart';

// The generated [NaverAccount] model is produced by `serverpod generate`.
// After running code generation, it is available via:
//   export 'generated/protocol.dart';
