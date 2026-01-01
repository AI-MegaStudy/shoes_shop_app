# 📂 프로젝트 폴더 구조

**작성일**: 2025-12-31  
**작성자**: 김택권  
**목적**: 프로젝트 폴더 구조 및 각 폴더의 주요 기능 정리

---

## 📁 프로젝트 루트 구조

```
shoes_shop_app/
├── docs/           # 프로젝트 문서
├── fastapi/        # 백엔드 서버 (FastAPI)
├── images/         # 이미지 리소스
└── lib/            # Flutter 앱 소스 코드
```

---

## 📁 docs/

프로젝트 문서 및 데이터베이스 스키마 정의 파일

| 폴더/파일 | 주요 기능 |
|-----------|----------|
| `DATABASE_GUIDE.md` | 데이터베이스 사용법 가이드 |
| `DATABASE_SCHEMA.md` | 데이터베이스 스키마 상세 설명 |
| `PROJECT_STRUCTURE.md` | 프로젝트 폴더 구조 문서 (이 문서) |
| `database_schema.dbml` | 데이터베이스 스키마 DBML 정의 파일 |

---

## 📁 fastapi/

백엔드 서버 (FastAPI + MySQL)

### fastapi/app/

FastAPI 애플리케이션 메인 코드

| 폴더/파일 | 주요 기능 |
|-----------|----------|
| `main.py` | FastAPI 앱 진입점, 라우터 등록 |
| `api/` | REST API 엔드포인트 정의 |
| `database/` | MySQL 데이터베이스 연결 관리 |
| `TEST/` | API 테스트 및 더미 데이터 생성 스크립트 |
| `API_GUIDE.md` | API 사용 가이드 문서 |

#### fastapi/app/api/

REST API 엔드포인트 모듈

- **기본 CRUD API**: 15개 테이블에 대한 CRUD 작업
  - 사용자 관리: `users.py`, `user_auth_identities.py`, `auth.py`
  - 관리자/직원: `staff.py`, `branch.py`
  - 제품 관련: `product.py`, `maker.py`, `kind_category.py`, `color_category.py`, `size_category.py`, `gender_category.py`
  - 주문 관련: `purchase_item.py`, `pickup.py`, `refund.py`, `receive.py`, `request.py`, `refund_reason_category.py`
- **JOIN API**: 복잡한 조인 쿼리 (6개 API 그룹)
  - `product_join.py`, `purchase_item_join.py`, `pickup_join.py`, `refund_join.py`, `receive_join.py`, `request_join.py`

### fastapi/mysql/

MySQL 데이터베이스 초기화 및 관리 스크립트

| 폴더/파일 | 주요 기능 |
|-----------|----------|
| `shoes_shop_db_mysql_init_with_social.sql` | 데이터베이스 스키마 생성 SQL (소셜 로그인 포함) |
| `create_db_with_social.py` | 데이터베이스 초기화 Python 스크립트 |
| `check_dummy_data.py` | 더미 데이터 확인 스크립트 |

### fastapi/requirements.txt

Python 패키지 의존성 목록

---

## 📁 images/

이미지 리소스 폴더

| 폴더/파일 | 주요 기능 |
|-----------|----------|
| `dummy-profile-pic.png` | 기본 프로필 이미지 |
| `Nike_*/` | Nike 제품 이미지 (제품별 폴더) |
| `Newbalance_*/` | Newbalance 제품 이미지 (제품별 폴더) |

---

## 📁 lib/

Flutter 앱 소스 코드

### lib/ (루트 파일)

| 파일 | 주요 기능 |
|------|----------|
| `main.dart` | 앱 진입점, 초기화, 테마 설정, 라우팅 |
| `config.dart` | 전역 상수 (API URL, 라우트, UI 상수 등) |
| `firebase_options.dart` | Firebase 설정 (소셜 로그인용) |

### lib/core/

전역 저장소 관리 (GetStorage 기반)

| 주요 기능 |
|----------|
| 전역 데이터 저장 및 조회 |
| 저장소 컨텍스트 관리 |

### lib/custom/

커스텀 위젯 및 유틸리티 라이브러리

