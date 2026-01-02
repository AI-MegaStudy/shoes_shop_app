/// 장바구니 저장소 유틸리티
/// GetStorage를 사용하여 장바구니 데이터를 로컬에 저장합니다.
library;

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:shoes_shop_app/model/user.dart';

class CartStorage {
  static final GetStorage _storage = GetStorage();
  static const String _cartUsersKey = 'cart_users'; // 장바구니를 가진 유저 목록 저장
  
  /// 유저별 장바구니 키 생성
  /// 
  /// [userSeq] 유저의 uSeq
  /// 반환: 'cart_${userSeq}' 형식의 키
  static String _getCartKey(int userSeq) {
    return 'cart_$userSeq';
  }
  
  /// 장바구니를 가진 유저 목록 가져오기
  /// 
  /// 반환: 장바구니를 가진 유저의 uSeq 리스트
  static List<int> _getCartUserList() {
    try {
      final userListJson = _storage.read<String>(_cartUsersKey);
      if (userListJson == null || userListJson.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(userListJson);
      return decoded.map((e) => _asInt(e)).where((seq) => seq > 0).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// 장바구니를 가진 유저 목록에 유저 추가
  /// 
  /// [userSeq] 추가할 유저의 uSeq
  static void _addToCartUserList(int userSeq) {
    final userList = _getCartUserList();
    if (!userList.contains(userSeq)) {
      userList.add(userSeq);
      try {
        final userListJson = jsonEncode(userList);
        _storage.write(_cartUsersKey, userListJson);
      } catch (e) {
        print('장바구니 유저 목록 저장 실패: $e');
      }
    }
  }
  
  /// 장바구니를 가진 유저 목록에서 유저 제거
  /// 
  /// [userSeq] 제거할 유저의 uSeq
  static void _removeFromCartUserList(int userSeq) {
    final userList = _getCartUserList();
    userList.remove(userSeq);
    try {
      if (userList.isEmpty) {
        _storage.remove(_cartUsersKey);
      } else {
        final userListJson = jsonEncode(userList);
        _storage.write(_cartUsersKey, userListJson);
      }
    } catch (e) {
      print('장바구니 유저 목록 저장 실패: $e');
    }
  }

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

  /// 현재 로그인한 유저의 uSeq 가져오기
  /// 
  /// 반환: 유저의 uSeq (로그인하지 않았으면 null)
  static int? _getCurrentUserSeq() {
    try {
      final userJson = _storage.read<String>('user');
      if (userJson == null || userJson.isEmpty) {
        return null;
      }
      final user = User.fromJson(jsonDecode(userJson));
      return user.uSeq;
    } catch (e) {
      return null;
    }
  }

  /// 장바구니 가져오기
  /// 
  /// 현재 로그인한 유저의 장바구니를 가져옵니다.
  /// 각 유저별로 별도의 키(cart_${userSeq})로 저장되므로 유저별로 독립적인 장바구니가 유지됩니다.
  /// 
  /// 반환: 장바구니 항목 리스트 (로그인하지 않았거나 장바구니가 없으면 빈 리스트)
  /// 
  /// 사용 예시:
  /// ```dart
  /// final cart = CartStorage.getCart();
  /// if (cart.isNotEmpty) {
  ///   print('장바구니 항목 수: ${cart.length}');
  /// }
  /// ```
  static List<Map<String, dynamic>> getCart() {
    final currentUserSeq = _getCurrentUserSeq();
    if (currentUserSeq == null) {
      return [];
    }
    
    final cartKey = _getCartKey(currentUserSeq);
    final cartJson = _storage.read<String>(cartKey);
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
  /// 현재 로그인한 유저의 키(cart_${userSeq})로 저장합니다.
  /// 장바구니를 가진 유저 목록에도 추가합니다.
  /// 
  /// 사용 예시:
  /// ```dart
  /// final cart = CartStorage.getCart();
  /// cart.add(newItem);
  /// CartStorage.saveCart(cart);
  /// ```
  static void saveCart(List<Map<String, dynamic>> cart) {
    final currentUserSeq = _getCurrentUserSeq();
    if (currentUserSeq == null) {
      return;
    }
    
    try {
      final cartJson = jsonEncode(cart);
      final cartKey = _getCartKey(currentUserSeq);
      _storage.write(cartKey, cartJson);
      
      // 장바구니가 비어있지 않으면 유저 목록에 추가
      if (cart.isNotEmpty) {
        _addToCartUserList(currentUserSeq);
      } else {
        // 장바구니가 비어있으면 유저 목록에서 제거
        _removeFromCartUserList(currentUserSeq);
      }
    } catch (e) {
      print('장바구니 저장 실패: $e');
    }
  }

  /// 장바구니 비우기
  /// 
  /// 현재 로그인한 유저의 장바구니만 삭제합니다.
  /// 
  /// 사용 예시:
  /// ```dart
  /// // 현재 로그인한 유저의 장바구니 삭제
  /// CartStorage.clearCart();
  /// ```
  static void clearCart() {
    final currentUserSeq = _getCurrentUserSeq();
    if (currentUserSeq == null) {
      return;
    }
    
    final cartKey = _getCartKey(currentUserSeq);
    _storage.remove(cartKey);
    
    // 유저 목록에서도 제거
    _removeFromCartUserList(currentUserSeq);
  }

  /// 모든 유저의 장바구니 일괄 삭제 (개발용)
  /// 
  /// 장바구니를 가진 유저 목록을 기반으로 모든 장바구니를 삭제합니다.
  /// 개발 및 테스트 용도로만 사용하세요.
  /// 
  /// 사용 예시:
  /// ```dart
  /// // 모든 유저의 장바구니 삭제
  /// CartStorage.clearAllCarts();
  /// ```
  static void clearAllCarts() {
    try {
      final userList = _getCartUserList();
      
      // 각 유저의 장바구니 삭제
      for (final userSeq in userList) {
        final cartKey = _getCartKey(userSeq);
        _storage.remove(cartKey);
      }
      
      // 유저 목록도 삭제
      _storage.remove(_cartUsersKey);
    } catch (e) {
      print('모든 장바구니 삭제 실패: $e');
    }
  }
  
  /// 특정 유저 목록의 장바구니 삭제 (개발용)
  /// 
  /// [userSeqs] 삭제할 유저의 uSeq 리스트
  /// 개발 및 테스트 용도로만 사용하세요.
  /// 
  /// 사용 예시:
  /// ```dart
  /// // 특정 유저들의 장바구니 삭제
  /// CartStorage.clearCartsForUsers([1, 2, 3, 5, 10]);
  /// ```
  static void clearCartsForUsers(List<int> userSeqs) {
    try {
      for (final userSeq in userSeqs) {
        final cartKey = _getCartKey(userSeq);
        _storage.remove(cartKey);
        _removeFromCartUserList(userSeq);
      }
    } catch (e) {
      print('유저별 장바구니 삭제 실패: $e');
    }
  }

  /// 장바구니에서 특정 항목 제거
  /// 
  /// [index] 제거할 항목의 인덱스
  /// 
  /// 사용 예시:
  /// ```dart
  /// // 첫 번째 항목 제거
  /// CartStorage.removeItem(0);
  /// ```
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
  /// 
  /// 사용 예시:
  /// ```dart
  /// // 첫 번째 항목의 수량을 3으로 변경
  /// CartStorage.updateQuantity(0, 3);
  /// ```
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

// ============================================
// 변경 이력
// ============================================
// 2026-01-02:
//   - 유저별 장바구니 데이터 분리: 각 유저별로 독립적인 장바구니 저장 (키: cart_${userSeq})
//   - getCart(): 현재 로그인한 유저의 키로 장바구니 조회
//   - saveCart(): 현재 로그인한 유저의 키로 장바구니 저장 (장바구니 유저 목록에 추가)
//   - clearCart(): 현재 로그인한 유저의 장바구니만 삭제 (장바구니 유저 목록에서 제거)
//   - 각 유저가 로그아웃 후 다시 로그인해도 자신의 장바구니가 유지됨
//   - 장바구니 메타데이터 관리: 'cart_users' 키에 장바구니를 가진 유저 목록 저장
//   - clearAllCarts(): 개발용 일괄 삭제 메서드 (장바구니 유저 목록 기반)
//   - clearCartsForUsers(): 특정 유저 목록의 장바구니 삭제 메서드
//   - 주요 메서드 사용 예시(주석) 추가

