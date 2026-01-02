# User Auth Identities API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/user_auth_identities.py`  
**경로**: `/api/user_auth_identities`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | 김택권 |
| 작성일 | 2026.01.01 |
| 완료일 | 2026.01.01 |

---

## 컬럼 설명

| 컬럼명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `auth_seq` | INT | ✅ | 인증 수단 고유 ID(PK), AUTO_INCREMENT |
| `u_seq` | INT | ✅ | 고객 번호(FK) → user.u_seq |
| `provider` | VARCHAR(50) | ✅ | 로그인 제공자 (local, google, kakao) |
| `provider_subject` | VARCHAR(255) | ✅ | 제공자 고유 식별자 (로컬: 이메일, 구글: sub, 카카오: id) |
| `provider_issuer` | VARCHAR(255) | | 제공자 발급자 (구글 iss 등) |
| `email_at_provider` | VARCHAR(255) | | 제공자에서 받은 이메일 |
| `password` | VARCHAR(255) | | 로컬 로그인 비밀번호 (로컬만 사용) |
| `created_at` | DATETIME | ✅ | 생성일자 (DEFAULT CURRENT_TIMESTAMP) |
| `last_login_at` | DATETIME | | 마지막 로그인 일시 |

**제약조건**:
- UNIQUE: `(provider, provider_subject)`
- FOREIGN KEY: `u_seq` → `user.u_seq` (CASCADE)

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/user_auth_identities` | [O] |
| Read (단일) | `GET /api/user_auth_identities/{auth_seq}` | [O] |
| Read (사용자별) | `GET /api/user_auth_identities/user/{user_seq}` | [O] |
| Read (제공자별) | `GET /api/user_auth_identities/provider/{provider}` | [O] |
| Create | `POST /api/user_auth_identities` | [O] |
| Update | `POST /api/user_auth_identities/{auth_seq}` | [O] |
| 로그인 시간 업데이트 | `POST /api/user_auth_identities/{auth_seq}/update_login_time` | [O] |
| Delete | `DELETE /api/user_auth_identities/{auth_seq}` | [O] |

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

