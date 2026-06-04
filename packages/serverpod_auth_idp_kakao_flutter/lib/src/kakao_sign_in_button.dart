import 'package:flutter/material.dart';

/// Kakao 로그인용 스타일이 적용된 버튼.
///
/// 카카오 디자인 가이드라인에 따라 노란색 배경(`#FEE500`)과 검정 텍스트를
/// 사용하는 Kakao 브랜드 버튼을 렌더링한다. 로딩/비활성 상태를 지원한다.
class KakaoSignInButton extends StatelessWidget {
  /// 카카오 브랜드 노란색 배경 색상.
  static const Color kakaoYellow = Color(0xFFFEE500);

  /// 버튼 텍스트와 라벨에 사용하는 검정 전경 색상.
  static const Color kakaoLabel = Color(0xFF000000);

  /// 버튼에 표시되는 기본 라벨.
  static const String defaultLabel = '카카오 로그인';

  /// 버튼이 눌렸을 때 호출되는 콜백.
  final VoidCallback? onPressed;

  /// 버튼이 현재 로딩 중인지 여부.
  final bool isLoading;

  /// 버튼이 비활성화되었는지 여부.
  final bool isDisabled;

  /// 버튼에 표시할 라벨 텍스트.
  final String label;

  /// 버튼의 최소 너비(픽셀).
  final double minimumWidth;

  /// 버튼의 높이(픽셀).
  final double height;

  /// Kakao 로그인 버튼을 생성한다.
  const KakaoSignInButton({
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.label = defaultLabel,
    this.minimumWidth = 240,
    this.height = 48,
    super.key,
  }) : assert(
         minimumWidth > 0 && minimumWidth <= 400,
         'Invalid minimumWidth. Must be between 0 and 400.',
       );

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumWidth,
        maxWidth: 400,
        minHeight: height,
        maxHeight: height,
      ),
      child: ElevatedButton(
        onPressed: isLoading || isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kakaoYellow,
          foregroundColor: kakaoLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: kakaoYellow.withValues(alpha: 0.6),
          disabledForegroundColor: kakaoLabel.withValues(alpha: 0.6),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(kakaoLabel),
        ),
      );
    }

    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: kakaoLabel,
      ),
    );
  }
}
