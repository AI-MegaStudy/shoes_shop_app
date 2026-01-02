# TEST 디렉토리 스크립트 가이드

## 📋 유지 스크립트 (2개)

### 1. `create_dummy_data.py` ⭐ 필수
**용도**: 더미 데이터 생성 (메인 스크립트)
**사용법**:
```bash
python3.10 create_dummy_data.py              # 전체 데이터 생성
python3.10 create_dummy_data.py --products-only  # 제품만 재생성
```
**설명**: 
- 모든 테이블의 더미 데이터를 생성
- 고정 시드(42)를 사용하여 재현 가능한 데이터 생성
- 날짜 일관성 보장 (수령일 > 주문일, 반품일 > 픽업일)

### 2. `audit_detailed_values.py` ⭐ 필수
**용도**: 상세 값 검수 (레코드 수 + 모든 컬럼 값 비교)
**사용법**:
```bash
python3.10 audit_detailed_values.py
```
**설명**:
- 레코드 수뿐만 아니라 각 컬럼 값도 비교
- 직원, 고객, 제품의 상세 정보 검수
- 변경된 값 표시
- 기대값과 실제값 비교

---

## 📊 스크립트 사용 워크플로우

### 일반적인 사용 순서:
1. **더미 데이터 생성**
   ```bash
   python3.10 create_dummy_data.py
   ```

2. **상세 값 검수**
   ```bash
   python3.10 audit_detailed_values.py
   ```

### 제품만 재생성하는 경우:
```bash
python3.10 create_dummy_data.py --products-only
python3.10 audit_detailed_values.py  # 검수
```

---

## 🔍 검수 항목

### `audit_detailed_values.py`가 확인하는 항목:
- ✅ 레코드 수 비교
- ✅ 모든 컬럼 값 비교
- ✅ 직원 정보 (이름, 직급, 전화번호, 상급자)
- ✅ 고객 정보 (이름, 전화번호, 주소, 탈퇴일)
- ✅ 제품 정보 (제품명별 개수, 가격 범위, 재고)

---

## 📝 참고사항

- 모든 스크립트는 고정 시드(42)를 사용하여 재현 가능한 데이터 생성
- 날짜 일관성은 자동으로 보장됨 (수정 불필요)
- 기대값 = `create_dummy_data.py`에 정의된 값
- 기대값은 레코드 수뿐만 아니라 컬럼 값도 포함

