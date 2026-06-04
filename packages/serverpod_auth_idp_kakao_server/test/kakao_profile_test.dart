import 'package:serverpod_auth_idp_kakao_server/src/business/kakao_profile.dart';
import 'package:serverpod_auth_idp_kakao_server/src/exceptions/kakao_exceptions.dart';
import 'package:serverpod_auth_idp_server/core.dart'
    show OAuth2InvalidResponseException, OAuth2MissingAccessTokenException;
import 'package:test/test.dart';

void main() {
  group('parseKakaoProfile', () {
    test('parses a complete Kakao response with nested fields', () {
      final details = parseKakaoProfile({
        'id': 1234567890,
        'kakao_account': {
          'email': 'User@Kakao.com',
          'profile': {
            'nickname': '카카오유저',
            'profile_image_url': 'https://k.kakaocdn.net/p.jpg',
          },
        },
      });

      expect(details.userIdentifier, '1234567890'); // int → String
      expect(details.email, 'user@kakao.com'); // 소문자화
      expect(details.name, '카카오유저');
      expect(details.image, Uri.parse('https://k.kakaocdn.net/p.jpg'));
    });

    test('stringifies a numeric id', () {
      final details = parseKakaoProfile({'id': 42});
      expect(details.userIdentifier, '42');
    });

    test('allows missing kakao_account (email/name/image null)', () {
      final details = parseKakaoProfile({'id': 7});
      expect(details.userIdentifier, '7');
      expect(details.email, isNull);
      expect(details.name, isNull);
      expect(details.image, isNull);
    });

    test('allows missing profile within kakao_account', () {
      final details = parseKakaoProfile({
        'id': 7,
        'kakao_account': {'email': 'a@b.com'},
      });
      expect(details.email, 'a@b.com');
      expect(details.name, isNull);
      expect(details.image, isNull);
    });

    test('lowercases the email', () {
      final details = parseKakaoProfile({
        'id': 1,
        'kakao_account': {'email': 'MiXeD@Case.COM'},
      });
      expect(details.email, 'mixed@case.com');
    });

    test('throws when id is missing', () {
      expect(
        () => parseKakaoProfile({
          'kakao_account': {'email': 'a@b.com'},
        }),
        throwsA(isA<KakaoUserInfoMissingDataException>()),
      );
    });
  });

  group('parseKakaoTokenResponse', () {
    test('returns the access token', () {
      final response = parseKakaoTokenResponse({
        'access_token': 'BBBB',
        'token_type': 'bearer',
      });
      expect(response.accessToken, 'BBBB');
    });

    test('throws OAuth2InvalidResponseException on error', () {
      expect(
        () => parseKakaoTokenResponse({
          'error': 'invalid_grant',
          'error_description': 'expired code',
        }),
        throwsA(isA<OAuth2InvalidResponseException>()),
      );
    });

    test('throws OAuth2MissingAccessTokenException when absent', () {
      expect(
        () => parseKakaoTokenResponse({'token_type': 'bearer'}),
        throwsA(isA<OAuth2MissingAccessTokenException>()),
      );
    });
  });
}
