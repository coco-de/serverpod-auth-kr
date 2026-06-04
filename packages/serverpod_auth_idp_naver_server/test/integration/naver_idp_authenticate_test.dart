import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_naver_server/serverpod_auth_idp_naver_server.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthUsers;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Builds a mock HTTP client that emulates Naver's `/v1/nid/me` endpoint.
http.Client _mockNaverClient({
  required final String id,
  final String? email,
  final String? name,
}) {
  return MockClient((final request) async {
    if (request.url.host == 'openapi.naver.com') {
      return http.Response(
        jsonEncode({
          'resultcode': '00',
          'message': 'success',
          'response': {
            'id': id,
            if (email != null) 'email': email,
            if (name != null) 'name': name,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('not found', 404);
  });
}

NaverIdpUtils _utils(final http.Client client) => NaverIdpUtils(
  config: NaverIdpConfig(clientId: 'test-client-id', clientSecret: 'secret'),
  authUsers: const AuthUsers(),
  httpClient: client,
);

void main() {
  withServerpod('Given NaverIdpUtils.authenticate', (
    final sessionBuilder,
    final endpoints,
  ) {
    late Session session;

    setUp(() {
      session = sessionBuilder.build();
    });

    test(
      'when authenticating a new user then it creates an AuthUser and a NaverAccount',
      () async {
        final result = await _utils(
          _mockNaverClient(
            id: '32742776',
            email: 'User@Naver.com',
            name: '홍길동',
          ),
        ).authenticate(session, accessToken: 'fake-token', transaction: null);

        expect(result.newAccount, isTrue);
        expect(result.details.userIdentifier, '32742776');
        expect(result.details.email, 'user@naver.com'); // lowercased

        final account = await NaverAccount.db.findFirstRow(
          session,
          where: (final t) => t.userIdentifier.equals('32742776'),
        );
        expect(account, isNotNull);
        expect(account!.authUserId, result.authUserId);
        expect(account.email, 'user@naver.com');
      },
    );

    test(
      'when authenticating the same Naver id twice then it reuses the AuthUser (dedup)',
      () async {
        final client = _mockNaverClient(
          id: 'dup-1',
          email: 'a@b.com',
          name: 'A',
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

        final accounts = await NaverAccount.db.find(
          session,
          where: (final t) => t.userIdentifier.equals('dup-1'),
        );
        expect(accounts, hasLength(1));
      },
    );

    test(
      'when getAccount has no authenticated session then it returns null',
      () async {
        final account = await _utils(
          _mockNaverClient(id: 'x'),
        ).getAccount(session);
        expect(account, isNull);
      },
    );
  });
}
