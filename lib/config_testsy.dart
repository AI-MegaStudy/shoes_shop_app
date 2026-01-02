import 'package:flutter/material.dart';


/// 큰 제목 텍스트 스타일 (프로필 화면 제목 등)
const TextStyle largeTitleStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

/// 제목 텍스트 스타일 (섹션 제목 등)
const TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

/// 기본 텍스트 스타일 (본문)
const TextStyle bodyTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

/// 중간 텍스트 스타일 (중요한 정보)
const TextStyle mediumTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

/// 작은 텍스트 스타일 (부가 정보)
const TextStyle smallTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

//  UI Text Styles - AppBar & Form Labels
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle boldLabelStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);


// Pickup 상태
Map pickupStatus = {
  0 : '제품 준비 중',
  1 : '제품 준비 완료',
  2 : '제품 수령 완료',
  3 : '반품 완료'
};