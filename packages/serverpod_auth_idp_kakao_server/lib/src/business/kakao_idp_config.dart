import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../exceptions/kakao_exceptions.dart';
import 'kakao_idp.dart';
import 'kakao_profile.dart';

// KakaoAccount 는 `serverpod generate` 후 생성되는 모델이다.
// 생성 전까지는 아래 import 가 분석 에러를 일으킬 수 있으나 정상이다.
import '../generated/protocol.dart';

/// Function to be called to check whether a Kakao account details match the
/// requirements during registration.
typedef KakaoAccountDetailsValidation =
    void Function(KakaoAccountDetails accountDetails);

/// Function to be called to extract additional information from Kakao APIs
/// using the access token. The [session] and [transaction] can be used to
/// store additional information in the database.
typedef GetExtraKakaoInfoCallback =
    Future<void> Function(
      Session session, {
      required KakaoAccountDetails accountDetails,
      required String accessToken,
      required Transaction? transaction,
    });

/// Callback to be invoked after a new Kakao account has been created and
/// linked to an auth user. The [session] and [transaction] can be used to
/// perform additional database operations.
typedef AfterKakaoAccountCreatedFunction =
    FutureOr<void> Function(
      Session session,
      AuthUserModel authUser,
      KakaoAccount kakaoAccount, {
      required Transaction? transaction,
    });

/// Configuration for the Kakao identity provider.
class KakaoIdpConfig extends IdentityProviderBuilder<KakaoIdp> {
  /// The REST API key (client ID) from your Kakao Developers application.
  final String clientId;

  /// The client secret from your Kakao Developers application.
  ///
  /// This is only used if the "Client Secret" feature is enabled in the
  /// Kakao Developers console. When it is disabled, this should be `null`.
  final String? clientSecret;

  /// OAuth2 PKCE server config for Kakao.
  late final OAuth2PkceServerConfig oauth2Config;

  /// Validation function for Kakao account details.
  ///
  /// This function should throw an exception if the account details do not
  /// match the requirements. If the function returns normally, the account
  /// is considered valid.
  ///
  /// It can be used to enforce additional requirements on the Kakao account
  /// details before allowing the user to sign in. Note that Kakao users may
  /// decline to share their email or profile, so email and name may be null
  /// even for valid accounts.
  ///
  /// To avoid blocking real users with limited consent from signing in,
  /// adjust your validation function with care.
  final KakaoAccountDetailsValidation kakaoAccountDetailsValidation;

  /// Callback that can be used with the access token to extract additional
  /// information from Kakao.
  ///
  /// This callback is invoked after the Kakao account has been created.
  /// It runs on EVERY authentication attempt.
  ///
  /// **CRITICAL - Do NOT create these models in the callback:**
  /// - [KakaoAccount] - Breaks new account detection
  /// - [UserProfile] - Interferes with automatic profile creation
  /// - [AuthUser] - Already handled by the authentication flow
  ///
  /// Creating these models will cause the authentication flow in
  /// [KakaoIdp.login] to fail or skip critical steps like user profile
  /// creation.
  ///
  /// **Safe usage:** Store data in your own custom tables, linked by
  /// [KakaoAccountDetails.userIdentifier]. Keep operations lightweight.
  final GetExtraKakaoInfoCallback? getExtraKakaoInfoCallback;

  /// Callback to be invoked after a new Kakao account has been created
  /// and linked to an auth user.
  ///
  /// This can be used to perform additional setup tasks after the Kakao
  /// account has been created and linked.
  final AfterKakaoAccountCreatedFunction? onAfterKakaoAccountCreated;

  /// Creates a new instance of [KakaoIdpConfig].
  KakaoIdpConfig({
    required this.clientId,
    this.clientSecret,
    this.kakaoAccountDetailsValidation = validateKakaoAccountDetails,
    this.getExtraKakaoInfoCallback,
    this.onAfterKakaoAccountCreated,
  }) : oauth2Config = OAuth2PkceServerConfig(
         tokenEndpointUrl: Uri.https('kauth.kakao.com', '/oauth/token'),
         clientId: clientId,
         // Kakao's client secret is optional (only required when the
         // "Client Secret" feature is enabled). OAuth2PkceServerConfig requires
         // a non-null value, so an empty string is sent when unset — Kakao
         // ignores an empty client_secret when the feature is disabled.
         clientSecret: clientSecret ?? '',
         credentialsLocation: OAuth2CredentialsLocation.body,
         parseTokenResponse: parseKakaoTokenResponse,
       );

  /// Default validation function for Kakao account details.
  ///
  /// This default implementation accepts all accounts as Kakao's optional
  /// fields (email, name) are intentionally optional for user privacy.
  /// Override this if you need to enforce specific requirements.
  static void validateKakaoAccountDetails(
    final KakaoAccountDetails accountDetails,
  ) {
    if (accountDetails.userIdentifier.isEmpty) {
      throw const KakaoUserInfoMissingDataException();
    }
  }

  @override
  KakaoIdp build({
    required final TokenManager tokenManager,
    required final AuthUsers authUsers,
    required final UserProfiles userProfiles,
  }) {
    return KakaoIdp(
      this,
      tokenIssuer: tokenManager,
      authUsers: authUsers,
      userProfiles: userProfiles,
    );
  }
}

/// Creates a new [KakaoIdpConfig] from keys on the `passwords.yaml` file.
///
/// This constructor requires that a [Serverpod] instance has already been
/// initialized.
///
/// The following keys are read from the `passwords.yaml` file:
/// - `kakaoClientId` (required): The REST API key from your Kakao application.
/// - `kakaoClientSecret` (optional): The client secret, only required when the
///   "Client Secret" feature is enabled in the Kakao Developers console.
///
/// Example `passwords.yaml`:
/// ```yaml
/// kakaoClientId: 'your-kakao-rest-api-key'
/// kakaoClientSecret: 'your-kakao-client-secret'
/// ```
class KakaoIdpConfigFromPasswords extends KakaoIdpConfig {
  /// Creates a new [KakaoIdpConfigFromPasswords] instance.
  KakaoIdpConfigFromPasswords({
    super.kakaoAccountDetailsValidation,
    super.getExtraKakaoInfoCallback,
    super.onAfterKakaoAccountCreated,
  }) : super(
         clientId: _requirePassword('kakaoClientId'),
         clientSecret: Serverpod.instance.getPassword('kakaoClientSecret'),
       );

  /// Reads a required [key] from the `passwords.yaml` file via the public
  /// Serverpod API, throwing a [StateError] when the key is missing.
  static String _requirePassword(final String key) {
    final password = Serverpod.instance.getPassword(key);
    if (password == null) {
      throw StateError(
        'Missing password "$key" in passwords.yaml. Add it before using '
        'KakaoIdpConfigFromPasswords.',
      );
    }
    return password;
  }
}
