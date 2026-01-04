# detail_view.dart 쿼리 개선 비교 문서

## 개요
`lib/view/user/product/detail_view.dart` 파일의 데이터 로딩 방식 개선에 따른 쿼리 변경 사항을 정리한 문서입니다.

**개선 일자**: 2026-01-05  
**개선 목적**: 존재하는 색상/사이즈만 표시하도록 필터링 로직 추가

---

## 1. 카테고리 로드 쿼리

### 1.1 기존 방식

```dart
Future<void> initializedData() async {
  // Gender Categories
  String _url = mainUrl + "/gender_categories";
  var url = Uri.parse(_url);
  var response = await http.get(url, headers: {});
  var jsonData = json.decode(utf8.decode(response.bodyBytes));
  genderList.addAll(jsonData["results"].map((d) => GenderCategory.fromJson(d)).toList());

  // Color Categories
  _url = mainUrl + "/color_categories";
  url = Uri.parse(_url);
  response = await http.get(url, headers: {});
  jsonData = json.decode(utf8.decode(response.bodyBytes));
  colorList.addAll(jsonData["results"].map((d) => ColorCategory.fromJson(d)).toList());
  selectedColor = colorList.indexWhere((f) => f.cc_seq == product!.cc_seq);

  // Size Categories
  _url = mainUrl + "/size_categories";
  url = Uri.parse(_url);
  response = await http.get(url, headers: {});
  jsonData = json.decode(utf8.decode(response.bodyBytes));
  sizeList.addAll(jsonData["results"].map((d) => SizeCategory.fromJson(d)).toList());

  await getProduct("init");
}
```

**쿼리:**
- `GET /api/gender_categories`
- `GET /api/color_categories`
- `GET /api/size_categories`

**특징:**
- 모든 카테고리 값을 로드하여 리스트에 저장
- 제품에 존재하지 않는 옵션도 포함됨

---

### 1.2 새로운 방식

```dart
Future<void> initializedData() async {
  // 1. 카테고리 목록 로드 (전체)
  await _loadCategories();

  // 2. 같은 제품명의 모든 색상별 제품 조회
  await _loadAllColorProducts();

  // 3. 실제 존재하는 옵션만 필터링
  _updateAvailableOptions();

  // 4. 초기 선택값 설정
  _setInitialSelections();

  // 5. 3D 뷰어 데이터 구성
  _build3DViewerData();

  // 6. 초기 제품 정보 업데이트
  await getProduct("init");
}

/// 카테고리 목록 로드 (전체)
Future<void> _loadCategories() async {
  // Gender Categories
  var url = Uri.parse("$mainUrl/gender_categories");
  var response = await http.get(url, headers: {});
  var jsonData = json.decode(utf8.decode(response.bodyBytes));
  _genderCategories = (jsonData["results"] as List)
      .map((d) => GenderCategory.fromJson(d))
      .toList();

  // Color Categories
  url = Uri.parse("$mainUrl/color_categories");
  response = await http.get(url, headers: {});
  jsonData = json.decode(utf8.decode(response.bodyBytes));
  _colorCategories = (jsonData["results"] as List)
      .map((d) => ColorCategory.fromJson(d))
      .toList();

  // Size Categories
  url = Uri.parse("$mainUrl/size_categories");
  response = await http.get(url, headers: {});
  jsonData = json.decode(utf8.decode(response.bodyBytes));
  _sizeCategories = (jsonData["results"] as List)
      .map((d) => SizeCategory.fromJson(d))
      .toList();
}
```

**쿼리:**
- `GET /api/gender_categories`
- `GET /api/color_categories`
- `GET /api/size_categories`

**변경사항:**
- 문자열 연결 방식 변경 (`+` → `$` 보간)
- 변수명 변경 (`genderList` → `_genderCategories`, `colorList` → `_colorCategories`, `sizeList` → `_sizeCategories`)
- 함수 분리 (`_loadCategories()`)

---

## 2. 제품 조회 쿼리

### 2.1 기존 방식

**초기화 시:**
```dart
// 카테고리만 로드하고 바로 getProduct("init") 호출
await getProduct("init");
```

