# Users API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/users.py`  
**경로**: `/api/users`

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
| `u_seq` | INT | ✅ | 고객 고유 ID(PK), AUTO_INCREMENT |
| `u_email` | VARCHAR(255) | ✅ | 고객 이메일 (UNIQUE, 로컬/소셜 모두 필수) |
| `u_name` | VARCHAR(255) | ✅ | 고객 이름 |
| `u_phone` | VARCHAR(30) | | 고객 전화번호 (UNIQUE, 선택 사항) |
| `u_image` | MEDIUMBLOB | | 고객 프로필 이미지 |
| `u_address` | VARCHAR(255) | | 고객 주소 |
| `created_at` | DATETIME | ✅ | 고객 가입일자 (DEFAULT CURRENT_TIMESTAMP) |
| `u_quit_date` | DATETIME | | 고객 탈퇴일자 |

**참고**: 
- `u_id`, `u_password` 필드는 제거됨 (소셜 로그인 지원)
- 인증 정보는 `user_auth_identities` 테이블에서 관리

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/users` | [O] |
| Read (단일) | `GET /api/users/{user_seq}` | [O] |
| Create | `POST /api/users` (이미지 필수) | [O] |
| Update (이미지 제외) | `POST /api/users/{user_seq}` | [O] |
| Update (이미지 포함) | `POST /api/users/{user_seq}/with_image` | [O] |
| 이미지 조회 | `GET /api/users/{user_seq}/profile_image` | [O] |
| 이미지 삭제 | `DELETE /api/users/{user_seq}/profile_image` | [O] |
| Delete | `DELETE /api/users/{user_seq}` | [O] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |
| 2026-01-01 | 김택권 | 완표 체크 |
---

**문서 버전**: 1.1  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

