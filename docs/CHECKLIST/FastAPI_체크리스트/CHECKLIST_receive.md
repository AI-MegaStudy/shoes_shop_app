# Receive API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/receive.py`  
**경로**: `/api/receives`

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
| `rec_seq` | INT | ✅ | 입고 고유 ID(PK), AUTO_INCREMENT |
| `rec_quantity` | INT | | 입고 수량 (DEFAULT 0) |
| `rec_date` | DATETIME | | 입고 처리 일시 |
| `s_seq` | INT | ✅ | 입고 처리 직원 ID(FK) → staff.s_seq |
| `p_seq` | INT | ✅ | 입고 제품 ID(FK) → product.p_seq |
| `m_seq` | INT | ✅ | 제조사 ID(FK) → maker.m_seq |

**참고**: 
- 입고 처리 시 `product.p_stock` 업데이트 필요 (애플리케이션 로직)

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/receives` | [ ] |
| Read (단일) | `GET /api/receives/{receive_seq}` | [ ] |
| Read (제품별) | `GET /api/receives/{product_seq}` | [ ] |
| Create | `POST /api/receives` | [ ] |
| Update | `POST /api/receives/{id}` | [ ] |
| 입고 처리 | `POST /api/receives/receive_seq/process` | [ ] |
| Delete | `DELETE /api/receives/{receive_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

