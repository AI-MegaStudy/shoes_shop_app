/// User Auth 폴더 전용 UI 설정 파일
/// 
/// user/auth 폴더의 모든 페이지에서 사용하는 UI 상수들을 정의합니다.
/// 로그인, 회원가입, 프로필 수정 화면의 룩앤필을 통일하기 위한 공용 상수입니다.
/// 
/// 테마 색상 사용:
/// ```dart
/// import 'package:shoes_shop_app/theme/app_colors.dart';
/// 
/// final p = context.palette;
/// Container(color: p.cardBackground)
/// ```
library;

import 'package:flutter/material.dart';

// ============================================
// AppBar 설정
// ============================================

/// AppBar 제목 텍스트 스타일
/// 
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle userAuthAppBarTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

/// AppBar 중앙 정렬 여부 (기본값: true)
const bool userAuthAppBarCenterTitle = true;

// ============================================
// 텍스트 스타일
// ============================================

/// 큰 제목 텍스트 스타일 (로고 텍스트 등)
const TextStyle userAuthLargeTitleStyle = TextStyle(
  fontSize: 48,
  fontWeight: FontWeight.bold,
);

/// 제목 텍스트 스타일 (섹션 제목, 약관 전체 동의 등)
const TextStyle userAuthTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

/// 버튼 텍스트 스타일
const TextStyle userAuthButtonTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

/// 본문 텍스트 스타일
const TextStyle userAuthBodyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

/// 작은 텍스트 스타일 (약관 보기 버튼 등)
const TextStyle userAuthSmallTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

// ============================================
// 버튼 스타일
// ============================================

/// 기본 버튼 높이
const double userAuthButtonHeight = 56.0;

/// 버튼 최대 너비 (적당한 크기로 제한)
const double userAuthButtonMaxWidth = 400.0;

/// 구글 로그인 버튼 아이콘 크기
const double userAuthGoogleIconSize = 20.0;

// ============================================
// 간격 및 패딩
// ============================================

/// 기본 간격
const double userAuthDefaultSpacing = 16.0;

/// 작은 간격
const double userAuthSmallSpacing = 8.0;

/// 중간 간격
const double userAuthMediumSpacing = 10.0;

/// 큰 간격
const double userAuthLargeSpacing = 24.0;

/// 기본 패딩 (화면 전체)
const EdgeInsets userAuthDefaultPadding = EdgeInsets.all(16.0);

/// 폼 가로 패딩
const EdgeInsets userAuthFormHorizontalPadding = EdgeInsets.symmetric(horizontal: 16);

/// 약관 카드 내부 패딩
const EdgeInsets userAuthTermsCardPadding = EdgeInsets.all(10);

/// 약관 항목 간격
const SizedBox userAuthTermsItemSpacing = SizedBox(height: 6);

/// 약관 체크박스 간격
const SizedBox userAuthTermsCheckboxSpacing = SizedBox(width: 4);

/// 약관 텍스트 간격
const SizedBox userAuthTermsTextSpacing = SizedBox(width: 2);

/// 입력 필드 간격
const SizedBox userAuthInputFieldSpacing = SizedBox(height: 10);

/// 버튼 간격
const SizedBox userAuthButtonSpacing = SizedBox(height: 16);

// ============================================
// BorderRadius
// ============================================

/// 기본 BorderRadius
const BorderRadius userAuthDefaultBorderRadius = BorderRadius.all(Radius.circular(8));

/// 작은 BorderRadius (약관 에러 표시 등)
const BorderRadius userAuthSmallBorderRadius = BorderRadius.all(Radius.circular(4));

/// 다이얼로그 BorderRadius
const BorderRadius userAuthDialogBorderRadius = BorderRadius.all(Radius.circular(12));

// ============================================
// 색상 (Deprecated - 팔레트 사용 권장)
// ============================================
// 
// ⚠️ 하드코딩된 색상은 더 이상 사용하지 마세요.
// 대신 context.palette를 사용하세요:
// 
// - userAuthLogoBackgroundColor → context.palette.divider
// - userAuthGoogleButtonBackgroundColor → context.palette.cardBackground
// - userAuthGoogleButtonTextColor → context.palette.textPrimary
// - userAuthDefaultProfileImageBackgroundColor → context.palette.divider
// - userAuthDefaultProfileImageIconColor → context.palette.textSecondary

/// 로고 영역 배경색
/// @deprecated context.palette.divider를 사용하세요
@Deprecated('Use context.palette.divider instead')
const Color userAuthLogoBackgroundColor = Color(0xFFE0E0E0);

/// 구글 로그인 버튼 배경색
/// @deprecated context.palette.cardBackground를 사용하세요
@Deprecated('Use context.palette.cardBackground instead')
const Color userAuthGoogleButtonBackgroundColor = Colors.white;

/// 구글 로그인 버튼 텍스트 색상
/// @deprecated context.palette.textPrimary를 사용하세요
@Deprecated('Use context.palette.textPrimary instead')
const Color userAuthGoogleButtonTextColor = Color(0xFF424242);

/// 기본 프로필 이미지 배경색
/// @deprecated context.palette.divider를 사용하세요
@Deprecated('Use context.palette.divider instead')
const Color userAuthDefaultProfileImageBackgroundColor = Color(0xFFE0E0E0);

/// 기본 프로필 이미지 아이콘 색상
/// @deprecated context.palette.textSecondary를 사용하세요
@Deprecated('Use context.palette.textSecondary instead')
const Color userAuthDefaultProfileImageIconColor = Colors.grey;

// ============================================
// 기타 UI 상수
// ============================================

/// 로고 영역 높이
const double userAuthLogoHeight = 200.0;

/// 프로필 이미지 크기
const double userAuthProfileImageSize = 120.0;

/// 프로필 이미지 카메라 아이콘 크기
const double userAuthProfileCameraIconSize = 36.0;

/// 프로필 이미지 카메라 아이콘 내부 아이콘 크기
const double userAuthProfileCameraInnerIconSize = 20.0;

/// 프로필 이미지 기본 아이콘 크기
const double userAuthProfileDefaultIconSize = 60.0;

/// 약관 보기 버튼 너비
const double userAuthTermsViewButtonWidth = 50.0;

/// 약관 에러 테두리 두께
const double userAuthTermsErrorBorderWidth = 2.0;

/// 회원가입 버튼 높이
const double userAuthSignUpButtonHeight = 50.0;