**getProduct() 함수:**
```dart
Future<void> getProduct(String type) async {
  if (product!.p_seq == -1) {
    // 색상만 지정하여 조회
    String _url = mainUrl + "/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}";
    
    final url = Uri.parse(_url);
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    if (jsonData != null && jsonData["results"].length > 0) {
      product = Product.fromJson(jsonData['results'][0]);
      selectedGender = genderList.indexWhere((f) => f.gc_seq == product!.gc_seq);
    }
  } else {
    // 색상+사이즈+성별 모두 지정하여 조회
    String _url = mainUrl + "/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}&sc_seq=${product!.sc_seq}&gc_seq=${product!.gc_seq}";
    
    final url = Uri.parse(_url);
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    if (jsonData != null && jsonData["results"].length > 0) {
      product = Product.fromJson(jsonData['results'][0]);
      selectedGender = genderList.indexWhere((f) => f.gc_seq == product!.gc_seq);
      isExist = true;
    } else {
      isExist = false;
      Get.snackbar("알림", "죄송합니다. 선택한 ${type}의 제품이 존재 하지 않습니다. ", backgroundColor: Colors.blue[200]);
    }
  }
  setState(() {});
}
```

**쿼리:**
- `GET /api/products/getBySeqs/?m_seq={m_seq}&p_name={p_name}&cc_seq={cc_seq}` (p_seq == -1인 경우)
- `GET /api/products/getBySeqs/?m_seq={m_seq}&p_name={p_name}&cc_seq={cc_seq}&sc_seq={sc_seq}&gc_seq={gc_seq}` (일반 경우)

**특징:**
- 선택된 옵션에 따라 개별적으로 제품 조회
- 존재하지 않는 옵션 선택 시 스넥바로 알림

---

### 2.2 새로운 방식

**초기화 시:**
```dart
// 1. 카테고리 목록 로드 (전체)
await _loadCategories();

// 2. 같은 제품명의 모든 색상별 제품 조회 (새로 추가!)
await _loadAllColorProducts();

// 3. 실제 존재하는 옵션만 필터링
_updateAvailableOptions();

// 4. 초기 선택값 설정
_setInitialSelections();

// 5. 3D 뷰어 데이터 구성
_build3DViewerData();

// 6. 초기 제품 정보 업데이트
await getProduct("init");
```

**새로 추가된 함수:**
```dart
/// 같은 제품명의 모든 색상별 제품 조회
Future<void> _loadAllColorProducts() async {
  try {
    final url = Uri.parse(
        "$mainUrl/products/getBySeqs?m_seq=${_initialProduct!.m_seq}&p_name=${Uri.encodeComponent(_initialProduct!.p_name)}");
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    if (jsonData['results'] != null) {
      _allColorProducts = (jsonData['results'] as List)
          .map((d) => Product.fromJson(d))
          .toList();
    }
  } catch (e) {
    debugPrint('같은 제품명의 모든 색상별 제품 조회 실패: $e');
  }
}
```

**쿼리:**
- `GET /api/products/getBySeqs?m_seq={m_seq}&p_name={p_name}` (색상 파라미터 없음)

**특징:**
- 색상(`cc_seq`) 파라미터 없이 조회 → 같은 제품명의 모든 색상 제품을 한 번에 가져옴
- `Uri.encodeComponent()` 사용으로 URL 인코딩 처리
- 초기 로드 시 한 번만 호출

**getProduct() 함수 (변경 없음):**
```dart
Future<void> getProduct(String type) async {
  if (product!.p_seq == -1) {
    String url0 = "$mainUrl/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}";
    
    final url = Uri.parse(url0);
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    if (jsonData != null && jsonData["results"].length > 0) {
      product = Product.fromJson(jsonData['results'][0]);
      final genderIndex = _availableGenders.indexWhere((f) => f.gc_seq == product!.gc_seq);
      if (genderIndex != -1) {
        selectedGender = genderIndex;
      }
    }
  } else {
    String url0 = "$mainUrl/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}&sc_seq=${product!.sc_seq}&gc_seq=${product!.gc_seq}";
    
    final url = Uri.parse(url0);
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    if (jsonData != null && jsonData["results"].length > 0) {
      product = Product.fromJson(jsonData['results'][0]);
      final genderIndex = _availableGenders.indexWhere((f) => f.gc_seq == product!.gc_seq);
      if (genderIndex != -1) {
        selectedGender = genderIndex;
      }
      isExist = true;
    } else {
      isExist = false;
      Get.snackbar("알림", "죄송합니다. 선택한 $type의 제품이 존재 하지 않습니다. ", backgroundColor: Colors.blue[200]);
    }
  }
  setState(() {});
}
```

