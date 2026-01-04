# Branch API 체크리스트

**작성일**: 2026-01-03 
**작성자**: 이광태  
**파일**: `fastapi/app/api/chatting.py`  
**경로**: `/api/chatting`

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
| `chatting_seq` | INT | ✅ | 쳇팅 고유 ID(PK), AUTO_INCREMENT |
| `u_seq` | INT | ✅ | 유저 (UNIQUE) |
| `fb_doc_id` | VARCHAR(30) | | firebase doc id|
| `s_seq` | INT | | Staff ID |
| `created_at` | timestamp | | 생성날짜 |
| `is_closed` | bool | | 문제해결여부 |

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/chatting` | [ ] |
| Read (단일) | `GET /api/chatting/by_user_seq` | [ ] |
| Read (단일) | `GET /api/chatting/{chatting_seq}` | [ ] |
| Create | `POST /api/chatting` | [ ] |
| Update | `POST /api/chatting{chatting_seq}` | [ ] |
| Delete | `DELETE /api/chatting/{chatting_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |
| 2026-01-03 | 이광태 | 기본 CRUD |
| 2026-01-04 | 이광태 | by_user_seq 펑션추가|

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-04 
**최종 수정자**: 이광태

