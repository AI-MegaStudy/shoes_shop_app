# PHP 업로드 및 테스트 도구

이 폴더에는 PHP 파일 업로드 관련 스크립트와 테스트 도구들이 포함되어 있습니다.

## 📁 파일 목록

### PHP 스크립트 (NAS에 업로드 필요)
- **`upload_image.php`** - 제품 이미지 업로드용 PHP 스크립트
  - 배치 위치: `/share/Web/upload_image.php`
  - 역할: 이미지 파일을 `/share/Web/images/`에 저장
  
- **`upload_model.php`** - GLB 모델 파일 업로드용 PHP 스크립트
  - 배치 위치: `/share/Web/upload_model.php`
  - 역할: GLB 파일을 `/share/Web/model/`에 저장

- **`check_phpinfo.php`** - PHP 웹서버 경로 확인용 스크립트
  - 배치 위치: `/share/Web/check_phpinfo.php`
  - 역할: DOCUMENT_ROOT 등 PHP 서버 정보 확인

### 테스트 스크립트
- **`test_upload_php.py`** - PHP 업로드 테스트 (FastAPI 경유)
  - 사용법: `python test_upload_php.py`
  - FastAPI → PHP → NAS 파일 저장 테스트

- **`test_upload_local.py`** - 로컬 파일 업로드 테스트
  - 사용법: `python test_upload_local.py`
  - FastAPI 서버 연결 및 업로드 테스트

- **`test_upload.py`** - 범용 업로드 테스트 스크립트
  - 사용법: `python test_upload.py <product_seq> <file_path> [model_name]`
  - 이미지 및 GLB 파일 업로드 지원

- **`test_upload_simple.sh`** - 간단한 curl 기반 테스트
  - 사용법: `./test_upload_simple.sh [product_seq] [image_path]`

### 문서
- **`README_PHP_PATH.md`** - PHP 웹서버 경로 찾기 가이드
  - QNAP NAS에서 DOCUMENT_ROOT 확인 방법
  - 경로 설정 가이드

## 🚀 사용 방법

### 1. PHP 파일 배치
```bash
# NAS의 /share/Web/ 디렉토리에 업로드
scp upload_image.php user@nas:/share/Web/
scp upload_model.php user@nas:/share/Web/
```

### 2. 테스트 실행
```bash
# FastAPI 서버 실행 후
cd fastapi/php_upload
python test_upload_php.py
```

## 📋 구조

```
fastapi/
├── php_upload/          # 이 폴더
│   ├── upload_image.php
│   ├── upload_model.php
│   ├── check_phpinfo.php
│   ├── test_upload_php.py
│   ├── test_upload_local.py
│   ├── test_upload.py
│   ├── test_upload_simple.sh
│   ├── README_PHP_PATH.md
│   └── README.md        # 이 파일
└── app/
    └── api/
        └── product.py   # FastAPI 업로드 엔드포인트
```

## ⚙️ 설정

### PHP 스크립트 설정
- 웹서버 URL: `https://cheng80.myqnapcloud.com`
- 이미지 저장 경로: `/share/Web/images/`
- 모델 저장 경로: `/share/Web/model/`

### FastAPI 설정
`fastapi/app/api/product.py`에서 다음 변수 확인:
- `PHP_UPLOAD_IMAGE_SCRIPT`: `https://cheng80.myqnapcloud.com/upload_image.php`
- `PHP_UPLOAD_MODEL_SCRIPT`: `https://cheng80.myqnapcloud.com/upload_model.php`

## 📝 참고사항

- PHP 파일은 NAS의 `/share/Web/` 디렉토리에 배치해야 합니다
- 이미지와 모델 파일은 각각 다른 PHP 스크립트로 처리됩니다
- DB 업데이트는 FastAPI가 담당합니다 (PHP는 파일 저장만)