**변경사항:**
- `genderList` → `_availableGenders` 사용
- null 체크 추가

---

## 3. 필터링 로직

### 3.1 기존 방식

**없음** - 모든 카테고리 값을 표시하고, 선택 후 `getProduct()` 호출로 존재 여부 확인

**문제점:**
- 존재하지 않는 옵션도 버튼으로 표시됨
- 사용자가 선택 후에야 존재하지 않음을 알 수 있음
- 불필요한 API 호출 발생 가능

---

### 3.2 새로운 방식

**`_updateAvailableOptions()` 함수 추가:**

```dart
/// 실제 존재하는 옵션만 필터링
void _updateAvailableOptions() {
  if (_allColorProducts.isEmpty) return;

  // 실제 존재하는 색상만 필터링
  final existingColorSeqs = _allColorProducts.map((p) => p.cc_seq).toSet().toList();
  _availableColors = _colorCategories.where((c) => existingColorSeqs.contains(c.cc_seq)).toList();

  // 선택된 색상이 있으면 해당 색상의 사이즈만 필터링
  if (_availableColors.isNotEmpty && selectedColor < _availableColors.length) {
    final selectedColorSeq = _availableColors[selectedColor].cc_seq;
    final existingSizeSeqs = _allColorProducts
        .where((p) => p.cc_seq == selectedColorSeq)
        .map((p) => p.sc_seq)
        .toSet()
        .toList();
    _availableSizes = _sizeCategories.where((s) => existingSizeSeqs.contains(s.sc_seq)).toList()
      ..sort((a, b) => a.sc_seq.compareTo(b.sc_seq)); // 사이즈 순으로 정렬

    // 선택된 사이즈가 있으면 해당 색상+사이즈의 성별만 필터링
    if (_availableSizes.isNotEmpty && selectedSize < _availableSizes.length) {
      final selectedSizeSeq = _availableSizes[selectedSize].sc_seq;
      final existingGenderSeqs = _allColorProducts
          .where((p) => p.cc_seq == selectedColorSeq && p.sc_seq == selectedSizeSeq)
          .map((p) => p.gc_seq)
          .toSet()
          .toList();
      _availableGenders = _genderCategories.where((g) => existingGenderSeqs.contains(g.gc_seq)).toList();
    } else {
      _availableGenders = [];
    }
  } else {
    _availableSizes = [];
    _availableGenders = [];
  }
}
```

**특징:**
- `_allColorProducts`에서 실제 존재하는 옵션만 추출
- 색상 선택 시 → 해당 색상의 사이즈만 표시
- 사이즈 선택 시 → 해당 색상+사이즈의 성별만 표시
- 동적 필터링으로 사용자 경험 개선

---

## 4. 쿼리 호출 횟수 비교

### 4.1 초기 로드 시

| 단계 | 기존 방식 | 새로운 방식 |
|------|----------|------------|
| 카테고리 로드 | 3회 | 3회 |
| 제품 조회 | 1회 (선택된 색상만) | 1회 (모든 색상) |
| **총계** | **4회** | **4회** |

**비고:**
- 호출 횟수는 동일하지만, 새로운 방식은 모든 색상 제품을 한 번에 조회하여 필터링 가능

---

### 4.2 옵션 선택 시

| 액션 | 기존 방식 | 새로운 방식 |
|------|----------|------------|
| 색상 선택 | 1회 (`getProduct`) | 1회 (`getProduct`) |
| 사이즈 선택 | 1회 (`getProduct`) | 1회 (`getProduct`) |
| 성별 선택 | 1회 (`getProduct`) | 1회 (`getProduct`) |

