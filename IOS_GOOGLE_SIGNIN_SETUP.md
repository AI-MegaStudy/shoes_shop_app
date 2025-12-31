# iOS Google Sign-In 설정 가이드 (간단 버전)

## 🔍 현재 문제
- `GoogleService-Info.plist` 파일에 `REVERSED_CLIENT_ID` 키가 없음
- 이로 인해 iOS에서 Google Sign-In이 작동하지 않음

## ✅ 해결 방법 (5단계)

### 1단계: Firebase Console 접속
1. 브라우저에서 [Firebase Console](https://console.firebase.google.com/) 접속
2. Google 계정으로 로그인
3. 프로젝트 선택: **shoes-shop-app-28f42** (또는 해당 프로젝트)

### 2단계: iOS 앱 확인 및 GoogleService-Info.plist 다운로드
1. Firebase Console에서 **왼쪽 상단 톱니바퀴 아이콘** (⚙️) 클릭 → **"프로젝트 설정"** 선택
2. **"내 앱"** 섹션에서 iOS 앱 확인
   - 번들 ID: `com.tj.shoesShopApp`
   - 앱이 없다면 → **"iOS 앱 추가"** 또는 **"iOS 아이콘"** 클릭 후 앱 등록
3. **"GoogleService-Info.plist 다운로드"** 버튼 클릭
4. 파일이 다운로드됨 (보통 `~/Downloads/GoogleService-Info.plist`)

### 3단계: GoogleService-Info.plist 파일 교체
터미널에서 실행:
```bash
# 1. 다운로드한 파일을 프로젝트 폴더로 복사
cp ~/Downloads/GoogleService-Info.plist ios/Runner/

# 2. REVERSED_CLIENT_ID 확인 (값이 출력되어야 함)
/usr/libexec/PlistBuddy -c "Print :REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist
```

**예상 출력 예시:**
```
com.googleusercontent.apps.627897695803-lt54b827993fq7o20avm2b7jocn5ovee
```

### 4단계: Info.plist의 URL Scheme 확인 및 수정
1. `ios/Runner/Info.plist` 파일 열기
2. `CFBundleURLSchemes` 배열 찾기 (약 59번째 줄)
3. 위에서 확인한 `REVERSED_CLIENT_ID` 값과 일치하는지 확인
4. 다르면 수정

**현재 Info.plist 값 (확인 필요):**
```xml
<string>com.googleusercontent.apps.627897695803-lt54b827993fq7o20avm2b7jocn5ovee</string>
```

**REVERSED_CLIENT_ID와 일치해야 합니다!**

### 5단계: Xcode에서 파일 추가 확인
1. Xcode 프로젝트 열기:
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ 주의: `.xcworkspace` 파일을 열어야 합니다 (`.xcodeproj` 아님)

2. 파일 확인:
   - 왼쪽 프로젝트 네비게이터에서 `GoogleService-Info.plist` 파일이 있는지 확인
   - 파일을 선택하고 오른쪽 패널에서 **"Target Membership"** → **"Runner"** 체크 확인

3. 파일이 없다면 추가:
   - 왼쪽 프로젝트 네비게이터에서 **"Runner"** 폴더 우클릭
   - **"Add Files to Runner..."** 선택
   - `GoogleService-Info.plist` 파일 선택
   - ✅ **"Copy items if needed"** 체크
   - ✅ **"Runner"** 타겟 체크
   - **"Add"** 클릭

## 🧪 테스트
1. 앱 재빌드:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter run
   ```

2. 구글 로그인 버튼 클릭 → 정상 작동 확인

## ⚠️ 주의사항
- **iOS 시뮬레이터에서는 Google Sign-In이 제한적으로 작동할 수 있습니다**
- 실제 iOS 기기에서 테스트하는 것이 가장 확실합니다
- `REVERSED_CLIENT_ID`는 클라이언트 ID를 역순으로 한 값입니다

## 🔗 참고 링크
- Firebase Console: https://console.firebase.google.com/
- 프로젝트: shoes-shop-app-28f42
- 번들 ID: com.tj.shoesShopApp

