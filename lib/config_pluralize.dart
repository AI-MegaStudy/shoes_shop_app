// 상수 정리용 Config 파일
// 생성자: 유다원
// 2026.01.01 생성

// ---------시스템-----------
import 'package:flutter/material.dart';

//const String ipAddress = "172.30.1.15"; //ip
const String ipAddress = "172.16.250.176"; //ip

Map productStatus = { // 제품 수령상태
  0 : '준비 중',
  1 : '준비 완료',
  2 : '수령 완료',
  3 : '반품 완료'
};

// ---------디자인-----------
const double edgeSpace = 20; // 세이프 에리어
const double imageWidth = 100; // 이미지 가로
const double imageWidthBig = 200; // 이미지 가로
const double cardSpace = 10; // 카드 여백

const Color orderColor = Colors.grey; // 준비 중 색상
const Color arriveColor = Colors.black; // 준비 완료, 수령 완료 색상
const Color refundColor = Color.fromARGB(255, 172, 33, 23); // 반품 완료 색상