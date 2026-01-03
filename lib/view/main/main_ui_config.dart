/// Main 폴더 전용 UI 설정 파일
/// 
/// main 폴더의 모든 페이지에서 사용하는 UI 상수들을 정의합니다.
/// 앱의 룩앤필을 통일하기 위한 공용 상수입니다.
/// 
/// 테마 색상 사용:
/// ```dart
/// import 'package:shoes_shop_app/theme/app_colors.dart';
/// 
/// final p = context.palette;
/// Text('가격', style: mainPriceStyle.copyWith(color: p.priceHighlight))
/// Container(color: p.productCardBackground)
/// ```
library;

import 'package:flutter/material.dart';

// ============================================
// AppBar 설정
// ============================================

/// AppBar 제목 텍스트 스타일
/// 
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle mainAppBarTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

/// AppBar 중앙 정렬 여부 (기본값: true)
const bool mainAppBarCenterTitle = true;

// ============================================
// Scaffold 배경색
// ============================================

/// Scaffold 배경색 (기본값: Colors.white)
/// 
/// 테마를 사용하는 경우 context.palette.background를 사용하세요.
const Color mainScaffoldBackgroundColor = Colors.white;

// ============================================
// 텍스트 스타일
// ============================================

/// 큰 제목 텍스트 스타일 (제품 상세 페이지 제품명 등)
const TextStyle mainLargeTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

/// 제목 텍스트 스타일 (섹션 제목 등)
const TextStyle mainTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

/// 중간 제목 텍스트 스타일
const TextStyle mainMediumTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

/// 본문 텍스트 스타일
const TextStyle mainBodyTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

/// 작은 텍스트 스타일 (부가 정보)
const TextStyle mainSmallTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
);

/// 중간 텍스트 스타일 (중요한 정보)
const TextStyle mainMediumTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);

/// 굵은 레이블 텍스트 스타일 (AppBar 제목 등)
/// 
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle mainBoldLabelStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

/// 제품명 텍스트 스타일 (제품 카드)
const TextStyle mainProductNameStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

/// 제품 부가 정보 텍스트 스타일 (제조사, 색상 등)
/// 
/// 색상은 copyWith(color: context.palette.textSecondary)로 테마에 맞게 설정해야 함
const TextStyle mainProductSubInfoStyle = TextStyle(
  fontSize: 12,
);

/// 가격 텍스트 스타일
/// 
/// 색상은 copyWith(color: context.palette.priceHighlight)로 테마에 맞게 설정해야 함
const TextStyle mainPriceStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

/// 가격 텍스트 스타일 (작은 버전, 제품 카드용)
/// 
/// 색상은 copyWith(color: context.palette.priceHighlight)로 테마에 맞게 설정해야 함
const TextStyle mainPriceSmallStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

// ============================================
// 버튼 스타일
// ============================================

/// 기본 버튼 높이
const double mainButtonHeight = 56.0;

/// 버튼 최대 너비 (적당한 크기로 제한)
const double mainButtonMaxWidth = 400.0;

/// 기본 버튼 패딩
const EdgeInsets mainButtonPadding = EdgeInsets.symmetric(vertical: 16);

/// 기본 ElevatedButton 스타일
ButtonStyle get mainElevatedButtonStyle => ElevatedButton.styleFrom(
  padding: mainButtonPadding,
);

/// Primary ElevatedButton 스타일
/// 
/// 색상은 copyWith()로 테마에 맞게 설정해야 함
/// 사용 예시:
/// ```dart
/// final p = context.palette;
/// ElevatedButton(
///   style: mainPrimaryButtonStyle.copyWith(
///     backgroundColor: MaterialStateProperty.all(p.paymentButton),
///     foregroundColor: MaterialStateProperty.all(p.paymentButtonText),
///   ),
/// )
/// ```
ButtonStyle get mainPrimaryButtonStyle => ElevatedButton.styleFrom(
  padding: mainButtonPadding,
);


// ============================================
// 카드 스타일
// ============================================

/// 제품 카드 elevation
const double mainProductCardElevation = 2.0;

/// 제품 카드 borderRadius
const double mainProductCardBorderRadius = 12.0;

/// 일반 카드 elevation
const double mainCardElevation = 6.0;

// ============================================
// 간격 및 패딩
// ============================================

/// 기본 간격
const double mainDefaultSpacing = 16.0;

/// 작은 간격
const double mainSmallSpacing = 8.0;