| 폴더 | 주요 기능 |
|------|----------|
| `*.dart` | 커스텀 위젯 (Button, Dialog, TextField, Card 등) |
| `external_util/` | 외부 라이브러리 래퍼 (네트워크, 저장소) |
| `util/` | 유틸리티 함수 (주소, 컬렉션, JSON, 네비게이션, 타이머, XML) |

### lib/model/

데이터 모델 (서버 API와 대응)

| 주요 기능 |
|----------|
| 사용자: `user.dart`, `user_auth_identity.dart` |
| 제품: `product.dart`, `maker.dart`, `kind_category.dart`, `color_category.dart`, `size_category.dart`, `gender_category.dart` (추가 예정: `product_join.dart`) |
| 주문: `purchase_item.dart`, `purchase_item_join.dart` |
| 수령/반품: `pickup.dart`, `refund.dart`, `receive.dart`, `request.dart`, `refund_reason_category.dart` (추가 예정: `pickup_join.dart`, `receive_join.dart`, `refund_join.dart`, `request_join.dart`) |
| 관리: `branch.dart`, `staff.dart` |

### lib/theme/

테마 관리 (라이트/다크 모드)

| 주요 기능 |
|----------|
| 테마 상태 관리 Provider |
| 색상 스킴 정의 (라이트/다크 모드) |
| 팔레트 컨텍스트 |

### lib/utils/

공용 유틸리티 함수

| 파일 | 주요 기능 |
|------|----------|
| `custom_common_util.dart` | API Base URL 관리, 공용 유틸리티 |
| `admin_tablet_utils.dart` | 태블릿 감지, 가로모드 고정 |
| `app_logger.dart` | 앱 로깅 유틸리티 |

### lib/view/

화면 (UI)

#### lib/view/user/

사용자 관련 화면

| 폴더 | 주요 기능 |
|------|----------|
| `auth/` | 로그인, 회원가입, 프로필 편집, 사용자 메뉴 |

#### lib/view/admin/

관리자 관련 화면

| 폴더 | 주요 기능 |
|------|----------|
| `auth/` | 관리자 로그인, 모바일 접근 차단, 주문 관리 |

#### lib/view/

공용 화면

| 파일 | 주요 기능 |
|------|----------|
| `home.dart` | 홈 화면 |

---

## 🗂️ 전체 폴더 구조 트리

```
shoes_shop_app/
├── docs/
│   ├── DATABASE_GUIDE.md
│   ├── DATABASE_SCHEMA.md
│   ├── PROJECT_STRUCTURE.md
│   └── database_schema.dbml
│
├── fastapi/
│   ├── app/
│   │   ├── main.py
│   │   ├── api/              # REST API 엔드포인트
│   │   ├── database/         # DB 연결 관리
│   │   ├── TEST/             # 테스트 스크립트
│   │   └── API_GUIDE.md
│   ├── mysql/                # DB 초기화 스크립트
│   ├── requirements.txt
│   └── venv/                 # Python 가상환경
│
├── images/
│   ├── dummy-profile-pic.png
│   ├── Nike_*/
│   └── Newbalance_*/
│
└── lib/
    ├── main.dart
    ├── config.dart
    ├── firebase_options.dart
    ├── core/                 # 전역 저장소
    ├── custom/               # 커스텀 위젯 및 유틸리티
    ├── model/                # 데이터 모델
    ├── theme/                # 테마 관리
    ├── utils/                # 공용 유틸리티
    └── view/                 # 화면 (UI)
        ├── user/
        ├── admin/
        ├── home.dart
        └── product_file_upload_view.dart
```

---

## 📝 주요 참고 문서

- `docs/DATABASE_GUIDE.md`: 데이터베이스 사용법
- `docs/DATABASE_SCHEMA.md`: 데이터베이스 스키마 상세
- `fastapi/app/API_GUIDE.md`: FastAPI 백엔드 API 사용 가이드

---

## 📝 변경 이력

### 2025-12-26 김택권
- **최초 작성**: 프로젝트 폴더 구조 문서 작성

### 2025-01-XX 김택권
- **문서 갱신**: docs, fastapi, images, lib 폴더 포함하여 전체 구조 정리
- 폴더 단위로 주요 기능 중심으로 재구성

---

**문서 버전**: 1.0  
**최종 수정일**: 2025-12-31  
**최종 수정자**: 김택권
