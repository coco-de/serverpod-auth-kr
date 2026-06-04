import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_kakao_server/serverpod_auth_idp_kakao_server.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthUsers;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Builds a mock HTTP client that emulates Kakao's `/v2/user/me` endpoint
/// (numeric top-level `id`, nested `kakao_account` / `profile`).
http.Client _mockKakaoClient({
  required final int id,
  final String? email,
  final String? nickname,
}) {
  return MockClient((final request) async {
    if (request.url.host == 'kapi.kakao.com') {
      return http.Response(
        jsonEncode({
          'id': id,
          'kakao_account': {
            if (email != null) 'email': email,
            'profile': {if (nickname != null) 'nickname': nickname},
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('not found', 404);
  });
}

KakaoIdpUtils _utils(final http.Client client) => KakaoIdpUtils(
  config: KakaoIdpConfig(clientId: 'test-rest-api-key'),
  authUsers: const AuthUsers(),
  httpClient: client,
);

void main() {
  withServerpod('Given KakaoIdpUtils.authenticate', (
    final sessionBuilder,
    final endpoints,
  ) {
    late Session session;

    setUp(() {
      session = sessionBuilder.build();
    });

    test(
      'when authenticating a new user then it creates an AuthUser and a KakaoAccount',
      () async {
        final result = await _utils(
          _mockKakaoClient(
            id: 1234567890,
            email: 'User@Kakao.com',
            nickname: '카카오유저',
          ),
        ).authenticate(session, accessToken: 'fake-token', transaction: null);

        expect(result.newAccount, isTrue);
        expect(result.details.userIdentifier, '1234567890'); // int → String
        expect(result.details.email, 'user@kakao.com'); // lowercased

        final account = await KakaoAccount.db.findFirstRow(
          session,
          where: (final t) => t.userIdentifier.equals('1234567890'),
        );
        expect(account, isNotNull);
        expect(account!.authUserId, result.authUserId);
        expect(account.email, 'user@kakao.com');
      },
    );

    test(
      'when authenticating the same Kakao id twice then it reuses the AuthUser (dedup)',
      () async {
        final client = _mockKakaoClient(
          id: 42,
          email: 'a@b.com',
          nickname: 'A',
        );

        final first = await _utils(
          client,
        ).authenticate(session, accessToken: 't1', transaction: null);
        final second = await _utils(
          client,
        ).authenticate(session, accessToken: 't2', transaction: null);

        expect(first.newAccount, isTrue);
        expect(second.newAccount, isFalse);
        expect(second.authUserId, first.authUserId);

        final accounts = await KakaoAccount.db.find(
          session,
          where: (final t) => t.userIdentifier.equals('42'),
        );
        expect(accounts, hasLength(1));
      },
    );

    test(
      'when authenticating without email consent then it stores a null email',
      () async {
        final result = await _utils(
          _mockKakaoClient(id: 999),
        ).authenticate(session, accessToken: 't', transaction: null);

        expect(result.details.email, isNull);
        final account = await KakaoAccount.db.findFirstRow(
          session,
          where: (final t) => t.userIdentifier.equals('999'),
        );
        expect(account!.email, isNull);
      },
    );
  });
}
