# Product API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/product.py`  
**경로**: `/api/products`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | 이광태|
| 작성일 | 2026-01-01|
| 완료일 | 2026-01-04|

---

## 컬럼 설명

| 컬럼명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `p_seq` | INT | ✅ | 제품 고유 ID(PK), AUTO_INCREMENT |
| `kc_seq` | INT | ✅ | 제품 종류 카테고리 ID(FK) → kind_category.kc_seq |
| `cc_seq` | INT | ✅ | 제품 색상 카테고리 ID(FK) → color_category.cc_seq |
| `sc_seq` | INT | ✅ | 제품 사이즈 카테고리 ID(FK) → size_category.sc_seq |
| `gc_seq` | INT | ✅ | 제품 성별 카테고리 ID(FK) → gender_category.gc_seq |
| `m_seq` | INT | ✅ | 제조사 ID(FK) → maker.m_seq |
| `p_name` | VARCHAR(255) | | 제품명 |
| `p_price` | INT | | 제품 가격 (DEFAULT 0) |
| `p_stock` | INT | ✅ | 중앙 재고 수량 (DEFAULT 0) |
| `p_image` | VARCHAR(255) | | 제품 이미지 경로 |
| `p_description` | TEXT | | 제품 설명 |
| `created_at` | DATETIME | ✅ | 제품 등록일자 (DEFAULT CURRENT_TIMESTAMP) |

**제약조건**:
- UNIQUE: `(cc_seq, sc_seq, m_seq)` - 같은 색상, 사이즈, 제조사 조합은 중복 불가

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/products` | [ ] |
| Read (단일) | `GET /api/products/{product_seq}` | [ ] |
| Read (제조사별) | `GET /api/products/by_maker/{maker_seq}` | [ ] |
| Create | `POST /api/products` | [ ] |
| Update | `POST /api/products/{product_seq}` | [ ] |
| 재고 수정 | `POST /api/products/{product_seq}/stock` | [ ] |
| 파일 업로드 | `POST /api/products/{product_seq}/upload_file` | [ ] |
| 파일 정보 조회 | `GET /api/products/{product_seq}/file_info` | [ ] |
| 파일 다운로드 | `GET /api/products/{product_seq}/file` | [ ] |
| Delete | `DELETE /api/products/{product_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |
| 2026-01-01 | 이광태 | 프로던트 기본 CRUD 작성 |
| 2026-01-02 | 이광태 | 프로덕트 search 기능 및 상품조회 group by 작성|
| 2026-01-03 | 이광태 | 로그인 후 최초페이지 group by 컬러,상품명으로 나오게 함. 몇몇 오류수정 |
---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-04  
**최종 수정자**: 이광태

