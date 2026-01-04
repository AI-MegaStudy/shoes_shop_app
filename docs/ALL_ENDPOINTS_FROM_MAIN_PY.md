# main.py에 등록된 모든 API 엔드포인트 목록

**작성일**: 2026-01-XX  
**목적**: `fastapi/app/main.py`에 등록된 모든 라우터의 엔드포인트 정리 및 사용 현황  
**기준**: `main.py`의 `app.include_router()` 호출 기준  
**조사 범위**: `lib/view` 폴더 내 모든 Dart 파일

---

## 📋 목차

1. [기본 CRUD API](#기본-crud-api)
2. [JOIN API](#join-api)
3. [Plus API](#plus-api)
4. [Admin API](#admin-api)
5. [기타 API](#기타-api)
6. [요약 통계](#요약-통계)

---

## 사용 현황 표기

- ✅ **사용 중**: `lib/view` 폴더에서 실제로 호출되는 엔드포인트
- ❌ **미사용**: `lib/view` 폴더에서 호출되지 않는 엔드포인트

---

## 기본 CRUD API

### 1. Branches API
**라우터**: `branch.router`  
**Prefix**: `/api/branches`  
**기능**: 매장 지점 정보 관리 (지점 목록, 상세 정보, 추가/수정/삭제)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/branches` | GET | 전체 지점 조회 (지점 목록 반환) | ✅ 사용 중 | `lib/view/user/payment/user_purchase_view.dart`, `lib/view/user/payment/gt_user_purchase_view.dart`, `lib/view/user/payment/user_payment_view.dart` |
| `/api/branches/{branch_seq}` | GET | 특정 지점 상세 정보 조회 | ❌ 미사용 | - |
| `/api/branches` | POST | 새 지점 추가 (지점명, 주소, 전화번호, 좌표 등) | ❌ 미사용 | - |
| `/api/branches/{branch_seq}` | POST | 지점 정보 수정 (지점명, 주소, 전화번호, 좌표 등) | ❌ 미사용 | - |
| `/api/branches/{branch_seq}` | DELETE | 지점 삭제 | ❌ 미사용 | - |

---

### 2. Users API
**라우터**: `users.router`  
**Prefix**: `/api/users`  
**기능**: 고객 계정 관리 (회원가입, 프로필 조회/수정, 프로필 이미지 관리)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/users` | GET | 전체 고객 목록 조회 (이메일, 이름, 전화번호, 주소 등, 이미지 제외) | ✅ 사용 중 | `lib/view/main/user/auth/signup_view.dart` (이메일/전화번호 중복 확인), `lib/view/main/Admin/user/admin_user_list_view.dart` |
| `/api/users/{user_seq}` | GET | 특정 고객 상세 정보 조회 (이메일, 이름, 전화번호, 주소 등, 이미지 제외) | ✅ 사용 중 | `lib/view/main/user/auth/login_view.dart`, `lib/view/user/auth/login_view.dart` |
| `/api/users` | POST | 새 고객 추가 (회원가입, 프로필 이미지 필수) | ✅ 사용 중 | `lib/view/main/user/auth/signup_view.dart` |
| `/api/users/{user_seq}` | POST | 고객 정보 수정 (이름, 전화번호, 주소 등, 이미지 제외) | ✅ 사용 중 | `lib/view/main/user/auth/user_profile_edit_view.dart` |
| `/api/users/{user_seq}/with_image` | POST | 고객 정보 수정 (이름, 전화번호, 주소 + 프로필 이미지 포함) | ✅ 사용 중 | `lib/view/main/user/auth/user_profile_edit_view.dart` |
| `/api/users/{user_seq}/profile_image` | GET | 고객 프로필 이미지 조회 (바이너리 데이터 반환) | ✅ 사용 중 | `lib/view/main/user/auth/user_profile_edit_view.dart`, `lib/view/main/user/menu/main_user_drawer_menu.dart`, `lib/view/main/Admin/user/admin_user_list_view.dart`, `lib/view/user/auth/user_drawer_menu.dart` |
| `/api/users/{user_seq}/profile_image` | DELETE | 고객 프로필 이미지 삭제 | ❌ 미사용 | - |
| `/api/users/{user_seq}` | DELETE | 고객 계정 삭제 (소프트 삭제: u_quit_date 설정) | ❌ 미사용 | - |

---

### 3. User Auth Identities API
**라우터**: `user_auth_identities.router`  
**Prefix**: `/api/user_auth_identities`  
**기능**: 사용자 인증 정보 관리 (로컬/소셜 로그인 정보, 로그인 시간 추적)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/user_auth_identities/user/{user_seq}` | GET | 특정 사용자의 모든 인증 정보 조회 (로컬, 구글, 카카오 등) | ✅ 사용 중 | `lib/view/main/Admin/user/admin_user_list_view.dart` |
| `/api/user_auth_identities/provider/{provider}` | GET | 특정 제공자별 인증 정보 조회 (예: provider=local인 모든 로컬 로그인 정보) | ✅ 사용 중 | `lib/view/main/user/auth/login_view.dart`, `lib/view/user/auth/login_view.dart` (provider=local) |
| `/api/user_auth_identities` | POST | 새 인증 정보 추가 (회원가입 시 로컬 로그인 정보 생성) | ✅ 사용 중 | `lib/view/main/user/auth/signup_view.dart` |
| `/api/user_auth_identities/{auth_seq}` | POST | 인증 정보 수정 (비밀번호 변경 등) | ❌ 미사용 | - |
| `/api/user_auth_identities/{auth_seq}/update_login_time` | POST | 마지막 로그인 시간 업데이트 (로그인 성공 시 호출) | ✅ 사용 중 | `lib/view/main/user/auth/login_view.dart`, `lib/view/user/auth/login_view.dart` |
| `/api/user_auth_identities/{auth_seq}` | DELETE | 인증 정보 삭제 (특정 인증 수단 제거) | ❌ 미사용 | - |

---

### 4. Auth API
**라우터**: `auth.router`  
**Prefix**: `/api`  
**기능**: 소셜 로그인 및 회원가입 처리

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/auth/social/login` | POST | 소셜 로그인 및 회원가입 (Google, Kakao 등. 기존 사용자면 로그인, 신규면 회원가입 처리) | ✅ 사용 중 | `lib/view/main/user/auth/login_view.dart`, `lib/view/user/auth/login_view.dart` |

---

### 5. Staff API
**라우터**: `staff.router`  
**Prefix**: `/api/staff`  
**기능**: 직원 계정 관리 (관리자 로그인, 직원 정보 조회/수정, 프로필 이미지 관리)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/staff` | GET | 전체 직원 목록 조회 (모든 지점의 모든 직원) | ❌ 미사용 | - |
| `/api/staff/{staff_seq}` | GET | 특정 직원 상세 정보 조회 (직원 SEQ로 조회) | ❌ 미사용 | - |
| `/api/staff/by_id/{staff_id}` | GET | 직원 ID로 조회 (관리자 로그인용, s_id로 조회, 탈퇴하지 않은 직원만) | ✅ 사용 중 | `lib/view/main/Admin/auth/admin_login_view_dev.dart` |
| `/api/staff/by_branch/{branch_seq}` | GET | 특정 지점의 직원 목록 조회 | ❌ 미사용 | - |
| `/api/staff` | POST | 새 직원 추가 (직원 ID, 비밀번호, 이름, 전화번호, 직급, 프로필 이미지 필수) | ❌ 미사용 | - |
| `/api/staff/{staff_seq}` | POST | 직원 정보 수정 (이름, 전화번호, 직급 등, 이미지 제외) | ✅ 사용 중 | `lib/view/main/Admin/auth/admin_profile_edit_view.dart` |
| `/api/staff/{staff_seq}/with_image` | POST | 직원 정보 수정 (이름, 전화번호, 직급 + 프로필 이미지 포함) | ✅ 사용 중 | `lib/view/main/Admin/auth/admin_profile_edit_view.dart` |
| `/api/staff/{staff_seq}/profile_image` | GET | 직원 프로필 이미지 조회 (바이너리 데이터 반환) | ✅ 사용 중 | `lib/view/main/Admin/auth/admin_profile_edit_view.dart` |
| `/api/staff/{staff_seq}/profile_image` | DELETE | 직원 프로필 이미지 삭제 | ❌ 미사용 | - |
| `/api/staff/{staff_seq}` | DELETE | 직원 계정 삭제 (소프트 삭제: s_quit_date 설정) | ❌ 미사용 | - |

---

### 6. Makers API
**라우터**: `maker.router`  
**Prefix**: `/api/makers`  
**기능**: 제조사 정보 관리 (나이키, 아디다스 등 브랜드 정보)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/makers` | GET | 전체 제조사 목록 조회 (제조사명, 전화번호, 주소 등) | ✅ 사용 중 | `lib/view/main/Admin/product/product_insert.dart`, `lib/view/main/Admin/product/product_update.dart` |
| `/api/makers/{maker_seq}` | GET | 특정 제조사 상세 정보 조회 | ❌ 미사용 | - |
| `/api/makers` | POST | 새 제조사 추가 (제조사명, 전화번호, 주소 등) | ❌ 미사용 | - |
| `/api/makers/{id}` | POST | 제조사 정보 수정 (제조사명, 전화번호, 주소 등) | ❌ 미사용 | - |
| `/api/makers/{maker_seq}` | DELETE | 제조사 삭제 | ❌ 미사용 | - |

---

### 7. Kind Categories API
**라우터**: `kind_category.router`  
**Prefix**: `/api/kind_categories`  
**기능**: 제품 종류 카테고리 관리 (러닝화, 운동화, 부츠 등)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/kind_categories` | GET | 전체 종류 카테고리 목록 조회 | ✅ 사용 중 | `lib/view/main/Admin/product/product_insert.dart`, `lib/view/main/Admin/product/product_update.dart` |
| `/api/kind_categories/{kind_category_seq}` | GET | 특정 종류 카테고리 상세 조회 | ❌ 미사용 | - |
| `/api/kind_categories` | POST | 새 종류 카테고리 추가 | ❌ 미사용 | - |
| `/api/kind_categories/{id}` | POST | 종류 카테고리 수정 | ❌ 미사용 | - |
| `/api/kind_categories/{kind_category_seq}` | DELETE | 종류 카테고리 삭제 | ❌ 미사용 | - |

---

### 8. Color Categories API
**라우터**: `color_category.router`  
**Prefix**: `/api/color_categories`  
**기능**: 색상 카테고리 관리 (블랙, 화이트, 레드 등)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/color_categories` | GET | 전체 색상 카테고리 목록 조회 | ✅ 사용 중 | `lib/view/main/Admin/product/product_insert.dart`, `lib/view/main/Admin/product/product_update.dart`, `lib/view/user/product/detail_view.dart` |
| `/api/color_categories/{color_category_seq}` | GET | 특정 색상 카테고리 상세 조회 | ❌ 미사용 | - |
| `/api/color_categories` | POST | 새 색상 카테고리 추가 | ❌ 미사용 | - |
| `/api/color_categories/{id}` | POST | 색상 카테고리 수정 | ❌ 미사용 | - |
| `/api/color_categories/{color_category_seq}` | DELETE | 색상 카테고리 삭제 | ❌ 미사용 | - |

---

### 9. Size Categories API
**라우터**: `size_category.router`  
**Prefix**: `/api/size_categories`  
**기능**: 사이즈 카테고리 관리 (250, 260, 270 등)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/size_categories` | GET | 전체 사이즈 카테고리 목록 조회 | ✅ 사용 중 | `lib/view/main/Admin/product/product_insert.dart`, `lib/view/main/Admin/product/product_update.dart`, `lib/view/user/product/detail_view.dart` |
| `/api/size_categories/{size_category_seq}` | GET | 특정 사이즈 카테고리 상세 조회 | ❌ 미사용 | - |
| `/api/size_categories` | POST | 새 사이즈 카테고리 추가 | ❌ 미사용 | - |
| `/api/size_categories/{id}` | POST | 사이즈 카테고리 수정 | ❌ 미사용 | - |
| `/api/size_categories/{size_category_seq}` | DELETE | 사이즈 카테고리 삭제 | ❌ 미사용 | - |

---

### 10. Gender Categories API
**라우터**: `gender_category.router`  
**Prefix**: `/api/gender_categories`  
**기능**: 성별 카테고리 관리 (남성, 여성, 유니섹스 등)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/gender_categories` | GET | 전체 성별 카테고리 목록 조회 | ✅ 사용 중 | `lib/view/main/Admin/product/product_insert.dart`, `lib/view/main/Admin/product/product_update.dart`, `lib/view/user/product/detail_view.dart` |
| `/api/gender_categories/{gender_category_seq}` | GET | 특정 성별 카테고리 상세 조회 | ❌ 미사용 | - |
| `/api/gender_categories` | POST | 새 성별 카테고리 추가 | ❌ 미사용 | - |
| `/api/gender_categories/{id}` | POST | 성별 카테고리 수정 | ❌ 미사용 | - |
| `/api/gender_categories/{gender_category_seq}` | DELETE | 성별 카테고리 삭제 | ❌ 미사용 | - |

---

### 11. Refund Reason Categories API
**라우터**: `refund_reason_category.router`  
**Prefix**: `/api/refund_reason_categories`  
**기능**: 반품 사유 카테고리 관리 (사이즈 불일치, 색상 불일치, 불량 등)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/refund_reason_categories` | GET | 전체 반품 사유 카테고리 목록 조회 | ✅ 사용 중 | `lib/view/admin/auth/admin_pickup_view.dart` |
| `/api/refund_reason_categories/{refund_reason_category_seq}` | GET | 특정 반품 사유 카테고리 상세 조회 | ❌ 미사용 | - |
| `/api/refund_reason_categories` | POST | 새 반품 사유 카테고리 추가 | ❌ 미사용 | - |
| `/api/refund_reason_categories/{id}` | POST | 반품 사유 카테고리 수정 | ❌ 미사용 | - |
| `/api/refund_reason_categories/{refund_reason_category_seq}` | DELETE | 반품 사유 카테고리 삭제 | ❌ 미사용 | - |

---

### 12. Products API
**라우터**: `product.router`  
**Prefix**: `/api/products`  
**기능**: 제품 정보 관리 (제품 등록/수정/삭제, 재고 관리, 이미지 관리, 검색)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/products` | GET | 전체 제품 조회 (모든 제품 목록, 제품 + 모든 카테고리 + 제조사 정보 JOIN) | ✅ 사용 중 | `lib/view/user/payment/user_cart_view.dart` |
| `/api/products/group_by_name` | GET | 제품명별 그룹화 조회 (같은 제품명의 최저가 표시, 제품 목록 화면용) | ✅ 사용 중 | `lib/view/user/product/list_view.dart` |
| `/api/products/id/{product_seq}` | GET | 제품 ID로 단일 제품 조회 (재고 확인용) | ✅ 사용 중 | `lib/view/user/payment/user_purchase_view.dart` |
| `/api/products/getBySeqs` | GET | 제조사와 제품명으로 제품 조회 (옵션별 제품 찾기, 쿼리 파라미터: m_seq, p_name, cc_seq, sc_seq, gc_seq) | ✅ 사용 중 | `lib/view/user/product/detail_view.dart` |
| `/api/products/searchByMain` | GET | 키워드로 제품명 검색 (부분 일치 검색, 쿼리 파라미터: kwds) | ✅ 사용 중 | `lib/view/user/product/list_view.dart` |
| `/api/products` | POST | 새 제품 추가 (카테고리, 제조사, 제품명, 가격, 재고, 설명 등) | ✅ 사용 중 | `lib/view/main/Admin/product/product_insert.dart` |
| `/api/products/{product_seq}` | POST | 제품 정보 수정 (카테고리, 제조사, 제품명, 가격, 재고, 설명 등) | ✅ 사용 중 | `lib/view/main/Admin/product/product_update.dart` |
| `/api/products/{product_seq}/stock` | POST | 제품 재고 수정 (재고량만 변경) | ✅ 사용 중 | `lib/view/main/Admin/product/product_management_detail.dart` |
| `/api/products/{product_seq}` | DELETE | 제품 삭제 | ❌ 미사용 | - |
| `/api/products/{product_seq}/upload_file` | POST | 제품 이미지 업로드 (제품 상세 이미지 업로드) | ✅ 사용 중 | `lib/view/main/Admin/product/file_upload_util.dart` |

---

### 13. Purchase Items API
**라우터**: `purchase_item.router`  
**Prefix**: `/api/purchase_items`  
**기능**: 구매 내역 관리 (주문 추가, 주문 상태 수정, 주문 조회)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/purchase_items` | GET | 전체 구매 내역 조회 (모든 고객의 모든 주문) | ❌ 미사용 | - |
| `/api/purchase_items/{purchase_item_seq}` | GET | 특정 구매 내역 상세 조회 (주문 번호로 조회) | ❌ 미사용 | - |
| `/api/purchase_items/by_user/{user_seq}` | GET | 특정 고객의 모든 구매 내역 조회 (기본 형식) | ❌ 미사용 | - |
| `/api/purchase_items/by_datetime` | GET | 분 단위 그룹화된 주문 조회 (기본 형식, 쿼리 파라미터: user_seq, order_datetime, branch_seq) | ❌ 미사용 | - |
| `/api/purchase_items` | POST | 새 구매 내역 추가 (주문 생성: 지점, 고객, 제품, 가격, 수량, 상태 등) | ✅ 사용 중 | `lib/view/user/payment/user_purchase_view.dart` |
| `/api/purchase_items/{purchase_item_seq}` | POST | 구매 내역 수정 (주문 상태 변경 등: b_status 수정) | ✅ 사용 중 | `lib/view/admin/auth/admin_purchase_view.dart`, `lib/view/admin/auth/admin_pickup_view.dart` |
| `/api/purchase_items/{purchase_item_seq}` | DELETE | 구매 내역 삭제 (주문 취소) | ❌ 미사용 | - |

---

### 14. Pickups API
**라우터**: `pickup.router`  
**Prefix**: `/api/pickups`  
**기능**: 수령 내역 관리 (수령 등록, 수령 완료 처리, 수령 조회)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/pickups` | GET | 전체 수령 내역 조회 (모든 고객의 모든 수령 내역) | ❌ 미사용 | - |
| `/api/pickups/{pickup_seq}` | GET | 특정 수령 내역 상세 조회 (수령 번호로 조회) | ❌ 미사용 | - |
| `/api/pickups/by_bseq/{purchase_item_seq}` | GET | 특정 구매 내역의 수령 내역 조회 (주문 번호로 수령 내역 찾기) | ❌ 미사용 | - |
| `/api/pickups` | POST | 새 수령 내역 추가 (주문 수령 처리: 구매 내역과 연결) | ✅ 사용 중 | `lib/view/user/payment/user_purchase_view.dart`, `lib/view/admin/auth/admin_purchase_view.dart` |
| `/api/pickups/{id}` | POST | 수령 내역 수정 | ❌ 미사용 | - |
| `/api/pickups/{pickup_seq}/complete` | POST | 수령 완료 처리 (수령 상태 업데이트, b_status를 '2'로 변경) | ❌ 미사용 | - |
| `/api/pickups/{pickup_seq}` | DELETE | 수령 내역 삭제 | ❌ 미사용 | - |

---

### 15. Refunds API
**라우터**: `refund.router`  
**Prefix**: `/api/refunds`  
**기능**: 반품 내역 관리 (반품 신청, 반품 처리, 반품 조회)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/refunds` | GET | 전체 반품 내역 조회 (모든 고객의 모든 반품 내역) | ❌ 미사용 | - |
| `/api/refunds/{refund_seq}` | GET | 특정 반품 내역 상세 조회 (반품 번호로 조회) | ❌ 미사용 | - |
| `/api/refunds/by_user/{user_seq}` | GET | 특정 고객의 모든 반품 내역 조회 (기본 형식) | ❌ 미사용 | - |
| `/api/refunds` | POST | 새 반품 내역 추가 (반품 신청: 수령 내역과 연결, 반품 사유 등) | ✅ 사용 중 | `lib/view/admin/auth/admin_pickup_view.dart` |
| `/api/refunds/{id}` | POST | 반품 내역 수정 | ❌ 미사용 | - |
| `/api/refunds/{refund_seq}/process` | POST | 반품 처리 (반품 승인/거부 처리, b_status를 '3'로 변경) | ❌ 미사용 | - |
| `/api/refunds/{refund_seq}` | DELETE | 반품 내역 삭제 | ❌ 미사용 | - |

---

## JOIN API

### 1. Product Join API
**라우터**: `product_join.router`  
**Prefix**: `/api/products`  
**기능**: 제품 정보와 관련 카테고리/제조사 정보를 JOIN하여 조회

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/products/with_categories` | GET | 모든 제품과 카테고리 정보를 함께 조회 (필터링 가능, 쿼리 파라미터: maker_seq, kind_seq, color_seq, size_seq, gender_seq) | ✅ 사용 중 | `lib/view/main/Admin/product/product_management.dart` |

---

---

### 4. Refund Join API
**라우터**: `refund_join.router`  
**Prefix**: `/api/refunds`  
**기능**: 반품 내역과 관련 고객/직원/수령/구매 내역/제품/지점/카테고리 정보를 JOIN하여 조회

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/refunds/refunds/{refund_seq}/with_details` | GET | 반품 + 고객 + 직원 + 수령 + 구매 내역 + 제품 + 지점 정보 (7테이블 JOIN, 반품 상세 정보) | ❌ 미사용 | - |
| `/api/refunds/refunds/{refund_seq}/full_detail` | GET | 반품 전체 상세 정보 (반품 + 고객 + 직원 + 수령 + 구매 내역 + 제품 + 지점 + 모든 카테고리 + 제조사, 12테이블 JOIN) | ❌ 미사용 | - |
| `/api/refunds/refunds/by_user/{user_seq}/with_details` | GET | 고객별 반품 상세 조회 (특정 고객의 모든 반품 내역 + 상세 정보) | ❌ 미사용 | - |
| `/api/refunds/refunds/by_staff/{staff_seq}/with_details` | GET | 직원별 반품 상세 조회 (특정 직원이 처리한 모든 반품 내역 + 상세 정보) | ❌ 미사용 | - |

**참고**: 실제 경로는 prefix `/api/refunds` + 라우터 경로 `/refunds/{refund_seq}/with_details` = `/api/refunds/refunds/{refund_seq}/with_details`

---

---

## Plus API

### 1. Purchase Items Plus API
**라우터**: `purchase_item_plus.router`  
**Prefix**: `/api/purchase_items`  
**기능**: 고객용 주문 내역 조회 (검색 및 정렬 기능 포함)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/purchase_items/by_user/{user_seq}/user_bundle` | GET | 고객별 주문 내역을 분 단위로 그룹화하여 조회 (주문 일자별로 묶음, 검색 및 정렬 기능 포함, 쿼리 파라미터: keyword, order, b_status='0' 또는 '1'만 조회) | ✅ 사용 중 | `lib/view/user/user_purchase_list.dart` |

---

### 2. Pickups Plus API
**라우터**: `pickup_plus.router`  
**Prefix**: `/api/pickups`  
**기능**: 고객용 수령 내역 조회 (검색 및 정렬 기능 포함)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/pickups/by_user/{user_seq}/all` | GET | 고객별 수령 내역 전체 조회 (검색 및 정렬 기능 포함, 쿼리 파라미터: keyword, order, b_status='2'만 조회) | ✅ 사용 중 | `lib/view/user/user_pickup_list.dart` |

---

### 3. Refunds Plus API
**라우터**: `refund_plus.router`  
**Prefix**: `/api/refunds`  
**기능**: 고객용 반품 내역 조회 (검색 및 정렬 기능 포함)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/refunds/refund/by_user/{user_seq}/all` | GET | 고객별 반품 내역 전체 조회 (검색 및 정렬 기능 포함, 쿼리 파라미터: keyword, order, 반품 사유, 처리 직원 정보 포함) | ✅ 사용 중 | `lib/view/user/user_refund_list.dart` |

---

## Admin API

### 1. Purchase Items Admin API
**라우터**: `purchase_item_admin.router`  
**Prefix**: `/api/purchase_items/admin`  
**기능**: 관리자용 구매 내역 조회 (전체 주문 목록, 상세 정보)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/purchase_items/admin/all` | GET | 관리자용 전체 구매 내역 조회 (모든 고객의 모든 주문, 검색 기능 포함, 쿼리 파라미터: search, 구매 내역 번호 또는 고객 이름으로 검색) | ✅ 사용 중 | `lib/view/admin/auth/admin_purchase_view.dart` |
| `/api/purchase_items/admin/{purchase_item_seq}/full_detail` | GET | 관리자용 구매 내역 전체 상세 정보 (구매 내역 + 고객 + 제품 + 지점 + 모든 카테고리 + 제조사, 9테이블 JOIN) | ✅ 사용 중 | `lib/view/admin/auth/admin_purchase_view.dart` |

---

### 2. Pickups Admin API
**라우터**: `pickup_admin.router`  
**Prefix**: `/api/pickups/admin`  
**기능**: 관리자용 수령 내역 조회 (전체 수령 목록, 상세 정보)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/pickups/admin/all` | GET | 관리자용 전체 수령 내역 조회 (모든 고객의 모든 수령 내역, 검색 기능 포함, 쿼리 파라미터: search, 수령 번호 또는 고객 이름으로 검색) | ✅ 사용 중 | `lib/view/admin/auth/admin_pickup_view.dart` |
| `/api/pickups/admin/{pickup_seq}/full_detail` | GET | 관리자용 수령 내역 전체 상세 정보 (수령 + 구매 내역 + 고객 + 제품 + 지점 + 모든 카테고리 + 제조사, 10테이블 JOIN) | ✅ 사용 중 | `lib/view/admin/auth/admin_pickup_view.dart` |

---

### 3. Refunds Admin API
**라우터**: `refund_admin.router`  
**Prefix**: `/api/refunds/admin`  
**기능**: 관리자용 반품 내역 조회 (전체 반품 목록, 상세 정보)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/refunds/admin/all` | GET | 관리자용 전체 반품 내역 조회 (모든 고객의 모든 반품 내역, 검색 기능 포함, 쿼리 파라미터: search, 반품 번호 또는 고객 이름으로 검색) | ✅ 사용 중 | `lib/view/admin/auth/admin_refund_view.dart` |
| `/api/refunds/admin/{refund_seq}/full_detail` | GET | 관리자용 반품 내역 전체 상세 정보 (반품 + 고객 + 직원 + 수령 + 구매 내역 + 제품 + 지점 + 모든 카테고리 + 제조사, 12테이블 JOIN) | ✅ 사용 중 | `lib/view/admin/auth/admin_refund_view.dart` |

---

## 기타 API

### Chatting API
**라우터**: `chatting.router`  
**Prefix**: `/api/chatting`  
**기능**: 고객-직원 간 채팅 세션 관리 (Firebase Firestore와 연동)

| 엔드포인트 | 메서드 | 설명 | 상태 | 사용 위치 |
|-----------|--------|------|------|----------|
| `/api/chatting` | GET | 전체 채팅 세션 조회 (모든 고객의 모든 채팅 세션) | ❌ 미사용 | - |
| `/api/chatting/by_user_seq` | GET | 고객별 채팅 세션 조회 (특정 고객의 채팅 세션, 쿼리 파라미터: u_seq, is_closed, Firebase 문서 ID 반환) | ✅ 사용 중 | `lib/view/user/product/chatting.dart` |
| `/api/chatting/{chatting_seq}` | GET | 채팅 세션 상세 조회 (채팅 세션 번호로 조회) | ❌ 미사용 | - |
| `/api/chatting` | POST | 채팅 세션 추가 (새 채팅 방 생성, Firebase 문서 ID 저장) | ❌ 미사용 | (직접 http.post 사용 가능성 있음) |
| `/api/chatting/{id}` | POST | 채팅 세션 수정 (담당 직원 배정, 종료 상태 변경 등) | ❌ 미사용 | - |
| `/api/chatting/{chatting_seq}` | DELETE | 채팅 세션 삭제 | ❌ 미사용 | - |

---

## 요약 통계

### 전체 통계

| 카테고리 | 총 엔드포인트 | 사용 중 | 미사용 | 사용률 |
|---------|-------------|---------|--------|--------|
| **기본 CRUD API** | 66개 | 28개 | 38개 | 42.4% |
| **JOIN API** | 5개 | 1개 | 4개 | 20% |
| **Plus API** | 3개 | 3개 | 0개 | 100% |
| **Admin API** | 6개 | 6개 | 0개 | 100% |
| **기타 API** | 6개 | 1개 | 5개 | 17% |
| **합계** | **86개** | **39개** | **47개** | **45.3%** |

### 주요 미사용 카테고리

1. **JOIN API**: 대부분 미사용 (5개 중 1개만 사용)
   - 상세 정보 조회가 필요한 경우 Plus API나 Admin API 사용
   - `with_details`, `full_detail` 엔드포인트 활용도 낮음

2. **Chatting API**: 대부분 미사용 (6개 중 1개만 사용)
   - 채팅 세션 조회만 사용, 생성/수정/삭제는 직접 처리하거나 미구현

### 사용 중인 주요 엔드포인트

1. **인증 관련**: 로그인, 회원가입, 프로필 관리
2. **제품 관리**: 제품 조회, 등록, 수정, 재고 관리
3. **주문/결제**: 구매 내역 추가, 수령 추가, 반품 추가
4. **고객용 조회**: 주문 내역, 수령 내역, 반품 내역 조회 (Plus API)
5. **관리자용 조회**: 구매/수령/반품 내역 조회 (Admin API)

### 라우터 등록 순서 (중요)
`main.py`에서 라우터 등록 순서가 중요합니다. 더 구체적인 경로가 먼저 등록되어야 합니다:
1. JOIN 라우터 (더 구체적인 경로)
2. 기본 CRUD 라우터
3. Plus API 라우터
4. Admin API 라우터

### 권장사항

1. **JOIN API 활용**: 현재 JOIN API 사용률이 낮음 (20%). 필요한 기능이 있다면 JOIN API 활용 검토
2. **코드 정리**: 사용되지 않는 엔드포인트는 백엔드 코드에서도 제거 검토 (또는 향후 사용 계획 명시)
3. **문서화**: 미사용 엔드포인트의 향후 사용 계획을 문서화하여 유지보수성 향상

---

**문서 버전**: 2.0  
**최종 수정일**: 2026-01-XX

### 변경 이력
- **v2.0**: 사용/미사용 상태 및 기능 설명 추가
  - 각 엔드포인트에 상태(사용 중/미사용) 및 사용 위치 추가
  - 각 엔드포인트의 기능 설명 상세화
  - 요약 통계 및 권장사항 추가
- **v2.1**: 미사용 엔드포인트 삭제
  - Receives API 전체 삭제 (7개 기본 CRUD + 5개 JOIN)
  - Requests API 전체 삭제 (7개 기본 CRUD + 6개 JOIN)
  - Purchase Item Join API 전체 삭제 (4개)
  - Pickup Join API 전체 삭제 (4개)
  - Receive Join API 전체 삭제 (5개)
  - Request Join API 전체 삭제 (6개)
  - 개별 미사용 엔드포인트 삭제 (User Auth Identities 2개, Products 5개, Product Join 3개)
  - 총 34개 엔드포인트 삭제 (120개 → 86개)

