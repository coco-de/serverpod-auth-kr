import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'naver_idp_utils.dart';

/// Collection of Naver-account admin methods.
class NaverIdpAdmin {
  /// Utility functions for the Naver identity provider.
  final NaverIdpUtils utils;

  /// Creates a new instance of [NaverIdpAdmin].
  const NaverIdpAdmin({required this.utils});

  /// Returns the account details for the given [accessToken].
  Future<NaverAccountDetails> fetchAccountDetails(
    final Session session, {
    required final String accessToken,
  }) async {
    return utils.fetchAccountDetails(session, accessToken: accessToken);
  }

  /// Adds a Naver authentication to the given [authUserId].
  ///
  /// Returns the newly created Naver account.
  Future<NaverAccount> linkNaverAuthentication(
    final Session session, {
    required final UuidValue authUserId,
    required final NaverAccountDetails accountDetails,
    final Transaction? transaction,
  }) async {
    return utils.linkNaverAuthentication(
      session,
      authUserId: authUserId,
      accountDetails: accountDetails,
      transaction: transaction,
    );
  }

  /// Return the `AuthUser` id for the Naver user id, if any.
  static Future<UuidValue?> findUserByNaverUserId(
    final Session session, {
    required final String userIdentifier,
    final Transaction? transaction,
  }) async {
    final account = await NaverAccount.db.findFirstRow(
      session,
      where: (final t) => t.userIdentifier.equals(userIdentifier),
      transaction: transaction,
    );

    return account?.authUserId;
  }
}
