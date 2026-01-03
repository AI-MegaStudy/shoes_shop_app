# Maker API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/maker.py`  
**경로**: `/api/makers`

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
| `m_seq` | INT | ✅ | 제조사 고유 ID(PK), AUTO_INCREMENT |
| `m_name` | VARCHAR(255) | ✅ | 제조사명 (UNIQUE) |
| `m_phone` | VARCHAR(30) | | 제조사 전화번호 |
| `m_address` | VARCHAR(255) | | 제조사 주소 |

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/makers` | [ ] |
| Read (단일) | `GET /api/makers/{maker_seq}` | [ ] |
| Create | `POST /api/makers` | [ ] |
| Update | `POST /api/makers/{id}` | [ ] |
| Delete | `DELETE /api/makers/{maker_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

