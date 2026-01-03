/// Payment 관련 데이터 상수 정의
/// 
/// 주문(purchase_item) 관련 상태 코드, 텍스트 매핑, 에러 메시지 등을 정의합니다.
/// UI 상수는 main_ui_config.dart를 참조하세요.
library;

// 서울 내 자치구 리스트 (payment_view.dart에서 사용)
const List<String> district = [
  '강남구',
  '강동구',
  '강북구',
  '강서구',
  '관악구',
  '광진구',
  '구로구',
  '금천구',
  '노원구',
  '도봉구',
  '동대문구',
  '동작구',
  '마포구',
  '서대문구',
  '서초구',
  '성동구',
  '성북구',
  '송파구',
  '양천구',
  '영등포구',
  '용산구',
  '은평구',
  '종로구',
  '중구',
  '중랑구',
];

// ============================================
// Purchase Item Status (b_status)
// ============================================

/// Purchase Item 상태 코드 상수
class PurchaseItemStatus {
  /// 제품 준비 중
  static const String preparing = '0';
  
  /// 픽업 대기 중
  static const String pickupWaiting = '1';
  
  /// 픽업 완료
  static const String pickupCompleted = '2';
  
  /// 취소됨
  static const String cancelled = '3';
  
  /// 초기 상태 (제품 준비 중)
  static const String initial = preparing;
  
  // Private constructor to prevent instantiation
  PurchaseItemStatus._();
}

/// Purchase Item 상태 코드 → 텍스트 매핑
const Map<String, String> purchaseItemStatusMap = {
  PurchaseItemStatus.preparing: '제품 준비 중',
  PurchaseItemStatus.pickupWaiting: '픽업 대기 중',
  PurchaseItemStatus.pickupCompleted: '픽업 완료',
  PurchaseItemStatus.cancelled: '취소됨',
};

/// Purchase Item 상태 코드를 텍스트로 변환
/// 
/// [status] 상태 코드 ('0', '1', '2', '3')
/// [defaultText] 상태 코드가 매핑에 없을 때 반환할 기본 텍스트
/// 
/// Returns: 상태 텍스트 (예: '제품 준비 중', '픽업 대기 중' 등)
String getPurchaseItemStatusText(String? status, {String? defaultText}) {
  if (status == null || status.isEmpty) {
    return defaultText ?? '알 수 없음';
  }
  return purchaseItemStatusMap[status] ?? defaultText ?? status;
}

// ============================================
// Error Messages
// ============================================

/// 주문 관련 에러 메시지
class PurchaseErrorMessage {
  /// 주문 저장 실패
  static const String saveFailed = '주문 저장 실패';
  
  /// 주문 처리 중 오류 발생
  static const String processError = '주문 처리 중 오류 발생';
  
  /// 주문 상세 정보를 불러올 수 없습니다.
  static const String loadDetailFailed = '주문 상세 정보를 불러올 수 없습니다.';
  
  /// 주문 정보를 찾을 수 없습니다.
  static const String orderNotFound = '주문 정보를 찾을 수 없습니다.';
  
  /// 주문 상세 조회 중 오류가 발생했습니다.
  static const String loadDetailError = '주문 상세 조회 중 오류가 발생했습니다.';
  
  /// 주문 내역을 불러올 수 없습니다.
  static const String loadListFailed = '주문 내역을 불러올 수 없습니다.';
  
  /// 주문 내역 조회 중 오류가 발생했습니다.
  static const String loadListError = '주문 내역 조회 중 오류가 발생했습니다.';
  
  /// 제품 정보를 불러올 수 없습니다.
  static const String loadProductFailed = '제품 정보를 불러올 수 없습니다.';
  
  /// 재고 확인 중 오류가 발생했습니다.
  static const String checkStockError = '재고 확인 중 오류가 발생했습니다.';
  
  /// 지점 목록을 불러올 수 없습니다.
  static const String loadBranchFailed = '지점 목록을 불러올 수 없습니다.';
  
  /// 결제 화면을 열 수 없습니다.
  static const String openPaymentFailed = '결제 화면을 열 수 없습니다.';
  
  /// 알 수 없는 오류
  static const String unknownError = '알 수 없는 오류';
  
  // Private constructor to prevent instantiation
  PurchaseErrorMessage._();
}

// ============================================
// Default Values / Placeholders
// ============================================

/// 기본값/플레이스홀더 상수
class PurchaseDefaultValue {
  /// 상품명 없음
  static const String productNameMissing = '상품명 없음';
  
  /// 지점명 없음
  static const String branchNameMissing = '지점명 없음';
  
  /// 알 수 없는 상품
  static const String unknownProduct = '알 수 없는 상품';
  
  /// 알 수 없음 (일반적인 경우)
  static const String unknown = '알 수 없음';
  
  // Private constructor to prevent instantiation
  PurchaseDefaultValue._();
}

// ============================================
// UI Text Labels
// ============================================

/// UI 텍스트 레이블 상수
class PurchaseLabel {
  /// 주문 상세
  static const String orderDetail = '주문 상세';
  
  /// 주문 내역
  static const String orderList = '주문 내역';
  
  /// 주문 정보
  static const String orderInfo = '주문 정보';
  
  /// 주문 항목
  static const String orderItems = '주문 항목';
  
  /// 주문 일시
  static const String orderDateTime = '주문 일시';
  
  /// 주문 내역이 없습니다.
  static const String noOrderHistory = '주문 내역이 없습니다.';
  
  // Private constructor to prevent instantiation
  PurchaseLabel._();
}

