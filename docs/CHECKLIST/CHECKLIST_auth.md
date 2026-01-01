# Auth API 체크리스트 (소셜 로그인 및 회원가입)

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/auth.py`  
**경로**: `/api`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

---

## 설명

소셜 로그인(Google, Kakao) 및 회원가입 완료 처리를 위한 특수 API입니다.

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| 소셜 로그인 (1단계) | `POST /api/auth/social/login` | [ ] |
| 회원가입 완료 (2단계) | `POST /api/users/{user_seq}/complete_registration` | [ ] |
| 회원가입 상태 확인 | `GET /api/users/{user_seq}/registration_status` | [ ] |

---

## 소셜 로그인 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `provider` | STRING | ✅ | 로그인 제공자 ('google', 'kakao') |
| `provider_subject` | STRING | ✅ | 제공자 고유 ID (구글: sub, 카카오: id) |
| `email` | STRING | | 이메일 주소 |
| `name` | STRING | | 이름 |
| `provider_issuer` | STRING | | 제공자 발급자 (iss) |

---

## 회원가입 완료 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `u_name` | STRING | | 이름 (수정 가능) |
| `u_phone` | STRING | ✅ | 전화번호 |
| `u_address` | STRING | | 주소 |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

