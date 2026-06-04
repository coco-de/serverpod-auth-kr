import 'package:serverpod/serverpod.dart';

import 'kakao_idp_utils.dart';
import 'kakao_profile.dart';

// KakaoAccount 는 `serverpod generate` 후 생성되는 모델이다.
import '../generated/protocol.dart';

/// Collection of Kakao-account admin methods.
class KakaoIdpAdmin {
  /// Utility functions for the Kakao identity provider.
  final KakaoIdpUtils utils;

  /// Creates a new instance of [KakaoIdpAdmin].
  const KakaoIdpAdmin({required this.utils});

  /// Returns the account details for the given [accessToken].
  Future<KakaoAccountDetails> fetchAccountDetails(
    final Session session, {
    required final String accessToken,
  }) async {
    return utils.fetchAccountDetails(session, accessToken: accessToken);
  }

  /// Adds a Kakao authentication to the given [authUserId].
  ///
  /// Returns the newly created Kakao account.
  Future<KakaoAccount> linkKakaoAuthentication(
    final Session session, {
    required final UuidValue authUserId,
    required final KakaoAccountDetails accountDetails,
    final Transaction? transaction,
  }) async {
    return utils.linkKakaoAuthentication(
      session,
      authUserId: authUserId,
      accountDetails: accountDetails,
      transaction: transaction,
    );
  }

  /// Return the `AuthUser` id for the Kakao user id, if any.
  static Future<UuidValue?> findUserByKakaoUserId(
    final Session session, {
    required final String userIdentifier,
    final Transaction? transaction,
  }) async {
    final account = await KakaoAccount.db.findFirstRow(
      session,
      where: (final t) => t.userIdentifier.equals(userIdentifier),
      transaction: transaction,
    );

    return account?.authUserId;
  }
}
