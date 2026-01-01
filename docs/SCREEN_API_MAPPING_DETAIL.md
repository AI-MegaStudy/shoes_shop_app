# 화면별 개발 가이드 - 상세 버전

**작성일**: 2025-01-XX  
**작성자**: 김택권  
**목적**: 화면 개발 시 필요한 DB 테이블, API 엔드포인트 상세 정보

---

## 📋 작업 분담 (최종)

| 담당자 | 담당 화면 수 | 주요 기능 | 복잡도 |
|--------|------------|----------|--------|
| 정진석| 4개 | 사용자/관리자 로그인 및 개인정보 수정, 드로어 메뉴 | 낮음 |
| 이광태| 5개 | 상품 조회 및 상세 화면, 장바구니, Firebase 채팅 | 중간 |
| 이예은 | 3개 | 주문, 결제 프로세스 | 높음 |
| 유다원 | 4개 | 사용자 주문, 수령/반품 조회 | 높음 |
| 임소연 | 4개 | 관리자 주문, 수령/반품 관리 | 높음 |
| 김택권 | 3개 | 소셜 로그인, 사용자 로그인/회원가입/개인정보 수정, PM 및 3D 프리뷰 | 높음 |

**총 화면 수:** 20개 (기본 화면)  
**추가 작업 화면:** 2개 (Firebase 공지 2개)  
**평균 화면 수:** 3.4개/인

**참고**: 
- 주문/반품 조회는 사용자용과 관리자용이 거의 동일한 데이터 사용
- 유다원(사용자 주문/반품 조회)과 임소연(관리자 주문/반품 관리)은 협업하여 공통 API를 먼저 개발하고 필터링 조건만 추가하는 것을 권장
- 장바구니는 DB 테이블 없이 임시 저장(메모리/로컬스토리지)으로만 사용하지만, 상품 정보 조회 및 재고 확인을 위해 `product` 테이블 참조 필요

---

## 관리자 화면

### 1. 관리자-로그인

| 항목 | 내용 |
|------|------|
| **화면 설명** | 관리자(직원) 로그인 화면 |
| **주요 기능** | ID/PW로 로그인 인증 |
| **담당자** | 정진석 |
| **필요 DB 테이블** | `staff` |
| **API 엔드포인트** | `POST /api/staffs/login` |
| **참고** | 사용자 로그인과 비슷한 로직 (ID/PW 확인만), 관리자 화면은 태블릿용이지만 로직은 동일

---

### 2. 관리자-드로어 메뉴

| 항목 | 내용 |
|------|------|
| **화면 설명** | 관리자 메뉴 네비게이션 |
| **주요 기능** | 현재 로그인한 직원 정보 표시 |
| **담당자** | 정진석 |
| **필요 DB 테이블** | `staff` |
| **API 엔드포인트** | `GET /api/staffs/{staff_seq}`<br>`GET /api/staffs/{staff_seq}/profile_image` |
| **참고** | 사용자 메뉴 드로어와 비슷한 로직, 관리자 화면은 태블릿용이지만 로직은 동일

---

### 3. 관리자-개인정보 수정

| 항목 | 내용 |
|------|------|
| **화면 설명** | 관리자 개인정보 수정 화면 |
| **주요 기능** | 직원 정보 조회/수정, 프로필 이미지 관리 |
| **담당자** | 정진석 |
| **필요 DB 테이블** | `staff`, `branch` |
| **API 엔드포인트** | `GET /api/staffs/{staff_seq}`<br>`GET /api/staffs/{staff_seq}/profile_image`<br>`POST /api/staffs/{staff_seq}`<br>`POST /api/staffs/{staff_seq}/with_image`<br>`DELETE /api/staffs/{staff_seq}/profile_image`<br>`GET /api/branches` |
| **참고** | 사용자 개인정보 수정과 비슷한 로직 (단순 CRUD)

---

### 4. 관리자-주문목록 조회

