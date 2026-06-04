import 'package:serverpod_auth_idp_naver_server/src/business/naver_profile.dart';
import 'package:serverpod_auth_idp_naver_server/src/exceptions/naver_exceptions.dart';
import 'package:serverpod_auth_idp_server/core.dart'
    show OAuth2InvalidResponseException, OAuth2MissingAccessTokenException;
import 'package:test/test.dart';

void main() {
  group('parseNaverProfile', () {
    Map<String, dynamic> body(final Map<String, dynamic> response) => {
      'resultcode': '00',
      'message': 'success',
      'response': response,
    };

    test('parses a complete Naver response', () {
      final details = parseNaverProfile(
        body({
          'id': '32742776',
          'email': 'User@Naver.com',
          'name': '홍길동',
          'profile_image': 'https://ssl.pstatic.net/p.jpg',
        }),
      );

      expect(details.userIdentifier, '32742776');
      expect(details.email, 'user@naver.com'); // 소문자화
      expect(details.name, '홍길동');
      expect(details.image, Uri.parse('https://ssl.pstatic.net/p.jpg'));
    });

    test('lowercases the email', () {
      final details = parseNaverProfile(body({'id': '1', 'email': 'A@B.COM'}));
      expect(details.email, 'a@b.com');
    });

    test('allows null email / name / image (consent declined)', () {
      final details = parseNaverProfile(body({'id': '1'}));
      expect(details.userIdentifier, '1');
      expect(details.email, isNull);
      expect(details.name, isNull);
      expect(details.image, isNull);
    });

    test('throws when resultcode is not 00', () {
      expect(
        () => parseNaverProfile({
          'resultcode': '024',
          'message': 'Authentication failed',
        }),
        throwsA(isA<NaverAccessTokenVerificationException>()),
      );
    });

    test('throws when the response object is missing', () {
      expect(
        () => parseNaverProfile({'resultcode': '00'}),
        throwsA(isA<NaverUserInfoMissingDataException>()),
      );
    });

    test('throws when id is missing', () {
      expect(
        () => parseNaverProfile(body({'email': 'a@b.com'})),
        throwsA(isA<NaverUserInfoMissingDataException>()),
      );
    });

    test('throws when id is empty', () {
      expect(
        () => parseNaverProfile(body({'id': ''})),
        throwsA(isA<NaverUserInfoMissingDataException>()),
      );
    });
  });

  group('parseNaverTokenResponse', () {
    test('returns the access token', () {
      final response = parseNaverTokenResponse({
        'access_token': 'AAAA',
        'token_type': 'bearer',
      });
      expect(response.accessToken, 'AAAA');
    });

    test('throws OAuth2InvalidResponseException on error', () {
      expect(
        () => parseNaverTokenResponse({
          'error': 'invalid_request',
          'error_description': 'bad code',
        }),
        throwsA(isA<OAuth2InvalidResponseException>()),
      );
    });

    test('throws OAuth2MissingAccessTokenException when absent', () {
      expect(
        () => parseNaverTokenResponse({'token_type': 'bearer'}),
        throwsA(isA<OAuth2MissingAccessTokenException>()),
      );
    });
  });
}
