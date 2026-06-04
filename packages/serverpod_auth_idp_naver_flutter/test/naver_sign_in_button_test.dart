import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_naver_flutter/serverpod_auth_idp_naver_flutter.dart';

void main() {
  Widget host(final Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders the default label and triggers onPressed on tap', (
    final tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(NaverSignInButton(onPressed: () => taps += 1)),
    );

    expect(find.text('Naver로 로그인'), findsOneWidget);
    await tester.tap(find.byType(NaverSignInButton));
    expect(taps, 1);
  });

  testWidgets('shows a spinner and ignores taps while loading', (
    final tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(NaverSignInButton(onPressed: () => taps += 1, isLoading: true)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(NaverSignInButton));
    expect(taps, 0);
  });

  testWidgets('is disabled when isDisabled is true', (final tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(NaverSignInButton(onPressed: () => taps += 1, isDisabled: true)),
    );

    await tester.tap(find.byType(NaverSignInButton));
    expect(taps, 0);
  });
}
