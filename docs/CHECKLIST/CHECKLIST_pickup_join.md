# Pickup Join API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/pickup_join.py`  
**경로**: `/api/pickups`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

---

## 설명

수령과 관련된 모든 정보(구매 내역, 고객, 제품, 지점, 카테고리, 제조사)를 JOIN하여 조회하는 API입니다.

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| 수령 상세 조회 | `GET /api/pickups/{pickup_seq}/with_details` | [ ] |
| 수령 전체 상세 조회 | `GET /api/pickups/{pickup_seq}/full_detail` | [ ] |
| 고객별 수령 조회 | `GET /api/pickups/by_user/{user_seq}/with_details` | [ ] |
| 지점별 수령 조회 | `GET /api/pickups/by_branch/{branch_seq}/with_details` | [ ] |

---

## JOIN 테이블

- **with_details**: Pickup + PurchaseItem + User + Product + Branch (5테이블 JOIN)
- **full_detail**: Pickup + PurchaseItem + User + Product + Branch + 모든 카테고리 + Maker (10테이블 JOIN)

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