| 항목 | 내용 |
|------|------|
| **화면 설명** | 전체 주문 목록 조회 화면 |
| **주요 기능** | 주문 목록 조회, 날짜+시간(분 단위)별 그룹화, 필터링/검색 |
| **담당자** | 임소연 |
| **필요 DB 테이블** | `purchase_item`, `user`, `product`, `branch` |
| **API 엔드포인트** | `GET /api/purchase_items`<br>`GET /api/purchase_items/by_user/{user_seq}/orders` (날짜+시간(분 단위) 그룹화된 주문 목록)<br>`GET /api/purchase_items/by_user/{user_seq}/with_details` |

---

### 5. 관리자-주문목록 조회(상세화면)

| 항목 | 내용 |
|------|------|
| **화면 설명** | 특정 주문의 상세 정보 화면 (관리자가 수령 처리) |
| **주요 기능** | 주문 상세 정보 조회, 수령 완료 처리 |
| **담당자** | 임소연 |
| **필요 DB 테이블** | `purchase_item`, `user`, `product`, `branch`, `pickup`, `kind_category`, `color_category`, `size_category`, `gender_category`, `maker` |
| **API 엔드포인트** | `GET /api/purchase_items/{purchase_item_seq}/full_detail` (단일 구매 항목 상세)<br>`GET /api/purchase_items/by_datetime/with_details` (날짜+시간(분 단위) 그룹화된 주문 상세, 파라미터: user_seq, order_datetime, branch_seq)<br>`GET /api/pickups/by_bseq/{purchase_item_seq}`<br>`POST /api/pickups/{pickup_seq}/complete` |

---

### 6. 관리자-반품목록 조회

| 항목 | 내용 |
|------|------|
| **화면 설명** | 전체 반품 목록 조회 화면 |
| **주요 기능** | 반품 목록 조회, 필터링/검색 |
| **담당자** | 임소연 |
| **필요 DB 테이블** | `refund`, `user`, `staff`, `pickup`, `purchase_item`, `product` |
| **API 엔드포인트** | `GET /api/refunds`<br>`GET /api/refunds/by_staff/{staff_seq}/with_details` |

---

### 7. 관리자-반품목록 조회(상세화면)

| 항목 | 내용 |
|------|------|
| **화면 설명** | 특정 반품의 상세 정보 화면 (관리자가 반품 처리) |
| **주요 기능** | 반품 상세 정보 조회, 반품 승인/거부 처리 |
| **담당자** | 임소연 |
| **필요 DB 테이블** | `refund`, `user`, `staff`, `pickup`, `purchase_item`, `product`, `branch`, `kind_category`, `color_category`, `size_category`, `gender_category`, `maker` |
| **API 엔드포인트** | `GET /api/refunds/{refund_seq}/full_detail`<br>`POST /api/refunds/{refund_seq}/process` |

---

## 사용자 화면

### 8. 사용자 로그인

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객 로그인 화면 (로컬/소셜) |
| **주요 기능** | 로컬 로그인 또는 소셜 로그인 인증 |
| **담당자** | 김택권 |
| **필요 DB 테이블** | `user`, `user_auth_identities` |
| **API 엔드포인트** | `POST /api/auth/local/login`<br>`POST /api/auth/social/login` |
| **참고** | 소셜 로그인(구글, 카카오) 지원

---

### 9. 사용자 메뉴 드로어

| 항목 | 내용 |
|------|------|
| **화면 설명** | 사용자 메뉴 네비게이션 |
| **주요 기능** | 현재 로그인한 고객 정보 표시 |
| **담당자** | 정진석 |
| **필요 DB 테이블** | `user` |
| **API 엔드포인트** | `GET /api/users/{user_seq}`<br>`GET /api/users/{user_seq}/profile_image` |

---

