# Product Join API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/product_join.py`  
**경로**: `/api/products`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

---

## 설명

제품과 관련된 모든 카테고리 및 제조사 정보를 JOIN하여 조회하는 API입니다.

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| 제품 전체 상세 조회 | `GET /api/products/{product_seq}/full_detail` | [ ] |
| 제품 목록 + 카테고리 | `GET /api/products/with_categories` | [ ] |
| 제조사별 제품 + 카테고리 | `GET /api/products/by_maker/{maker_seq}/with_categories` | [ ] |
| 카테고리별 제품 조회 | `GET /api/products/by_category` | [ ] |

---

## JOIN 테이블

- Product + KindCategory + ColorCategory + SizeCategory + GenderCategory + Maker (6테이블 JOIN)

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

