# Staff API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/staff.py`  
**경로**: `/api/staffs`

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
| `s_seq` | INT | ✅ | 직원 고유 ID(PK), AUTO_INCREMENT |
| `s_id` | VARCHAR(50) | ✅ | 직원 로그인 ID (UNIQUE) |
| `br_seq` | INT | ✅ | 소속 지점 ID(FK) → branch.br_seq |
| `s_password` | VARCHAR(255) | ✅ | 직원 비밀번호(해시) |
| `s_name` | VARCHAR(255) | ✅ | 직원명 |
| `s_phone` | VARCHAR(30) | ✅ | 직원 전화번호 (UNIQUE) |
| `s_rank` | VARCHAR(100) | | 직원 직급 |
| `s_image` | MEDIUMBLOB | | 직원 프로필 이미지 |
| `s_superseq` | INT | | 상급자 직원 ID (논리적 참조, FK 없음) |
| `created_at` | DATETIME | ✅ | 생성일자 (DEFAULT CURRENT_TIMESTAMP) |
| `s_quit_date` | DATETIME | | 직원 탈퇴 일자 |

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/staffs` | [ ] |
| Read (단일) | `GET /api/staffs/{staff_seq}` | [ ] |
| Read (지점별) | `GET /api/staffs/by_branch/{branch_seq}` | [ ] |
| Create | `POST /api/staffs` (이미지 필수) | [ ] |
| Update (이미지 제외) | `POST /api/staffs/{id}` | [ ] |
| Update (이미지 포함) | `POST /api/staffs/{id}/with_image` | [ ] |
| 이미지 조회 | `GET /api/staffs/staff_seq/profile_image` | [ ] |
| 이미지 삭제 | `DELETE /api/staffs/{staff_seq}` (이미지 삭제) | [ ] |
| Delete | `DELETE /api/staffs/{staff_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

