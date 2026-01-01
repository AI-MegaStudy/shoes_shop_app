# Request API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/request.py`  
**경로**: `/api/requests`

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
| `req_seq` | INT | ✅ | 발주/품의 고유 ID(PK), AUTO_INCREMENT |
| `req_date` | DATETIME | | 발주 요청 일시 |
| `req_content` | TEXT | | 발주 내용 |
| `req_quantity` | INT | | 발주 수량 (DEFAULT 0) |
| `req_manappdate` | DATETIME | | 팀장 결재 일시 |
| `req_dirappdate` | DATETIME | | 이사 결재 일시 |
| `s_seq` | INT | ✅ | 발주 요청 직원 ID(FK) → staff.s_seq |
| `p_seq` | INT | ✅ | 발주 제품 ID(FK) → product.p_seq |
| `m_seq` | INT | ✅ | 제조사 ID(FK) → maker.m_seq |
| `s_superseq` | INT | | 승인자 직원 ID (논리적 참조, FK 없음) |

**참고**: 
- 발주 프로세스: 직원 발주 요청 → 팀장 결재 → 이사 결재

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/requests` | [ ] |
| Read (단일) | `GET /api/requests/{request_seq}` | [ ] |
| Create | `POST /api/requests` | [ ] |
| Update | `POST /api/requests/{id}` | [ ] |
| 팀장 결재 | `POST /api/requests/request_seq/approve_manager` | [ ] |
| 이사 결재 | `POST /api/requests/request_seq/approve_director` | [ ] |
| Delete | `DELETE /api/requests/{request_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

