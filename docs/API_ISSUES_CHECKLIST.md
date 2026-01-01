# FastAPI API 파일 컬럼명 및 인덱스 매핑 체크리스트

**작성일**: 2026-01-01  
**작성자**: AI Assistant  
**목적**: FastAPI API 파일들의 SQL SELECT 절과 인덱스 매핑, DB 스키마 일치 여부 확인

---

## 📋 체크 항목

1. SQL SELECT 절의 컬럼 순서
2. 결과 파싱 시 인덱스 매핑 (row[0], row[1] 등)
3. 실제 DB 스키마와의 컬럼명 일치 여부
4. 경로 파라미터 및 엔드포인트 충돌

---

## ❌ 발견된 문제점

### 1. staff.py

#### 문제 1-1: 경로 파라미터 불일치
- **파일**: `fastapi/app/api/staff.py`
- **위치**: 234줄
- **문제**: 
  ```python
  @router.get("/staff_seq/profile_image")
  async def view_staff_profile_image(staff_seq: int):
  ```
- **설명**: 경로에 `/staff_seq/`라는 리터럴 문자열이 포함되어 있어, 실제로는 `/api/staffs/staff_seq/profile_image`로 접근해야 함. 경로 파라미터로 사용하려면 `/{staff_seq}/profile_image`로 수정 필요
- **영향**: 엔드포인트 접근 불가능
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전
  @router.get("/staff_seq/profile_image")
  async def view_staff_profile_image(staff_seq: int):
  
  # 수정 후
  @router.get("/{staff_seq}/profile_image")
  async def view_staff_profile_image(staff_seq: int):
  ```
  - 경로의 리터럴 문자열 `/staff_seq/`를 경로 파라미터 `/{staff_seq}/`로 변경
  - 이제 `/api/staffs/{staff_seq}/profile_image` 형태로 접근 가능

#### 문제 1-2: 경로 파라미터 명명 불일치
- **파일**: `fastapi/app/api/staff.py`
- **위치**: 158줄, 194줄
- **문제**:
  ```python
  @router.post("/{id}")
  async def update_staff(
      s_seq: int = Form(...),  # 함수 파라미터로 받음
  ```
- **설명**: 경로는 `/{id}`인데 함수 파라미터는 `s_seq`를 Form으로 받고 있음. 경로 파라미터는 별도로 정의되지 않음. 일반적으로는 `@router.post("/{staff_seq}")` 형태로 경로 파라미터를 받아야 함
- **영향**: 경로 파라미터와 함수 파라미터 불일치로 혼란 가능
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전 (158줄)
  @router.post("/{id}")
  async def update_staff(
      s_seq: int = Form(...),
      s_id: str = Form(...),
      br_seq: int = Form(...),
      # ... 나머지 Form 파라미터들
  ):
      # s_seq를 Form으로 받아서 사용
  
  # 수정 후
  @router.post("/{staff_seq}")
  async def update_staff(
      staff_seq: int,  # 경로 파라미터로 받음
      s_id: str = Form(...),
      br_seq: int = Form(...),
      # ... 나머지 Form 파라미터들 (s_seq 제외)
  ):
      # staff_seq를 경로 파라미터로 받아서 사용
      # SQL 쿼리에서 s_seq 대신 staff_seq 사용
      curs.execute(sql, (s_id, br_seq, ..., staff_seq))
  ```
  - 경로 파라미터명을 `{id}`에서 `{staff_seq}`로 변경
  - 함수 파라미터에서 `s_seq: int = Form(...)` 제거하고 `staff_seq: int` 경로 파라미터 추가
  - SQL 쿼리의 WHERE 절에서 `staff_seq` 사용
  - 194줄의 `update_staff_with_image` 함수도 동일하게 수정

#### 문제 1-3: DELETE 엔드포인트 중복
- **파일**: `fastapi/app/api/staff.py`
- **위치**: 262줄, 279줄
- **문제**: 
  - 262줄: `@router.delete("/{staff_seq}")` - 프로필 이미지 삭제
  - 279줄: `@router.delete("/{staff_seq}")` - 직원 삭제
- **설명**: 같은 경로에 두 개의 DELETE 엔드포인트가 있어 충돌 발생. 프로필 이미지 삭제는 `/{staff_seq}/profile_image`로 변경 필요
- **영향**: 두 번째 엔드포인트가 무시됨
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전 (262줄)
  @router.delete("/{staff_seq}")
  async def delete_staff_profile_image(staff_seq: int):
      sql = "UPDATE staff SET s_image=NULL WHERE s_seq=%s"
      curs.execute(sql, (staff_seq,))
  
  # 수정 후 (262줄)
  @router.delete("/{staff_seq}/profile_image")
  async def delete_staff_profile_image(staff_seq: int):
      sql = "UPDATE staff SET s_image=NULL WHERE s_seq=%s"
      curs.execute(sql, (staff_seq,))
  
  # 279줄은 그대로 유지
  @router.delete("/{staff_seq}")
  async def delete_staff(staff_seq: int):
      sql = "DELETE FROM staff WHERE s_seq=%s"
      curs.execute(sql, (staff_seq,))
  ```
  - 프로필 이미지 삭제 엔드포인트 경로를 `/{staff_seq}/profile_image`로 변경
  - 이제 두 엔드포인트가 구분됨:
    - `/api/staffs/{staff_seq}/profile_image` (DELETE) - 프로필 이미지 삭제
    - `/api/staffs/{staff_seq}` (DELETE) - 직원 삭제

---

### 2. pickup.py

#### 문제 2-1: GET 엔드포인트 중복
- **파일**: `fastapi/app/api/pickup.py`
- **위치**: 51줄, 76줄
- **문제**:
  - 51줄: `@router.get("/{pickup_seq}")` - ID로 수령 내역 조회
  - 76줄: `@router.get("/{purchase_seq}")` - 구매 ID로 수령 내역 조회
- **설명**: FastAPI는 경로 파라미터 타입만으로는 구분하지 못함. 두 엔드포인트가 동일한 경로 패턴을 사용하여 충돌 발생. 76줄을 `/by_purchase/{purchase_seq}` 또는 `/by_bseq/{purchase_seq}`로 변경 필요
- **영향**: 두 번째 엔드포인트가 무시됨
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전 (76줄)
  @router.get("/{purchase_seq}")
  async def select_pickup_by_purchase(purchase_seq: int):
      curs.execute("""
          SELECT pic_seq, b_seq, u_seq, created_at 
          FROM pickup 
          WHERE b_seq = %s
      """, (purchase_seq,))
  
  # 수정 후 (76줄)
  @router.get("/by_bseq/{purchase_item_seq}")
  async def select_pickup_by_purchase(purchase_item_seq: int):
      curs.execute("""
          SELECT pic_seq, b_seq, u_seq, created_at 
          FROM pickup 
          WHERE b_seq = %s
      """, (purchase_item_seq,))
  ```
  - 경로를 `/{purchase_seq}`에서 `/by_bseq/{purchase_item_seq}`로 변경
  - 함수 파라미터명도 `purchase_item_seq`로 변경하여 의미 명확화
  - 이제 두 엔드포인트가 구분됨:
    - `/api/pickups/{pickup_seq}` (GET) - pic_seq로 수령 내역 조회
    - `/api/pickups/by_bseq/{purchase_item_seq}` (GET) - b_seq로 수령 내역 조회

#### 문제 2-2: 경로 파라미터 불일치
- **파일**: `fastapi/app/api/pickup.py`
- **위치**: 161줄
- **문제**:
  ```python
  @router.post("/pickup_seq/complete")
  async def complete_pickup(pickup_seq: int):
  ```
- **설명**: 경로에 `/pickup_seq/`라는 리터럴 문자열이 포함되어 있음. 경로 파라미터로 사용하려면 `/{pickup_seq}/complete`로 수정 필요
- **영향**: 엔드포인트 접근 불가능
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전
  @router.post("/pickup_seq/complete")
  async def complete_pickup(pickup_seq: int):
      created_at_dt = datetime.now()
      sql = "UPDATE pickup SET created_at=%s WHERE pic_seq=%s"
      curs.execute(sql, (created_at_dt, pickup_seq))
  
  # 수정 후
  @router.post("/{pickup_seq}/complete")
  async def complete_pickup(pickup_seq: int):
      created_at_dt = datetime.now()
      sql = "UPDATE pickup SET created_at=%s WHERE pic_seq=%s"
      curs.execute(sql, (created_at_dt, pickup_seq))
  ```
  - 경로의 리터럴 문자열 `/pickup_seq/`를 경로 파라미터 `/{pickup_seq}/`로 변경
  - 이제 `/api/pickups/{pickup_seq}/complete` 형태로 접근 가능

---

### 3. receive.py

#### 문제 3-1: GET 엔드포인트 중복
- **파일**: `fastapi/app/api/receive.py`
- **위치**: 55줄, 82줄
- **문제**:
  - 55줄: `@router.get("/{receive_seq}")` - ID로 입고 내역 조회
  - 82줄: `@router.get("/{product_seq}")` - 제품별 입고 내역 조회
- **설명**: 두 엔드포인트가 동일한 경로 패턴을 사용하여 충돌 발생. 82줄을 `/by_product/{product_seq}`로 변경 필요
- **영향**: 두 번째 엔드포인트가 무시됨
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전 (82줄)
  @router.get("/{product_seq}")
  async def select_receives_by_product(product_seq: int):
      curs.execute("""
          SELECT rec_seq, rec_quantity, rec_date, s_seq, p_seq, m_seq 
          FROM receive 
          WHERE p_seq = %s
          ORDER BY rec_date DESC, rec_seq
      """, (product_seq,))
  
  # 수정 후 (82줄)
  @router.get("/by_product/{product_seq}")
  async def select_receives_by_product(product_seq: int):
      curs.execute("""
          SELECT rec_seq, rec_quantity, rec_date, s_seq, p_seq, m_seq 
          FROM receive 
          WHERE p_seq = %s
          ORDER BY rec_date DESC, rec_seq
      """, (product_seq,))
  ```
  - 경로를 `/{product_seq}`에서 `/by_product/{product_seq}`로 변경
  - 이제 두 엔드포인트가 구분됨:
    - `/api/receives/{receive_seq}` (GET) - rec_seq로 입고 내역 조회
    - `/api/receives/by_product/{product_seq}` (GET) - p_seq로 입고 내역 목록 조회

#### 문제 3-2: 경로 파라미터 불일치
- **파일**: `fastapi/app/api/receive.py`
- **위치**: 171줄
- **문제**:
  ```python
  @router.post("/receive_seq/process")
  async def process_receive(receive_seq: int):
  ```
- **설명**: 경로에 `/receive_seq/`라는 리터럴 문자열이 포함되어 있음. 경로 파라미터로 사용하려면 `/{receive_seq}/process`로 수정 필요
- **영향**: 엔드포인트 접근 불가능
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전
  @router.post("/receive_seq/process")
  async def process_receive(receive_seq: int):
      rec_date_dt = datetime.now()
      sql = "UPDATE receive SET rec_date=%s WHERE rec_seq=%s"
      curs.execute(sql, (rec_date_dt, receive_seq))
  
  # 수정 후
  @router.post("/{receive_seq}/process")
  async def process_receive(receive_seq: int):
      rec_date_dt = datetime.now()
      sql = "UPDATE receive SET rec_date=%s WHERE rec_seq=%s"
      curs.execute(sql, (rec_date_dt, receive_seq))
  ```
  - 경로의 리터럴 문자열 `/receive_seq/`를 경로 파라미터 `/{receive_seq}/`로 변경
  - 이제 `/api/receives/{receive_seq}/process` 형태로 접근 가능

---

### 4. request.py

#### 문제 4-1: 경로 파라미터 불일치
- **파일**: `fastapi/app/api/request.py`
- **위치**: 187줄, 206줄
- **문제**:
  ```python
  @router.post("/request_seq/approve_manager")
  async def approve_request_manager(request_seq: int):
  
  @router.post("/request_seq/approve_director")
  async def approve_request_director(request_seq: int):
  ```
- **설명**: 경로에 `/request_seq/`라는 리터럴 문자열이 포함되어 있음. 경로 파라미터로 사용하려면 `/{request_seq}/approve_manager`, `/{request_seq}/approve_director`로 수정 필요
- **영향**: 엔드포인트 접근 불가능
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전 (187줄)
  @router.post("/request_seq/approve_manager")
  async def approve_request_manager(request_seq: int):
      req_manappdate_dt = datetime.now()
      sql = "UPDATE request SET req_manappdate=%s WHERE req_seq=%s"
      curs.execute(sql, (req_manappdate_dt, request_seq))
  
  # 수정 후 (187줄)
  @router.post("/{request_seq}/approve_manager")
  async def approve_request_manager(request_seq: int):
      req_manappdate_dt = datetime.now()
      sql = "UPDATE request SET req_manappdate=%s WHERE req_seq=%s"
      curs.execute(sql, (req_manappdate_dt, request_seq))
  
  # 수정 전 (206줄)
  @router.post("/request_seq/approve_director")
  async def approve_request_director(request_seq: int):
      req_dirappdate_dt = datetime.now()
      sql = "UPDATE request SET req_dirappdate=%s WHERE req_seq=%s"
      curs.execute(sql, (req_dirappdate_dt, request_seq))
  
  # 수정 후 (206줄)
  @router.post("/{request_seq}/approve_director")
  async def approve_request_director(request_seq: int):
      req_dirappdate_dt = datetime.now()
      sql = "UPDATE request SET req_dirappdate=%s WHERE req_seq=%s"
      curs.execute(sql, (req_dirappdate_dt, request_seq))
  ```
  - 두 엔드포인트 모두 경로의 리터럴 문자열 `/request_seq/`를 경로 파라미터 `/{request_seq}/`로 변경
  - 이제 다음과 같이 접근 가능:
    - `/api/requests/{request_seq}/approve_manager` (POST) - 팀장 결재
    - `/api/requests/{request_seq}/approve_director` (POST) - 이사 결재

---

### 5. purchase_item.py

#### 문제 5-1: 경로 파라미터 불일치
- **파일**: `fastapi/app/api/purchase_item.py`
- **위치**: 185줄
- **문제**:
  ```python
  @router.post("/{id}")
  async def update_purchase_item(
      b_seq: int = Form(...),  # 경로 파라미터를 Form으로 받음
  ```
- **설명**: 경로는 `/{id}`인데 함수 파라미터에 경로 파라미터가 정의되지 않고 Form으로만 받고 있음. `@router.post("/{purchase_item_seq}")` 형태로 경로 파라미터를 명시적으로 받아야 함
- **영향**: 경로 파라미터와 함수 파라미터 불일치로 혼란 가능
- **수정 필요**: ✅
- **해결 방법**:
  ```python
  # 수정 전
  @router.post("/{id}")
  async def update_purchase_item(
      b_seq: int = Form(...),
      br_seq: int = Form(...),
      u_seq: int = Form(...),
      p_seq: int = Form(...),
      b_price: int = Form(0),
      b_quantity: int = Form(1),
      b_date: str = Form(...),
      b_status: Optional[str] = Form(None),
  ):
      b_date_dt = datetime.fromisoformat(b_date.replace('Z', '+00:00'))
      sql = """
          UPDATE purchase_item 
          SET br_seq=%s, u_seq=%s, p_seq=%s, b_price=%s, b_quantity=%s, b_date=%s, b_status=%s 
          WHERE b_seq=%s
      """
      curs.execute(sql, (br_seq, u_seq, p_seq, b_price, b_quantity, b_date_dt, b_status, b_seq))
  
  # 수정 후
  @router.post("/{purchase_item_seq}")
  async def update_purchase_item(
      purchase_item_seq: int,  # 경로 파라미터로 받음
      br_seq: int = Form(...),
      u_seq: int = Form(...),
      p_seq: int = Form(...),
      b_price: int = Form(0),
      b_quantity: int = Form(1),
      b_date: str = Form(...),
      b_status: Optional[str] = Form(None),
  ):
      b_date_dt = datetime.fromisoformat(b_date.replace('Z', '+00:00'))
      sql = """
          UPDATE purchase_item 
          SET br_seq=%s, u_seq=%s, p_seq=%s, b_price=%s, b_quantity=%s, b_date=%s, b_status=%s 
          WHERE b_seq=%s
      """
      curs.execute(sql, (br_seq, u_seq, p_seq, b_price, b_quantity, b_date_dt, b_status, purchase_item_seq))
  ```
  - 경로 파라미터명을 `{id}`에서 `{purchase_item_seq}`로 변경
  - 함수 파라미터에서 `b_seq: int = Form(...)` 제거하고 `purchase_item_seq: int` 경로 파라미터 추가
  - SQL 쿼리의 WHERE 절에서 `purchase_item_seq` 사용
  - Form 데이터에서 `b_seq` 제거 (경로에서 받음)

---

## ✅ 정상 확인된 파일들

다음 파일들은 SQL SELECT 절과 인덱스 매핑이 정상적으로 일치함:

1. **users.py** - 모든 인덱스 매핑 정상
2. **user_auth_identities.py** - 모든 인덱스 매핑 정상
3. **branch.py** - 모든 인덱스 매핑 정상
4. **product.py** - 모든 인덱스 매핑 정상
5. **product_join.py** - 모든 인덱스 매핑 정상
6. **purchase_item_join.py** - 모든 인덱스 매핑 정상
7. **pickup_join.py** - 모든 인덱스 매핑 정상
8. **refund.py** - 모든 인덱스 매핑 정상
9. **refund_join.py** - 모든 인덱스 매핑 정상
10. **receive_join.py** - 모든 인덱스 매핑 정상
11. **request_join.py** - 모든 인덱스 매핑 정상
12. **maker.py** - 모든 인덱스 매핑 정상
13. **kind_category.py** - 모든 인덱스 매핑 정상
14. **color_category.py** - 모든 인덱스 매핑 정상
15. **size_category.py** - 모든 인덱스 매핑 정상
16. **gender_category.py** - 모든 인덱스 매핑 정상
17. **refund_reason_category.py** - 모든 인덱스 매핑 정상
18. **auth.py** - 모든 인덱스 매핑 정상 (소셜 로그인 엔드포인트만 사용)

---

## 📝 추가 확인 필요 사항

### 엔드포인트 경로 패턴 일관성

일부 파일에서 경로 파라미터를 사용할 때와 리터럴 문자열을 사용할 때의 일관성이 없음:

- `staff.py`: `/{id}`, `/staff_seq/profile_image` (혼용)
- `pickup.py`: `/{pickup_seq}`, `/pickup_seq/complete` (혼용)
- `receive.py`: `/{receive_seq}`, `/receive_seq/process` (혼용)
- `request.py`: `/{request_seq}`, `/request_seq/approve_manager` (혼용)

**권장사항**: 모든 경로 파라미터는 `/{param_name}` 형태로 통일

---

## 🔧 수정 우선순위

### 높음 (즉시 수정 필요)
1. ❌ **staff.py 문제 1-3**: DELETE 엔드포인트 중복 (서비스 동작 불가)
2. ❌ **pickup.py 문제 2-1**: GET 엔드포인트 중복 (서비스 동작 불가)
3. ❌ **receive.py 문제 3-1**: GET 엔드포인트 중복 (서비스 동작 불가)

### 중간 (기능 동작은 하지만 수정 권장)
5. ❌ **staff.py 문제 1-1**: 경로 파라미터 오류
6. ❌ **pickup.py 문제 2-2**: 경로 파라미터 오류
7. ❌ **receive.py 문제 3-2**: 경로 파라미터 오류
8. ❌ **request.py 문제 4-1**: 경로 파라미터 오류

### 낮음 (일관성을 위한 개선)
9. ❌ **staff.py 문제 1-2**: 경로 파라미터 명명 불일치
10. ❌ **purchase_item.py 문제 5-1**: 경로 파라미터 명명 불일치

---

## 📊 요약

- **전체 파일 수**: 24개
- **정상 파일 수**: 18개
- **문제 발견 파일 수**: 5개
- **총 문제 개수**: 9개
- **즉시 수정 필요**: 3개
- **수정 권장**: 4개
- **개선 권장**: 2개

---

## 📝 변경 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | AI Assistant | 최초 작성 - 전체 API 파일 컬럼명 및 인덱스 매핑 체크 완료 |
| 2026-01-01 | AI Assistant | 모든 문제점에 대한 구체적인 해결 방법 추가 |
| 2026-01-01 | AI Assistant | auth.py 불필요한 엔드포인트 삭제 (complete_registration, registration_status, check_registration_completed) |

---

**문서 버전**: 1.3  
**최종 수정일**: 2026-01-01  
**최종 수정자**: AI Assistant