### 10. 사용자-회원가입

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객 회원가입 화면 (로컬/소셜) |
| **주요 기능** | 고객 정보 등록, 프로필 이미지 업로드 |
| **담당자** | 김택권 |
| **필요 DB 테이블** | `user`, `user_auth_identities` |
| **API 엔드포인트** | `POST /api/users`<br>`POST /api/auth/local/signup`<br>`POST /api/auth/social/login` (소셜 로그인 시) |

---

### 11. 사용자-개인정보 수정

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객 개인정보 수정 화면 |
| **주요 기능** | 고객 정보 조회/수정, 프로필 이미지 관리 |
| **담당자** | 김택권 |
| **필요 DB 테이블** | `user` |
| **API 엔드포인트** | `GET /api/users/{user_seq}`<br>`GET /api/users/{user_seq}/profile_image`<br>`POST /api/users/{user_seq}`<br>`POST /api/users/{user_seq}/with_image`<br>`DELETE /api/users/{user_seq}/profile_image` |

---

### 12. 사용자-상품조회

| 항목 | 내용 |
|------|------|
| **화면 설명** | 상품 목록 조회 화면 (필터링 가능) |
| **주요 기능** | 상품 목록 조회, 카테고리별 필터링, 제조사별 조회 |
| **담당자** | 이광태 |
| **필요 DB 테이블** | `product`, `kind_category`, `color_category`, `size_category`, `gender_category`, `maker` |
| **API 엔드포인트** | `GET /api/products/with_categories`<br>`GET /api/products/by_category`<br>`GET /api/products/by_maker/{maker_seq}/with_categories`<br>`GET /api/makers`<br>`GET /api/kind_categories`<br>`GET /api/color_categories`<br>`GET /api/size_categories`<br>`GET /api/gender_categories` |
| **참고** | 상품 조회와 상세 화면은 연관성이 높아 한 명이 담당

---

### 13. 상품상세화면

| 항목 | 내용 |
|------|------|
| **화면 설명** | 특정 상품의 상세 정보 화면 (3D 프리뷰 포함) |
| **주요 기능** | 상품 상세 정보 조회 (모든 카테고리 + 제조사 정보 포함), 3D 프리뷰 |
| **담당자** | 이광태 (3D 프리뷰: 김택권) |
| **필요 DB 테이블** | `product`, `kind_category`, `color_category`, `size_category`, `gender_category`, `maker` |
| **API 엔드포인트** | `GET /api/products/{p_seq}/full_detail`<br>`GET /api/products/{p_seq}/file_info`<br>`GET /api/products/{p_seq}/file` |
| **참고** | 3D 프리뷰 기능은 김택권이 개발 (상품 상세 화면에 통합)

---

### 14. 사용자-장바구니

| 항목 | 내용 |
|------|------|
| **화면 설명** | 장바구니 화면 |
| **주요 기능** | 장바구니 조회, 상품 추가/수정/삭제, 재고 확인 |
| **담당자** | 이광태 |
| **필요 DB 테이블** | `product` (장바구니는 DB 테이블 없이 임시 저장만 사용) |
| **API 엔드포인트** | 장바구니는 클라이언트에서 임시 저장 (메모리/로컬스토리지)<br>`GET /api/products/{p_seq}` - 상품 정보 조회<br>`GET /api/products/{p_seq}/stock` - 재고 확인 (장바구니 추가 시 필수)<br>`GET /api/products/check_stocks` - 여러 상품 재고 일괄 확인 (결제 전 확인)<br>결제 시 `POST /api/purchase_items`로 주문 생성 |
| **참고** | 장바구니는 DB 테이블 없이 임시 저장만 사용하지만, 상품 정보 조회 및 재고 확인을 위해 `product` 테이블 참조 필요

---

### 15. 사용자-주소:결제방법

| 항목 | 내용 |
|------|------|
| **화면 설명** | 주소 및 결제 방법 선택 화면 |
| **주요 기능** | 지점 선택 (픽업 지점), 고객 정보 확인 |
| **담당자** | 이예은 |
| **필요 DB 테이블** | `branch`, `user` |
| **API 엔드포인트** | `GET /api/branches`<br>`GET /api/users/{user_seq}` |

