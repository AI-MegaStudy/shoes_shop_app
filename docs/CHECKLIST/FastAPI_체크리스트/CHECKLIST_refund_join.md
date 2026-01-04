# Refund Join API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/refund_join.py`  
**경로**: `/api/refunds`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | 유다원 |
| 작성일 | 2026.01.01 |
| 완료일 | 2025.12.29 |

---

## 설명

반품과 관련된 모든 정보(고객, 직원, 수령, 구매 내역, 제품, 지점, 카테고리, 제조사)를 JOIN하여 조회하는 API입니다.

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| 반품 상세 조회 | `GET /api/refunds/{refund_seq}/with_details` | [O] |
| 반품 전체 상세 조회 | `GET /api/refunds/{refund_seq}/full_detail` | [O] |
| 고객별 반품 조회 | `GET /api/refunds/by_user/{user_seq}/with_details` | [O] |
| 직원별 반품 조회 | `GET /api/refunds/by_staff/{staff_seq}/with_details` | [O] |

---

## JOIN 테이블

- **with_details**: Refund + User + Staff + Pickup + PurchaseItem + Product + Branch (7테이블 JOIN)
- **full_detail**: Refund + User + Staff + Pickup + PurchaseItem + Product + Branch + 모든 카테고리 + Maker (12테이블 JOIN)

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |
| 2026-01-01 | 유다원 | 완료한 작업 체크 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

