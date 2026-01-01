# Refund API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/refund.py`  
**경로**: `/api/refunds`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

---

## 컬럼 설명

| 컬럼명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `ref_seq` | INT | ✅ | 반품 고유 ID(PK), AUTO_INCREMENT |
| `ref_date` | DATETIME | | 반품 처리 일시 |
| `ref_reason` | VARCHAR(255) | | 반품 사유 |
| `ref_re_seq` | INT | | 반품 사유 번호(FK) → refund_reason_category.ref_re_seq |
| `ref_re_content` | VARCHAR(255) | | 반품 사유 내용 |
| `u_seq` | INT | ✅ | 반품 요청 고객 ID(FK) → user.u_seq |
| `s_seq` | INT | ✅ | 반품 처리 직원 ID(FK) → staff.s_seq |
| `pic_seq` | INT | ✅ | 수령 ID(FK) → pickup.pic_seq |

**참고**: 
- 반품은 반드시 수령(pickup) 후에만 가능
- 모든 반품은 직원이 처리

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/refunds` | [ ] |
| Read (단일) | `GET /api/refunds/{refund_seq}` | [ ] |
| Read (고객별) | `GET /api/refunds/by_user/{user_seq}` | [ ] |
| Create | `POST /api/refunds` | [ ] |
| Update | `POST /api/refunds/{id}` | [ ] |
| 반품 처리 | `POST /api/refunds/{refund_seq}/process` | [ ] |
| Delete | `DELETE /api/refunds/{refund_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