---

### 16. 사용자-결제팝업

| 항목 | 내용 |
|------|------|
| **화면 설명** | 결제 팝업 화면 |
| **주요 기능** | 결제 금액 확인, 지점 정보 확인, 재고 확인 |
| **담당자** | 이예은 |
| **필요 DB 테이블** | `product`, `branch` |
| **API 엔드포인트** | `GET /api/products/{p_seq}` - 상품 정보 조회<br>`GET /api/products/{p_seq}/stock` - 재고 확인<br>`GET /api/products/check_stocks` - 여러 상품 재고 일괄 확인<br>`GET /api/branches/{br_seq}` |
| **참고** | 결제 전 재고 확인 필수

---

### 17. 사용자-결제하기

| 항목 | 내용 |
|------|------|
| **화면 설명** | 결제 처리 화면 |
| **주요 기능** | 주문 생성, 수령 정보 생성, 재고 차감 |
| **담당자** | 이예은 |
| **필요 DB 테이블** | `purchase_item`, `pickup`, `product` |
| **API 엔드포인트** | `GET /api/products/check_stocks` - 결제 전 재고 확인<br>`POST /api/purchase_items` - 주문 생성<br>`POST /api/pickups` - 수령 정보 생성<br>`PUT /api/products/{p_seq}/stock` - 재고 차감 (주문 생성 시 트랜잭션으로 처리) |
| **참고** | 재고 확인 후 주문 생성, 재고 차감은 트랜잭션으로 처리하여 동시성 문제 방지

---

### 18. 사용자- 주문내역 조회

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객의 주문 내역 목록 화면 |
| **주요 기능** | 고객별 주문 목록 조회 (주문번호별 그룹화) |
| **담당자** | 유다원 |
| **필요 DB 테이블** | `purchase_item`, `product`, `branch` |
| **API 엔드포인트** | `GET /api/purchase_items/by_user/{user_seq}/orders` (날짜+시간(분 단위) 그룹화된 주문 목록)<br>`GET /api/purchase_items/by_user/{user_seq}/with_details` |

---

### 19. 사용자- 주문내역 조회(상세화면)

| 항목 | 내용 |
|------|------|
| **화면 설명** | 특정 주문의 상세 정보 화면 |
| **주요 기능** | 주문 상세 정보 조회, 수령 정보 확인 |
| **담당자** | 유다원 |
| **필요 DB 테이블** | `purchase_item`, `user`, `product`, `branch`, `pickup`, `kind_category`, `color_category`, `size_category`, `gender_category`, `maker` |
| **API 엔드포인트** | `GET /api/purchase_items/by_datetime/with_details` (날짜+시간(분 단위) 그룹화된 주문 상세, 파라미터: user_seq, order_datetime, branch_seq)<br>`GET /api/purchase_items/{purchase_item_seq}/full_detail` (단일 구매 항목 상세)<br>`GET /api/pickups/by_bseq/{purchase_item_seq}` |

---

### 20. 사용자-수령 반품목록 조회

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객의 수령 및 반품 목록 화면 (조회만 가능) |
| **주요 기능** | 수령 내역 조회, 반품 내역 조회 |
| **담당자** | 유다원 |
| **필요 DB 테이블** | `pickup`, `purchase_item`, `product`, `branch`, `refund`, `staff` |
| **API 엔드포인트** | `GET /api/pickups/by_user/{user_seq}/with_details`<br>`GET /api/refunds/by_user/{user_seq}/with_details` |

---

### 21. 사용자-수령 반품목록 조회(상세화면)

