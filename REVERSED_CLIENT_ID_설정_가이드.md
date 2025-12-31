# REVERSED_CLIENT_ID 설정 가이드

## 🔍 현재 상황
- `GoogleService-Info.plist` 파일에 `REVERSED_CLIENT_ID` 키가 없음
- `Info.plist`에는 이미 URL Scheme이 설정되어 있음: `com.googleusercontent.apps.627897695803-lt54b827993fq7o20avm2b7jocn5ovee`

## ⚠️ 중요
`REVERSED_CLIENT_ID`는 Google Cloud Console에서 **iOS용 OAuth 클라이언트 ID**를 생성할 때 자동으로 생성됩니다.
Firebase Console에서 다운로드한 `GoogleService-Info.plist`에는 OAuth 클라이언트 ID가 생성되지 않으면 `REVERSED_CLIENT_ID`가 포함되지 않습니다.

## ✅ 해결 방법

### 방법 1: Google Cloud Console에서 OAuth 클라이언트 ID 확인/생성 (권장)

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com/ 접속
   - 프로젝트 선택: **shoes-shop-app-28f42**

2. **OAuth 클라이언트 ID 확인**
   - 왼쪽 메뉴: **"API 및 서비스"** → **"사용자 인증 정보"**
   - **"OAuth 2.0 클라이언트 ID"** 섹션 확인
   - iOS용 클라이언트 ID가 있는지 확인
   - 클라이언트 ID 예시: `627897695803-lt54b827993fq7o20avm2b7jocn5ovee.apps.googleusercontent.com`

3. **없으면 생성**
   - **"사용자 인증 정보 만들기"** → **"OAuth 클라이언트 ID"** 선택
   - **애플리케이션 유형**: iOS 선택
   - **이름**: Shoes Shop App iOS (또는 원하는 이름)
   - **번들 ID**: `com.tj.shoesShopApp`
   - **"만들기"** 클릭
   - 생성된 **클라이언트 ID** 복사

4. **REVERSED_CLIENT_ID 계산**
   - 클라이언트 ID: `627897695803-lt54b827993fq7o20avm2b7jocn5ovee.apps.googleusercontent.com`
   - REVERSED_CLIENT_ID: `com.googleusercontent.apps.627897695803-lt54b827993fq7o20avm2b7jocn5ovee`
   - (클라이언트 ID의 `.apps.googleusercontent.com` 부분을 `com.googleusercontent.apps.`로 바꾸고 나머지는 그대로)

5. **GoogleService-Info.plist에 REVERSED_CLIENT_ID 추가**
   ```xml
   <key>REVERSED_CLIENT_ID</key>
   <string>com.googleusercontent.apps.627897695803-lt54b827993fq7o20avm2b7jocn5ovee</string>
   ```

6. **Firebase Console에서 다시 다운로드** (OAuth 클라이언트 ID가 생성된 후)
   - Firebase Console → 프로젝트 설정 → iOS 앱
   - **"GoogleService-Info.plist 다운로드"** 클릭
   - 이번에는 `REVERSED_CLIENT_ID`가 포함되어 있을 것입니다

### 방법 2: Info.plist의 값 사용 (임시 해결책)

현재 `Info.plist`에 이미 값이 있으므로, GoogleService-Info.plist에 수동으로 추가할 수 있습니다:

```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.627897695803-lt54b827993fq7o20avm2b7jocn5ovee</string>
```

하지만 이 방법은 **권장되지 않습니다**. Google Cloud Console에서 OAuth 클라이언트 ID를 제대로 생성하고 Firebase Console에서 다시 다운로드하는 것이 좋습니다.

## 📝 확인 체크리스트

- [ ] Google Cloud Console에서 iOS용 OAuth 클라이언트 ID 생성/확인
- [ ] Firebase Console에서 GoogleService-Info.plist 다시 다운로드
- [ ] REVERSED_CLIENT_ID가 포함되어 있는지 확인
- [ ] Info.plist의 CFBundleURLSchemes가 REVERSED_CLIENT_ID와 일치하는지 확인

## 🔗 참고 링크

- Google Cloud Console: https://console.cloud.google.com/
- Firebase Console: https://console.firebase.google.com/
- 프로젝트: shoes-shop-app-28f42
- 번들 ID: com.tj.shoesShopApp

