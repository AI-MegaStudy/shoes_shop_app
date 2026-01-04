# Pickup API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/pickup.py`  
**경로**: `/api/pickups`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | 이예은 |
| 작성일 | 26-01-04 |
| 완료일 | 26-01-04 |

---

## 컬럼 설명

| 컬럼명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `pic_seq` | INT | ✅ | 수령 고유 ID(PK), AUTO_INCREMENT |
| `b_seq` | INT | ✅ | 구매 ID(FK) → purchase_item.b_seq |
| `u_seq` | INT | ✅ | 고객 번호(FK) → user.u_seq |
| `created_at` | DATETIME | ✅ | 수령 완료 일시 (DEFAULT CURRENT_TIMESTAMP) |

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/pickups` | [ ] |
| Read (단일) | `GET /api/pickups/{pickup_seq}` | [ ] |
| Read (구매별) | `GET /api/pickups/{purchase_seq}` | [ ] |
| Create | `POST /api/pickups` | [ ] |
| Update | `POST /api/pickups/{id}` | [ ] |
| 수령 완료 처리 | `POST /api/pickups/pickup_seq/complete` | [ ] |
| Delete | `DELETE /api/pickups/{pickup_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

