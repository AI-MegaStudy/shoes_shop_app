# Model 클래스

이 폴더에는 애플리케이션에서 사용하는 데이터 모델 클래스들이 정의되어 있습니다.

## 파일 목록

### user.dart
- **User**: 사용자 정보 모델 클래스
  - `user` 테이블 구조에 맞춤
  - 소셜 로그인 지원 버전
  - JSON 직렬화/역직렬화 지원 (`toJson()`, `fromJson()`)

### user_auth_identity.dart
- **UserAuthIdentity**: 사용자 인증 정보 모델 클래스
  - `user_auth_identities` 테이블 구조에 맞춤
  - 소셜 로그인 지원 버전
  - JSON 직렬화/역직렬화 지원 (`toJson()`, `fromJson()`)
  - `isSocialLogin` getter: 소셜 로그인 여부 확인

## 사용 방법

```dart
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/model/user_auth_identity.dart';

// User 객체 생성
final user = User(
  uSeq: 1,
  uEmail: 'user@example.com',
  uName: '홍길동',
  uPhone: '010-1234-5678',
);

// JSON으로 변환
final json = user.toJson();

// JSON에서 생성
final userFromJson = User.fromJson(json);
```

## 추가 모델

다른 테이블에 대한 모델이 필요하면 이 폴더에 추가하세요:
- `product.dart` - 제품 정보 모델
- `order.dart` - 주문 정보 모델
- 등등...

