# Request Join API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/request_join.py`  
**경로**: `/api/requests`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

---

## 설명

발주와 관련된 모든 정보(직원, 제품, 제조사, 카테고리)를 JOIN하여 조회하는 API입니다.

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| 발주 상세 조회 | `GET /api/requests/{request_seq}/with_details` | [ ] |
| 발주 전체 상세 조회 | `GET /api/requests/{request_seq}/full_detail` | [ ] |
| 직원별 발주 조회 | `GET /api/requests/by_staff/{staff_seq}/with_details` | [ ] |
| 상태별 발주 조회 | `GET /api/requests/by_status` | [ ] |
| 제품별 발주 조회 | `GET /api/requests/by_product/{product_seq}/with_details` | [ ] |
| 제조사별 발주 조회 | `GET /api/requests/by_maker/{maker_seq}/with_details` | [ ] |

---

## JOIN 테이블

- **with_details**: Request + Staff + Product + Maker (4테이블 JOIN)
- **full_detail**: Request + Staff + Product + Maker + 모든 카테고리 (9테이블 JOIN)

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

