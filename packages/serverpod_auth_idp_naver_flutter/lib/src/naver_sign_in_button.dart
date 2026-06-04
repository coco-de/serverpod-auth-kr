import 'package:flutter/material.dart';

/// Naver 로그인용 스타일이 적용된 버튼.
///
/// Naver 브랜드 가이드라인에 따라 녹색(#03C75A) 배경과 흰색 텍스트로 렌더링되며,
/// 로딩/비활성화 상태를 지원합니다. 정본 GitHub 버튼(`github_sign_in_button.dart`)
/// 의 구조를 간소화하여 미러링한 스켈레톤입니다.
class NaverSignInButton extends StatelessWidget {
  /// 버튼이 눌렸을 때 호출되는 콜백.
  final VoidCallback? onPressed;

  /// 버튼이 현재 로딩 중인지 여부.
  final bool isLoading;

  /// 버튼이 비활성화 상태인지 여부.
  final bool isDisabled;

  /// 버튼에 표시할 텍스트.
  final String text;

  /// 최소 버튼 너비(픽셀 단위).
  final double minimumWidth;

  /// Naver 브랜드 녹색.
  static const Color naverGreen = Color(0xFF03C75A);

  /// [NaverSignInButton] 을 생성합니다.
  const NaverSignInButton({
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.text = 'Naver로 로그인',
    this.minimumWidth = 240,
    super.key,
  }) : assert(
         minimumWidth > 0 && minimumWidth <= 400,
         'Invalid minimumWidth. Must be between 0 and 400.',
       );

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumWidth,
        maxWidth: 400,
        minHeight: 48,
        maxHeight: 48,
      ),
      child: ElevatedButton(
        onPressed: isLoading || isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: naverGreen,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          elevation: 0,
          disabledBackgroundColor: naverGreen.withValues(alpha: 0.6),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
        ),
        child: _buildButtonContent(foregroundColor),
      ),
    );
  }

  Widget _buildButtonContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
