import 'package:flutter/material.dart';

/// 신발 쇼핑 앱 전용 컬러 스키마
///
/// 이 앱에서만 사용하는 특수 컬러들을 정의합니다.
/// - 제품 관련 색상 (카드, 가격, 할인 등)
/// - 장바구니/결제 관련 색상
/// - 재고/상태 관련 색상
/// - 브랜드/카테고리 관련 색상
class ShoesShopColorScheme {
  /// 제품 카드 배경색
  final Color productCardBackground;

  /// 제품 카드 테두리 색상
  final Color productCardBorder;

  /// 가격 강조 색상 (메인 가격 표시)
  final Color priceHighlight;

  /// 할인/세일 가격 색상
  final Color salePrice;

  /// 원가 (취소선) 색상
  final Color originalPrice;

  /// 장바구니 아이콘 색상
  final Color cartIcon;

  /// 결제 버튼 배경색
  final Color paymentButton;

  /// 결제 버튼 텍스트 색상
  final Color paymentButtonText;

  /// 재고 있음 색상
  final Color stockAvailable;

  /// 재고 부족 경고 색상
  final Color stockLow;

  /// 재고 없음 색상
  final Color stockOut;

  /// 브랜드 강조 색상
  final Color brandHighlight;

  /// 필터 활성화 색상
  final Color filterActive;

  /// 필터 비활성화 색상
  final Color filterInactive;

  /// 배송/픽업 배지 색상
  final Color deliveryBadge;

  /// 신상품 배지 색상
  final Color newProductBadge;

  /// 베스트셀러 배지 색상
  final Color bestsellerBadge;

  const ShoesShopColorScheme({
    required this.productCardBackground,
    required this.productCardBorder,
    required this.priceHighlight,
    required this.salePrice,
    required this.originalPrice,
    required this.cartIcon,
    required this.paymentButton,
    required this.paymentButtonText,
    required this.stockAvailable,
    required this.stockLow,
    required this.stockOut,
    required this.brandHighlight,
    required this.filterActive,
    required this.filterInactive,
    required this.deliveryBadge,
    required this.newProductBadge,
    required this.bestsellerBadge,
  });
}

