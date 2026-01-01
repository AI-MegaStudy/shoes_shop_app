/// 장바구니 저장소 유틸리티
/// GetStorage를 사용하여 장바구니 데이터를 로컬에 저장합니다.

import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class CartStorage {
  static const String _cartKey = 'cart';
  static final GetStorage _storage = GetStorage();

  /// 장바구니에 상품 추가
  /// 
  /// [item] 추가할 상품 정보 (Map<String, dynamic>)
  /// - p_seq: 상품 ID (필수)
  /// - p_name: 상품명
  /// - p_price: 가격
  /// - cc_seq: 색상 카테고리 ID
  /// - cc_name: 색상명
  /// - sc_seq: 사이즈 카테고리 ID
  /// - sc_name: 사이즈명
  /// - quantity: 수량 (기본값: 1)
  /// - p_image: 이미지 경로
  static void addToCart(Map<String, dynamic> item) {
    final cart = getCart();
    
    // 동일한 상품(p_seq, cc_seq, sc_seq)이 이미 있는지 확인
    final existingIndex = cart.indexWhere((e) =>
        _asInt(e['p_seq']) == _asInt(item['p_seq']) &&
        _asInt(e['cc_seq']) == _asInt(item['cc_seq']) &&
        _asInt(e['sc_seq']) == _asInt(item['sc_seq']));
    
    if (existingIndex >= 0) {
      // 기존 항목의 수량 증가
      final currentQty = _asInt(cart[existingIndex]['quantity'], 1);
      cart[existingIndex]['quantity'] = currentQty + _asInt(item['quantity'], 1);
    } else {
      // 새 항목 추가
      cart.add(Map<String, dynamic>.from(item));
    }
    
    saveCart(cart);
  }

  /// 장바구니 가져오기
  /// 
  /// 반환: 장바구니 항목 리스트
  static List<Map<String, dynamic>> getCart() {
    final cartJson = _storage.read<String>(_cartKey);
    if (cartJson == null || cartJson.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(cartJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 장바구니 저장
  /// 
  /// [cart] 저장할 장바구니 리스트
  static void saveCart(List<Map<String, dynamic>> cart) {
    try {
      final cartJson = jsonEncode(cart);
      _storage.write(_cartKey, cartJson);
    } catch (e) {
      print('장바구니 저장 실패: $e');
    }
  }

  /// 장바구니 비우기
  static void clearCart() {
    _storage.remove(_cartKey);
  }

  /// 장바구니에서 특정 항목 제거
  /// 
  /// [index] 제거할 항목의 인덱스
  static void removeItem(int index) {
    final cart = getCart();
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      saveCart(cart);
    }
  }

  /// 장바구니 항목 수량 업데이트
  /// 
  /// [index] 업데이트할 항목의 인덱스
  /// [quantity] 새로운 수량
  static void updateQuantity(int index, int quantity) {
    final cart = getCart();
    if (index >= 0 && index < cart.length && quantity > 0) {
      cart[index]['quantity'] = quantity;
      saveCart(cart);
    }
  }

  /// 장바구니가 비어있는지 확인
  static bool isEmpty() {
    return getCart().isEmpty;
  }

  /// 장바구니 항목 개수
  static int getItemCount() {
    return getCart().length;
  }

  /// 동적 값을 int로 변환
  static int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }
}

