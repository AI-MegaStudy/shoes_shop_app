# Branch API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/branch.py`  
**경로**: `/api/branches`

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
| `br_seq` | INT | ✅ | 지점 고유 ID(PK), AUTO_INCREMENT |
| `br_name` | VARCHAR(100) | ✅ | 지점명 (UNIQUE) |
| `br_phone` | VARCHAR(30) | | 지점 전화번호 |
| `br_address` | VARCHAR(255) | | 지점 주소 |
| `br_lat` | DECIMAL(10,7) | | 지점 위도 |
| `br_lng` | DECIMAL(10,7) | | 지점 경도 |

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/branches` | [ ] |
| Read (단일) | `GET /api/branches/{branch_seq}` | [ ] |
| Create | `POST /api/branches` | [ ] |
| Update | `POST /api/branches/{branch_seq}` | [ ] |
| Delete | `DELETE /api/branches/{branch_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