/// 큰 간격
const double mainLargeSpacing = 24.0;

/// 기본 패딩
const EdgeInsets mainDefaultPadding = EdgeInsets.all(16.0);

/// 작은 패딩
const EdgeInsets mainSmallPadding = EdgeInsets.all(8.0);

/// 중간 패딩 (카드 내부 등)
const EdgeInsets mainMediumPadding = EdgeInsets.all(12.0);

/// 매우 작은 패딩 (드롭다운 메뉴 항목 등)
const EdgeInsets mainTinyPadding = EdgeInsets.symmetric(vertical: 2);

/// 기본 SizedBox 높이 (요소 간 수직 간격)
const SizedBox mainDefaultVerticalSpacing = SizedBox(height: 16);

/// 작은 SizedBox 높이 (작은 요소 간 수직 간격)
const SizedBox mainSmallVerticalSpacing = SizedBox(height: 8);

/// 매우 작은 SizedBox 높이 (드롭다운 메뉴 내부 등)
const SizedBox mainTinyVerticalSpacing = SizedBox(height: 2);

// ============================================
// 색상 (Deprecated - 팔레트 사용 권장)
// ============================================
// 
// ⚠️ 하드코딩된 색상은 더 이상 사용하지 마세요.
// 대신 context.palette를 사용하세요:
// 
// - mainBackgroundGrey → context.palette.background
// - mainLightGrey → context.palette.divider
// - mainMediumGrey → context.palette.textSecondary
// - mainDarkGrey → context.palette.textSecondary
// - mainPrimaryColor → context.palette.primary
// - mainPrimaryDarkColor → context.palette.primary
// 
// 신발 쇼핑 앱 전용 색상:
// - context.palette.priceHighlight (가격 강조)
// - context.palette.productCardBackground (제품 카드 배경)
// - context.palette.paymentButton (결제 버튼)
// 등등...

/// 배경 회색 (이미지 플레이스홀더 등)
/// @deprecated context.palette.background를 사용하세요
@Deprecated('Use context.palette.background instead')
const Color mainBackgroundGrey = Color(0xFFF5F5F5);

/// 연한 회색 (카드 배경 등)
/// @deprecated context.palette.divider를 사용하세요
@Deprecated('Use context.palette.divider instead')
const Color mainLightGrey = Color(0xFFE0E0E0);

/// 중간 회색 (텍스트 등)
/// @deprecated context.palette.textSecondary를 사용하세요
@Deprecated('Use context.palette.textSecondary instead')
const Color mainMediumGrey = Color(0xFF757575);

/// 어두운 회색 (텍스트 등)
/// @deprecated context.palette.textSecondary를 사용하세요
@Deprecated('Use context.palette.textSecondary instead')
const Color mainDarkGrey = Color(0xFF424242);

/// Primary 색상 (파란색)
/// @deprecated context.palette.primary를 사용하세요
@Deprecated('Use context.palette.primary instead')
const Color mainPrimaryColor = Colors.blue;

/// Primary 색상 (진한 파란색)
/// @deprecated context.palette.primary를 사용하세요
@Deprecated('Use context.palette.primary instead')
const Color mainPrimaryDarkColor = Color(0xFF1976D2);

// ============================================
// BorderRadius
// ============================================

/// 기본 BorderRadius
const BorderRadius mainDefaultBorderRadius = BorderRadius.all(Radius.circular(12));

/// 작은 BorderRadius
const BorderRadius mainSmallBorderRadius = BorderRadius.all(Radius.circular(8));

/// 중간 BorderRadius (큰 카드 등)
const BorderRadius mainMediumBorderRadius = BorderRadius.all(Radius.circular(16));

/// BottomSheet 상단 BorderRadius
const BorderRadius mainBottomSheetTopBorderRadius = BorderRadius.vertical(top: Radius.circular(20));

// ============================================
// 기타 UI 상수
// ============================================

/// 3D 뷰어 높이
const double main3DViewerHeight = 300.0;

/// 제품 이미지 높이 (카드 내부)
const double mainProductImageHeight = 90.0;

/// 제품 이미지 너비 (카드 내부)
const double mainProductImageWidth = 90.0;

/// 검색바 borderRadius
const double mainSearchBarBorderRadius = 10.0;

/// 필터 칩 배경색
/// @deprecated context.palette.filterInactive를 사용하세요
@Deprecated('Use context.palette.filterInactive instead')
const Color mainFilterChipBackgroundColor = Color(0xFFE0E0E0);