| 항목 | 내용 |
|------|------|
| **화면 설명** | 특정 수령/반품의 상세 정보 화면 (조회만 가능) |
| **주요 기능** | 수령 상세 정보 조회, 반품 상세 정보 조회, 반품 신청 |
| **담당자** | 유다원 |
| **필요 DB 테이블** | `pickup`, `purchase_item`, `product`, `branch`, `refund`, `staff`, `kind_category`, `color_category`, `size_category`, `gender_category`, `maker` |
| **API 엔드포인트** | `GET /api/pickups/{pickup_seq}/full_detail`<br>`GET /api/refunds/{refund_seq}/full_detail`<br>`POST /api/refunds` |

---

## 추가 작업 화면 (Firebase)

### 22. 관리자-공지 등록

| 항목 | 내용 |
|------|------|
| **화면 설명** | 공지사항 등록 화면 (Firebase 사용) |
| **주요 기능** | 공지사항 작성, 등록, 수정, 삭제 |
| **담당자** | 추가 작업 |
| **필요 DB 테이블** | Firebase Firestore (MySQL 테이블 불필요) |
| **API 엔드포인트** | Firebase SDK 사용<br>`POST /api/firebase/notices` (Firebase Admin SDK)<br>`PUT /api/firebase/notices/{notice_id}`<br>`DELETE /api/firebase/notices/{notice_id}` |
| **참고** | Firebase Firestore를 사용하여 공지사항 관리, 실시간 업데이트 지원 가능

---

### 23. 사용자-공지 조회

| 항목 | 내용 |
|------|------|
| **화면 설명** | 공지사항 조회 화면 (Firebase 사용) |
| **주요 기능** | 공지사항 목록 조회, 상세 조회 |
| **담당자** | 추가 작업 |
| **필요 DB 테이블** | Firebase Firestore (MySQL 테이블 불필요) |
| **API 엔드포인트** | Firebase SDK 사용<br>`GET /api/firebase/notices`<br>`GET /api/firebase/notices/{notice_id}` |
| **참고** | Firebase Firestore를 사용하여 공지사항 조회, 실시간 업데이트 지원 가능

---

### 24. 관리자-상담 채팅

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객 상담 채팅 화면 (Firebase 사용) |
| **주요 기능** | 채팅방 목록 조회, 채팅 메시지 송수신, 채팅방 관리 |
| **담당자** | 이광태 |
| **필요 DB 테이블** | Firebase Firestore (MySQL 테이블 불필요) |
| **API 엔드포인트** | Firebase SDK 사용<br>`GET /api/firebase/chat_rooms`<br>`GET /api/firebase/chat_rooms/{room_id}/messages`<br>`POST /api/firebase/chat_rooms/{room_id}/messages`<br>`PUT /api/firebase/messages/{message_id}/read` |
| **참고** | Firebase Firestore를 사용하여 실시간 채팅 구현, 푸시 알림 연동 가능

---

### 25. 사용자-상담 채팅

| 항목 | 내용 |
|------|------|
| **화면 설명** | 고객 상담 채팅 화면 (Firebase 사용) |
| **주요 기능** | 채팅방 생성, 채팅 메시지 송수신, 채팅 이력 조회 |
| **담당자** | 이광태 |
| **필요 DB 테이블** | Firebase Firestore (MySQL 테이블 불필요) |
| **API 엔드포인트** | Firebase SDK 사용<br>`POST /api/firebase/chat_rooms`<br>`GET /api/firebase/chat_rooms/{room_id}/messages`<br>`POST /api/firebase/chat_rooms/{room_id}/messages`<br>`PUT /api/firebase/messages/{message_id}/read` |
| **참고** | Firebase Firestore를 사용하여 실시간 채팅 구현, 푸시 알림 연동 가능

---

## DB 테이블 구조 요약

### 주요 테이블

| 테이블명 | 설명 |
|---------|------|
| `branch` | 오프라인 지점 정보 |
| `user` | 고객 계정 |
| `user_auth_identities` | 사용자 로그인 수단별 인증 정보 |
| `staff` | 직원 계정 |
| `maker` | 제조사 |
| `kind_category` | 종류 카테고리 |
| `color_category` | 색상 카테고리 |
| `size_category` | 사이즈 카테고리 |
| `gender_category` | 성별 카테고리 |
| `product` | 판매 상품(SKU) |
| `purchase_item` | 구매 내역 |
| `pickup` | 오프라인 수령 |
| `refund` | 반품/환불 |
| `receive` | 입고 |
| `request` | 발주 |