**비고:**
- 옵션 선택 시 쿼리 호출 횟수는 동일
- 새로운 방식은 필터링된 옵션만 표시하므로 사용자 경험 개선

---

## 5. 데이터 흐름 비교

### 5.1 기존 방식

```
초기화
  ↓
카테고리 로드 (3회)
  ↓
getProduct("init") 호출
  ↓
[사용자 선택]
  ↓
getProduct() 호출 (선택할 때마다)
  ↓
존재 여부 확인 → 스넥바 표시 (없는 경우)
```

**문제점:**
- 존재하지 않는 옵션도 표시됨
- 선택 후에야 존재 여부 확인 가능

---

### 5.2 새로운 방식

```
초기화
  ↓
카테고리 로드 (3회)
  ↓
모든 색상 제품 조회 (1회) ← 새로 추가
  ↓
필터링 (_updateAvailableOptions) ← 새로 추가
  ↓
초기 선택값 설정 (_setInitialSelections) ← 새로 추가
  ↓
3D 뷰어 데이터 구성 (_build3DViewerData) ← 새로 추가
  ↓
getProduct("init") 호출
  ↓
[사용자 선택]
  ↓
필터링 업데이트 (_updateAvailableOptions) ← 동적 업데이트
  ↓
getProduct() 호출
```

**개선점:**
- 존재하는 옵션만 표시
- 선택 전에 필터링되어 사용자 경험 개선
- 동적 필터링으로 실시간 옵션 업데이트

---

## 6. 주요 변경사항 요약

### 6.1 추가된 쿼리

| 쿼리 | 설명 | 호출 시점 |
|------|------|----------|
| `GET /api/products/getBySeqs?m_seq={m_seq}&p_name={p_name}` | 같은 제품명의 모든 색상별 제품 조회 | 초기 로드 시 1회 |

**특징:**
- 색상 파라미터(`cc_seq`) 없이 조회
- 모든 색상의 제품을 한 번에 가져옴
- `Uri.encodeComponent()` 사용으로 URL 인코딩 처리

---

### 6.2 변경된 로직

1. **필터링 방식**
   - 기존: 모든 카테고리 표시 → 선택 후 존재 여부 확인
   - 변경: 실제 존재하는 옵션만 필터링하여 표시

2. **데이터 구조**
   - 기존: `genderList`, `colorList`, `sizeList` (모든 카테고리)
   - 변경: `_availableColors`, `_availableSizes`, `_availableGenders` (필터링된 옵션)

3. **동적 업데이트**
   - 색상 선택 시 → 사이즈/성별 목록 자동 업데이트
   - 사이즈 선택 시 → 성별 목록 자동 업데이트

---

### 6.3 개선 효과

| 항목 | 기존 | 개선 후 |
|------|------|---------|
| 존재하지 않는 옵션 표시 | ✅ 표시됨 | ❌ 표시 안 됨 |
| 사용자 경험 | 선택 후 확인 | 선택 전 필터링 |
| API 호출 횟수 | 동일 | 동일 |
| 데이터 효율성 | 낮음 | 높음 (필터링) |

---

## 7. 코드 변경 이력

**2026-01-05:**
- `_loadAllColorProducts()` 함수 추가: 같은 제품명의 모든 색상별 제품 조회
- `_updateAvailableOptions()` 함수 추가: 실제 존재하는 옵션만 필터링
- `_setInitialSelections()` 함수 추가: 진입 시 받아온 product 값으로 기본 선택
- `_build3DViewerData()` 함수 추가: 3D 뷰어용 색상별 이미지 파일명 리스트 생성
- 필터링된 옵션만 표시하도록 UI 위젯 수정
- 동적 필터링 로직 구현 (색상 선택 시 사이즈/성별 자동 업데이트)

---

## 8. 참고사항

- 기존 `getProduct()` 함수는 그대로 유지되어 하위 호환성 보장
- 필터링은 클라이언트 측에서 `_allColorProducts` 데이터를 기반으로 수행
- 3D 뷰어 연동을 위한 데이터 구조 추가 (`_3dImageNames`, `_3dColorNames`)

