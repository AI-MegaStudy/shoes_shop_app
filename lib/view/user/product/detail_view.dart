import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/model/color_category.dart';
import 'package:shoes_shop_app/model/gender_category.dart';
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/model/size_category.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/user/payment/gt_user_cart_view.dart';
import 'package:shoes_shop_app/view/user/payment/gt_user_purchase_view.dart';
import 'package:shoes_shop_app/view/user/product/detail_module_3d.dart';
import 'package:http/http.dart' as http;

class CartItem {
  int p_seq;
  String p_name;
  int p_price;
  int cc_seq;
  String cc_name;
  int sc_seq;
  String sc_name;
  int gc_seq;
  String gc_name;
  int quantity;
  String p_image;

  CartItem({
    required this.p_seq,
    required this.p_name,
    required this.p_price,
    required this.cc_seq,
    required this.cc_name,
    required this.sc_seq,
    required this.sc_name,
    required this.gc_seq,
    required this.gc_name,
    required this.quantity,
    required this.p_image,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_seq': p_seq,
      'p_name': p_name,
      'p_price': p_price,
      'cc_seq': cc_seq,
      'cc_name': cc_name,
      'sc_seq': sc_seq,
      'sc_name': sc_name,
      'gc_seq': gc_seq,
      'gc_name': gc_name,
      'quantity': quantity,
      'p_image': p_image,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      p_seq: json['p_seq'],
      p_name: json['p_name'],
      p_price: json['p_price'],
      cc_seq: json['cc_seq'],
      cc_name: json['cc_name'],
      sc_seq: json['sc_seq'],
      sc_name: json['sc_name'],
      gc_seq: json['gc_seq'],
      gc_name: json['gc_name'],
      quantity: json['quantity'],
      p_image: json['p_image'],
    );
  }
}

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  Product? product = Get.arguments;

  /// 초기 제품 정보 (진입 시 받아온 값)
  Product? _initialProduct;

  /// 같은 제품명의 모든 색상별 제품 목록
  List<Product> _allColorProducts = [];

  /// 카테고리 목록 (전체)
  List<GenderCategory> _genderCategories = [];
  List<ColorCategory> _colorCategories = [];
  List<SizeCategory> _sizeCategories = [];

  /// 실제 존재하는 옵션만 필터링된 리스트
  List<ColorCategory> _availableColors = [];
  List<SizeCategory> _availableSizes = [];
  List<GenderCategory> _availableGenders = [];

  late int selectedGender = 2;
  late int selectedColor = 0;
  late int selectedSize = 0;
  bool isExist = true;

  int quantity = 1;

  /// 3D 뷰어용 데이터
  List<String> _3dImageNames = []; // 색상별 이미지 파일명 리스트
  List<String> _3dColorNames = []; // 색상명 리스트
  int _3dReloadKey = 0; // 위젯 재생성을 위한 키
  // == UI관련 색깔
  // 선택 버튼 background
  final Color selectedBgColor = Colors.blue;
  // 선택 버튼 foreground(Text Color)
  final Color selectedFgColor = Colors.white;
  // Title Font Size
  final double titleFontSize = 15.0;

  String get mainUrl => "${config.getApiBaseUrl()}/api";
  @override
  void initState() {
    super.initState();
    _initialProduct = product;
    initializedData();
  }

  Future<void> initializedData() async {
    if (product == null) return;

    try {
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
    } catch (e) {
      debugPrint('데이터 로드 실패: $e');
    }
  }

  /// 카테고리 목록 로드 (전체)
  Future<void> _loadCategories() async {
    try {
      // Gender Categories
      var url = Uri.parse("$mainUrl/gender_categories");
      var response = await http.get(url, headers: {});
      var jsonData = json.decode(utf8.decode(response.bodyBytes));
      _genderCategories = (jsonData["results"] as List).map((d) => GenderCategory.fromJson(d)).toList();

      // Color Categories
      url = Uri.parse("$mainUrl/color_categories");
      response = await http.get(url, headers: {});
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      _colorCategories = (jsonData["results"] as List).map((d) => ColorCategory.fromJson(d)).toList();

      // Size Categories
      url = Uri.parse("$mainUrl/size_categories");
      response = await http.get(url, headers: {});
      jsonData = json.decode(utf8.decode(response.bodyBytes));
      _sizeCategories = (jsonData["results"] as List).map((d) => SizeCategory.fromJson(d)).toList();
    } catch (e) {
      debugPrint('카테고리 로드 실패: $e');
    }
  }

  /// 같은 제품명의 모든 색상별 제품 조회
  Future<void> _loadAllColorProducts() async {
    try {
      final url = Uri.parse("$mainUrl/products/getBySeqs?m_seq=${_initialProduct!.m_seq}&p_name=${Uri.encodeComponent(_initialProduct!.p_name)}");
      final response = await http.get(url);
      final jsonData = json.decode(utf8.decode(response.bodyBytes));

      if (jsonData['results'] != null) {
        _allColorProducts = (jsonData['results'] as List).map((d) => Product.fromJson(d)).toList();
      }
    } catch (e) {
      debugPrint('같은 제품명의 모든 색상별 제품 조회 실패: $e');
    }
  }

  /// 실제 존재하는 옵션만 필터링
  void _updateAvailableOptions() {
    if (_allColorProducts.isEmpty) return;

    // 실제 존재하는 색상만 필터링
    final existingColorSeqs = _allColorProducts.map((p) => p.cc_seq).toSet().toList();
    _availableColors = _colorCategories.where((c) => existingColorSeqs.contains(c.cc_seq)).toList();

    // 선택된 색상이 있으면 해당 색상의 사이즈만 필터링
    if (_availableColors.isNotEmpty && selectedColor < _availableColors.length) {
      final selectedColorSeq = _availableColors[selectedColor].cc_seq;
      final existingSizeSeqs = _allColorProducts.where((p) => p.cc_seq == selectedColorSeq).map((p) => p.sc_seq).toSet().toList();
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

  /// 3D 뷰어 데이터 구성 (색상별 이미지 파일명 리스트 생성)
  void _build3DViewerData() {
    _3dImageNames = [];
    _3dColorNames = [];

    // 실제 존재하는 색상별로 이미지 파일명 수집
    for (final color in _availableColors) {
      // 해당 색상의 첫 번째 제품에서 이미지 파일명 가져오기
      final colorProduct = _allColorProducts.firstWhere(
        (p) => p.cc_seq == color.cc_seq && p.p_image.isNotEmpty,
        orElse: () => _allColorProducts.firstWhere((p) => p.cc_seq == color.cc_seq, orElse: () => _allColorProducts.first),
      );

      if (colorProduct.p_image.isNotEmpty) {
        _3dImageNames.add(colorProduct.p_image);
        _3dColorNames.add(color.cc_name);
      }
    }

    debugPrint('=== 3D 뷰어 데이터 구성 ===');
    debugPrint('이미지 파일명 리스트: $_3dImageNames');
    debugPrint('색상명 리스트: $_3dColorNames');
    debugPrint('현재 선택된 색상 인덱스: $selectedColor');
    debugPrint('==========================');
  }

  /// 초기 선택값 설정 (진입 시 받아온 product 값으로 기본 선택)
  void _setInitialSelections() {
    if (_initialProduct == null) return;

    // 1. 초기 색상 인덱스 설정
    final initialColorSeq = _initialProduct!.cc_seq;
    final colorIndex = _availableColors.indexWhere((c) => c.cc_seq == initialColorSeq);
    if (colorIndex != -1) {
      selectedColor = colorIndex;
    } else if (_availableColors.isNotEmpty) {
      selectedColor = 0;
    }

    // 2. 색상 선택 후 사이즈 목록 업데이트
    _updateAvailableOptions();

    // 3. 초기 사이즈 인덱스 설정 (진입 시 받아온 제품의 사이즈)
    if (_availableSizes.isNotEmpty) {
      final initialSizeSeq = _initialProduct!.sc_seq;
      final sizeIndex = _availableSizes.indexWhere((s) => s.sc_seq == initialSizeSeq);
      if (sizeIndex != -1) {
        selectedSize = sizeIndex;
      } else {
        // 해당 색상에 초기 사이즈가 없으면 가장 작은 사이즈로 설정
        selectedSize = 0;
      }
    }

    // 4. 사이즈 선택 후 성별 목록 업데이트
    _updateAvailableOptions();

    // 5. 초기 성별 인덱스 설정 (진입 시 받아온 제품의 성별)
    if (_availableGenders.isNotEmpty) {
      final initialGenderSeq = _initialProduct!.gc_seq;
      final genderIndex = _availableGenders.indexWhere((g) => g.gc_seq == initialGenderSeq);
      if (genderIndex != -1) {
        selectedGender = genderIndex;
      } else {
        // 해당 색상+사이즈에 초기 성별이 없으면 첫 번째 성별로 설정
        selectedGender = 0;
      }
    }
  }

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
      String url0 =
          "$mainUrl/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}&sc_seq=${product!.sc_seq}&gc_seq=${product!.gc_seq}";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product!.p_name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 450,
                  // color: Colors.green,
                  child: _3dImageNames.isNotEmpty
                      ? GTProductDetail3D(
                          key: ValueKey('3d_${_3dReloadKey}_$selectedColor'), // 색상 변경 시 위젯 재생성
                          imageNames: _3dImageNames,
                          colorList: _3dColorNames,
                          initialIndex: selectedColor < _3dImageNames.length ? selectedColor : 0,
                        )
                      : const SizedBox.shrink(),
                ),
                Text(
                  "상품명: ${product!.p_name}",
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                ),

                Text(
                  "가격: ${CustomCommonUtil.formatPrice(product!.p_price)}",
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                ),

                // 제품 설명
                Container(
                  width: MediaQuery.of(context).size.width,

                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                  child: Padding(padding: const EdgeInsets.all(8.0), child: Text(product!.p_description)),
                ),

                // Gender
                Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: _genderWidget()),

                // Size
                Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: _sizeWidget()),
                // color
                Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: _colorWidget()),
                // 수량
                isExist
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(child: _quantityWidget()),
                            IconButton(
                              onPressed: () => _addCart(true),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green[100],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
                              ),
                              icon: Icon(Icons.shopping_cart, color: Colors.black),
                            ),
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () => Get.to(() => const GTUserCartView()),
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))),
                                child: Text('View'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                isExist
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // 카트에 추가
                                  _addCart(false);
                                  // Todo: GO to page
                                  Get.to(() => UserPurchaseView());
                                },
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))),
                                child: Text("바로구매"),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Functions
  void _addCart(bool isMessage) {
    // 카트에 추가

    final item = CartItem(
      p_seq: product!.p_seq!,
      p_name: product!.p_name,
      p_price: product!.p_price,
      cc_seq: product!.cc_seq,
      cc_name: product!.p_color!,
      sc_seq: product!.sc_seq,
      sc_name: product!.p_size!,
      gc_seq: product!.gc_seq,
      gc_name: product!.p_gender!,
      quantity: quantity,
      p_image: product!.p_image,
    ).toJson();

    print(item);

    CartStorage.addToCart(item);
    // Get Message
    if (isMessage) {
      Get.defaultDialog(
        title: "카트에 추가되었습니다.",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('성공적으로 추가 됬습니다.'),
            Text('상품명: ${product!.p_name} / ${product!.p_gender}'),
            Text('수 량: $quantity'),
            Text('가 격: ${product!.p_price * quantity}원'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("확인"),
          ),
        ],
      );
    }
  }

  // -- Widgets
  Widget _genderWidget() {
    if (_availableGenders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        Row(
          spacing: 5,
          children: List.generate(
            _availableGenders.length,
            (index) => ElevatedButton(
              onPressed: () async {
                selectedGender = index;
                final genderSeq = _availableGenders[selectedGender].gc_seq;
                if (genderSeq != null) {
                  product!.gc_seq = genderSeq;
                }
                product!.p_gender = _availableGenders[selectedGender].gc_name;
                await getProduct(_availableGenders[selectedGender].gc_name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedGender == index ? selectedBgColor : selectedFgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
              ),
              child: Text(_availableGenders[index].gc_name, style: TextStyle(color: selectedGender == index ? selectedFgColor : Colors.black)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sizeWidget() {
    if (_availableSizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            spacing: 5,
            children: List.generate(
              _availableSizes.length,
              (index) => ElevatedButton(
                onPressed: () async {
                  selectedSize = index;
                  product!.sc_seq = _availableSizes[selectedSize].sc_seq;
                  product!.p_size = _availableSizes[selectedSize].sc_name;
                  _updateAvailableOptions(); // 사이즈 선택 후 성별 목록 업데이트
                  await getProduct("사이즈(${product!.p_size})");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSize == index ? selectedBgColor : selectedFgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
                ),
                child: Text(_availableSizes[index].sc_name, style: TextStyle(color: selectedSize == index ? selectedFgColor : Colors.black)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorWidget() {
    if (_availableColors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            spacing: 5,
            children: List.generate(
              _availableColors.length,
              (index) => ElevatedButton(
                onPressed: () async {
                  selectedColor = index;
                  final colorSeq = _availableColors[selectedColor].cc_seq;
                  if (colorSeq != null) {
                    product!.cc_seq = colorSeq;
                  }
                  product!.p_color = _availableColors[selectedColor].cc_name;
                  selectedSize = 0; // 색상 변경 시 가장 작은 사이즈로 리셋
                  _updateAvailableOptions(); // 색상 선택 후 사이즈/성별 목록 업데이트
                  _build3DViewerData(); // 3D 뷰어 데이터 업데이트
                  _3dReloadKey++; // 위젯 재생성을 위한 키 증가
                  await getProduct("Color(${product!.p_color})");
                  setState(() {}); // UI 업데이트
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor == index ? selectedBgColor : selectedFgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
                ),
                child: Text(_availableColors[index].cc_name, style: TextStyle(color: selectedColor == index ? selectedFgColor : Colors.black)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quantityWidget() {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue[100]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              quantity += 1;
              setState(() {});
            },
            icon: Icon(Icons.add),
          ),
          Container(
            width: 50,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('$quantity'),
          ),
          IconButton(
            onPressed: () {
              if (quantity > 1) {
                quantity -= 1;
                setState(() {});
              }
            },
            icon: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