**참고**: 
- Firebase 기능(공지, 상담 채팅)은 MySQL 테이블이 아닌 Firebase Firestore를 사용합니다.

---

## 공통 개발 가이드

### 인증 방식
- 로컬 로그인: ID/PW 확인 방식 (`user_auth_identities` 테이블 사용)
- 소셜 로그인: 구글, 카카오 등 (`user_auth_identities` 테이블에 provider 정보 저장)
- 로그인 후 사용자 정보는 클라이언트에서 관리

### 수령/반품 처리
- 사용자: 수령/반품 신청만 가능
- 관리자: 수령/반품 승인 및 처리 담당

### 주문 그룹화
- `b_date` (구매 일시)를 날짜+시간(분 단위)로 그룹화하여 여러 주문 항목을 하나의 주문으로 처리
- 같은 날짜+시간(분 단위), 사용자(`u_seq`), 지점(`br_seq`)을 가진 `purchase_item`들은 하나의 주문으로 묶음
- `DATE_FORMAT(b_date, '%Y-%m-%d %H:%i')`를 사용하여 분 단위로 주문 그룹화

### 이미지 처리
- 프로필 이미지: `MEDIUMBLOB` 타입으로 저장
- 제품 이미지: `VARCHAR(255)` 경로 문자열로 저장

---

## 참고사항

1. **API 개발**: FastAPI 기반으로 개발하며, 화면 요구사항에 맞춰 API 엔드포인트를 설계합니다.
2. **DB 스키마**: `fastapi/mysql/shoes_shop_db_mysql_init_with_social.sql` 파일 참조
3. **작업 협의**: 공통 응답 형식, 에러 처리 방식 등은 담당자 간 협의가 필요합니다.
4. **수주/발주 관리**: `request`, `receive` 테이블은 차후 화면 개발 시 활용 가능합니다.
5. **Firebase 기능**: 공지사항과 상담 채팅은 Firebase Firestore를 사용하며, MySQL 테이블이 필요하지 않습니다.

---

## 📝 변경 이력

### 2025-12-30 김택권
- **최초 작성**: 화면별 개발 가이드 상세 버전 작성

### 2026-01-01 김택권
- **작업 분담 업데이트**: SUMMARY 버전과 일치하도록 수정
  - 이광태: Firebase 채팅 기능(사용자/관리자) 추가 담당, 장바구니 화면 추가 담당
  - 김택권: 소셜 로그인, 사용자 로그인, 사용자 회원가입, 사용자 개인정보 수정 페이지 담당
  - 정진석: 관리자 관련 화면 및 사용자 드로어 메뉴 담당
  - 이예은: 주문 및 결제 프로세스만 담당 (장바구니 제외)
- **담당자 이름 표기 변경**: 담당자 1~6을 실제 이름(정진석, 이광태, 이예은, 유다원, 임소연, 김택권)으로 변경
- **필요 컬럼을 API 엔드포인트로 변경**: 모든 화면의 "필요 컬럼" 항목을 "API 엔드포인트"로 변경
- **소셜 로그인 반영**: 사용자 로그인/회원가입 화면에 `user_auth_identities` 테이블 추가
- **주문 그룹화 방식 수정**: `b_tnum` 기반 그룹화에서 `b_date` 기반 날짜+시간(분 단위) 그룹화로 변경
- **API 엔드포인트 수정**: `by_tnum` 엔드포인트를 `by_datetime` 엔드포인트로 변경

---

**문서 버전**: 1.1  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

**참고**: 최소 버전은 `SCREEN_API_MAPPING_SUMMARY.md` 파일 참조
