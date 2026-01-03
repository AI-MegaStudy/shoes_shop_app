# Kind Category API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/kind_category.py`  
**경로**: `/api/kind_categories`

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
| `kc_seq` | INT | ✅ | 종류 카테고리 ID(PK), AUTO_INCREMENT |
| `kc_name` | VARCHAR(100) | ✅ | 종류명 (UNIQUE, 예: 러닝화, 스니커즈, 부츠 등) |

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/kind_categories` | [ ] |
| Read (단일) | `GET /api/kind_categories/{kind_category_seq}` | [ ] |
| Create | `POST /api/kind_categories` | [ ] |
| Update | `POST /api/kind_categories/{id}` | [ ] |
| Delete | `DELETE /api/kind_categories/{kind_category_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

