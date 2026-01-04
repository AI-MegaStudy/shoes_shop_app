import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o3d/o3d.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/model/size_category.dart';
import 'package:shoes_shop_app/model/gender_category.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/view/main/user/cart/main_cart_view.dart';
import 'package:shoes_shop_app/view/main/user/payment/main_payment_view.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:http/http.dart' as http;

/// 메인 제품 상세 페이지
/// 
/// 제품 상세 정보를 표시하고, 3D 뷰어를 통합하며, 색상/사이즈/성별 선택 및 장바구니/결제 기능을 제공합니다.
class MainProductDetail extends StatefulWidget {
  const MainProductDetail({super.key});

  @override
  State<MainProductDetail> createState() => _MainProductDetailState();
}

class _MainProductDetailState extends State<MainProductDetail> {
  /// arguments에서 받은 초기 제품 정보
  Product? _initialProduct;

  /// 현재 선택된 제품 정보
  Product? _currentProduct;

  /// 같은 제품명의 모든 색상별 제품 목록
  List<Product> _allColorProducts = [];

  /// 카테고리 목록
  List<SizeCategory> _sizeCategories = [];
  List<GenderCategory> _genderCategories = [];

  /// 선택된 옵션
  int? _selectedColorIndex;
  int? _selectedSizeIndex;
  int? _selectedGenderIndex;

  /// 사용 가능한 사이즈 목록 (선택된 색상에 따라 동적 변경)
  List<SizeCategory> _availableSizes = [];

  /// 사용 가능한 성별 목록 (선택된 색상과 사이즈에 따라 동적 변경)
  List<GenderCategory> _availableGenders = [];

  /// 수량
  int _quantity = 1;

  /// 3D 뷰어 관련
  String _currentImageName = ''; // 현재 선택된 색상의 이미지 파일명
  String _currentModelName = ''; // 현재 선택된 색상의 모델 이름
  List<int> _colorSeqList = []; // 색상별 cc_seq 리스트 (색상 선택용)
  bool _is3DLoading = false;
  bool _has3DError = false;
  int _reloadCounter = 0;
  final O3DController _o3dController = O3DController();

  /// 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialProduct = Get.arguments as Product?;
    if (_initialProduct == null) {
      Get.back();
      return;
    }
    _loadData();
    // API base URL 설정
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
  }

  /// 데이터 로드
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 카테고리 목록 로드
      await _loadCategories();

      // 같은 제품명의 모든 색상별 제품 조회
      await _loadAllColorProducts();

      // 3D 뷰어 데이터 구성 (색상별로 그룹화하여 _imageNames, _colorSeqList 생성)
      _build3DViewerData();
      
      // 초기 색상 인덱스 설정 (3D 뷰어 데이터 구성 후에 설정)
      // _build3DViewerData()에서 이미 _selectedColorIndex를 조정했으므로 확인만 함
      if (_selectedColorIndex == null && _colorSeqList.isNotEmpty) {
        _selectedColorIndex = 0;
      }
      
      // 초기 제품 정보 설정
      _currentProduct = _initialProduct;

      // 사용 가능한 사이즈/성별 목록 업데이트
      _updateAvailableOptions();
      
      // 사이즈 초기값 설정 (항상 가장 작은 사이즈로 설정)
      if (_availableSizes.isNotEmpty && _selectedSizeIndex == null) {
        // _availableSizes는 이미 sc_seq 순으로 정렬되어 있으므로 첫 번째가 가장 작은 사이즈
        _selectedSizeIndex = 0;
        _updateAvailableOptions(); // 사이즈 선택 후 성별 목록 업데이트
        _updateCurrentProduct();
      }
      
      // 성별 초기값 설정 (사이즈 선택 후 사용 가능한 성별 중 첫 번째로 설정)
      if (_availableGenders.isNotEmpty && _selectedGenderIndex == null) {
        _selectedGenderIndex = 0;
        _updateCurrentProduct();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar(
          '오류',
          '제품 정보를 불러오는데 실패했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// 카테고리 목록 로드
  Future<void> _loadCategories() async {
    final apiBaseUrl = config.getApiBaseUrl();
    CustomNetworkUtil.setBaseUrl(apiBaseUrl);

    final results = await Future.wait([
      CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/color_categories',
        fromJson: (json) => json,
      ),
      CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/size_categories',
        fromJson: (json) => json,
      ),
      CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/gender_categories',
        fromJson: (json) => json,
      ),
    ]);

    // _colorCategories는 현재 사용되지 않음 (주석 처리)
    // if (results[0].success && results[0].data != null) {
    //   _colorCategories = (results[0].data!['results'] as List<dynamic>?)
    //           ?.map((e) => ColorCategory.fromJson(e))
    //           .toList() ??
    //       [];
    // }
    if (results[1].success && results[1].data != null) {
      _sizeCategories = (results[1].data!['results'] as List<dynamic>?)
              ?.map((e) => SizeCategory.fromJson(e))
              .toList() ??
          [];
    }
    if (results[2].success && results[2].data != null) {
      _genderCategories = (results[2].data!['results'] as List<dynamic>?)
              ?.map((e) => GenderCategory.fromJson(e))
              .toList() ??
          [];
    }
  }

  /// 같은 제품명의 모든 색상별 제품 조회
  Future<void> _loadAllColorProducts() async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      final url = '$apiBaseUrl/api/products/getBySeqs?m_seq=${_initialProduct!.m_seq}&p_name=${Uri.encodeComponent(_initialProduct!.p_name)}';

      final response = await http.get(Uri.parse(url));
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

  /// 3D 뷰어 데이터 구성 (전달받은 색상의 이미지 하나만 사용)
  void _build3DViewerData() {
    debugPrint('=== 3D 뷰어 데이터 구성 시작 ===');
    debugPrint('_allColorProducts 개수: ${_allColorProducts.length}개');
    debugPrint('초기 제품: ${_initialProduct?.p_name}, 색상: ${_initialProduct?.cc_seq}, 이미지: ${_initialProduct?.p_image}');
    
    // 색상별 cc_seq 리스트 생성 (색상 선택 UI용)
    final seen = <int>{};
    _colorSeqList = [];
    for (final product in _allColorProducts) {
      if (!seen.contains(product.cc_seq)) {
        _colorSeqList.add(product.cc_seq);
        seen.add(product.cc_seq);
      }
    }
    
    // 초기 제품의 이미지와 모델 이름 설정
    if (_initialProduct != null && _initialProduct!.p_image.isNotEmpty) {
      _currentImageName = _initialProduct!.p_image;
      
      // 이미지 파일명에서 모델 이름 추출 (product_detail_3d.dart와 동일한 로직)
      // 확장자 제거 (예: 'Newbalnce_U740WN2_Black_01.png' -> 'Newbalnce_U740WN2_Black_01')
      String nameWithoutExt = _currentImageName.replaceAll(RegExp(r'\.(png|jpg|jpeg|avif)$'), '');
      
      // 마지막 언더스코어와 숫자 제거 (예: 'Newbalnce_U740WN2_Black_01' -> 'Newbalnce_U740WN2_Black')
      _currentModelName = nameWithoutExt.replaceAll(RegExp(r'_\d+$'), '');
      
      debugPrint('초기 이미지: $_currentImageName');
      debugPrint('초기 모델 이름: $_currentModelName');
    } else {
      _currentImageName = '';
      _currentModelName = '';
      debugPrint('초기 제품에 이미지가 없습니다.');
    }
    
    // 초기 색상 인덱스 설정
    if (_initialProduct != null && _colorSeqList.isNotEmpty) {
      final initialColorSeq = _initialProduct!.cc_seq;
      final colorIndex = _colorSeqList.indexOf(initialColorSeq);
      if (colorIndex != -1) {
        _selectedColorIndex = colorIndex;
      } else {
        _selectedColorIndex = 0;
      }
    } else if (_colorSeqList.isNotEmpty) {
      _selectedColorIndex = 0;
    }
    
    debugPrint('=== 3D 뷰어 데이터 구성 완료 ===');
    debugPrint('색상 seq 리스트: $_colorSeqList');
    debugPrint('선택된 색상 인덱스: $_selectedColorIndex');
    debugPrint('현재 이미지: $_currentImageName');
    debugPrint('현재 모델 이름: $_currentModelName');
    debugPrint('3D 모델 URL: $_modelUrl');
    debugPrint('========================');
  }
  
  /// 3D 모델 URL
  String get _modelUrl {
    final url = 'https://cheng80.myqnapcloud.com/glb_model.php?name=$_currentModelName';
    debugPrint('=== 3D 모델 URL 생성 ===');
    debugPrint('모델 이름: $_currentModelName');
    debugPrint('전체 URL: $url');
    debugPrint('======================');
    return url;
  }

  /// 현재 모델 리로드 함수 (현재 선택된 모델을 다시 로드)
  void _reloadInitialModel() {
    // 로딩 중이면 무시
    if (_is3DLoading) {
      return;
    }
    
    setState(() {
      _is3DLoading = true; // 로딩 시작
      _reloadCounter++; // 위젯 강제 재생성을 위한 카운터 증가 (현재 인덱스 유지)
      _has3DError = false; // 에러 상태 초기화
    });
    
    debugPrint('=== 3D 모델 리로드 ===');
    debugPrint('리로드 카운터: $_reloadCounter');
    debugPrint('모델 이름: $_currentModelName');
    debugPrint('모델 URL: $_modelUrl');
    debugPrint('====================');
    
    // O3D 위젯이 src 변경을 자동으로 감지하여 새 모델을 로드함 (ValueKey로 위젯 재생성)
    // onWebViewCreated의 NavigationDelegate가 페이지 로딩 완료를 감지함
    // _reloadCounter가 변경되면 위젯이 재생성되어 카메라가 초기화됨
  }

  /// 사용 가능한 사이즈/성별 목록 업데이트
  void _updateAvailableOptions() {
    // 선택된 색상에 해당하는 사이즈만 필터링
    if (_selectedColorIndex != null &&
        _selectedColorIndex! >= 0 &&
        _selectedColorIndex! < _colorSeqList.length) {
      final selectedColorSeq = _colorSeqList[_selectedColorIndex!];
      
      // 해당 색상의 모든 제품에서 사이즈 seq 추출
      final availableSizeSeqs = _allColorProducts
          .where((p) => p.cc_seq == selectedColorSeq)
          .map((p) => p.sc_seq)
          .toSet()
          .toList();
      
      // 사이즈 카테고리에서 필터링하고 sc_seq 순으로 정렬 (가장 작은 사이즈가 먼저)
      _availableSizes = _sizeCategories
          .where((s) => availableSizeSeqs.contains(s.sc_seq))
          .toList()
        ..sort((a, b) => a.sc_seq.compareTo(b.sc_seq));
      
      // 사이즈가 선택되어 있고, 색상도 선택되어 있으면 성별 목록 조회
      if (_selectedSizeIndex != null &&
          _selectedSizeIndex! >= 0 &&
          _selectedSizeIndex! < _availableSizes.length &&
          _availableSizes.isNotEmpty) {
        final selectedSizeSeq = _availableSizes[_selectedSizeIndex!].sc_seq;
        
        final availableGenderSeqs = _allColorProducts
            .where((p) => p.cc_seq == selectedColorSeq && p.sc_seq == selectedSizeSeq)
            .map((p) => p.gc_seq)
            .toSet()
            .toList();

        _availableGenders = _genderCategories
            .where((g) => availableGenderSeqs.contains(g.gc_seq))
            .toList();
      } else {
        _availableGenders = [];
      }
    } else {
      // 색상이 선택되지 않았으면 모든 사이즈 표시
      _availableSizes = _sizeCategories;
      _availableGenders = [];
    }
  }

  /// 색상 선택 변경 (index는 _colorSeqList의 인덱스)
  void _onColorSelected(int index) {
    if (index == _selectedColorIndex) return;

    setState(() {
      _selectedColorIndex = index;
      // 성별 초기화
      _selectedGenderIndex = null;
      
      // 선택된 색상에 해당하는 제품에서 이미지 찾기
      final selectedColorSeq = _colorSeqList[index];
      final productWithImage = _allColorProducts.firstWhere(
        (p) => p.cc_seq == selectedColorSeq && p.p_image.isNotEmpty,
        orElse: () => _allColorProducts.firstWhere(
          (p) => p.cc_seq == selectedColorSeq,
          orElse: () => _allColorProducts.first,
        ),
      );
      
      // 새로운 색상의 이미지와 모델 이름 업데이트
      if (productWithImage.p_image.isNotEmpty) {
        _currentImageName = productWithImage.p_image;
        
        // 이미지 파일명에서 모델 이름 추출
        String nameWithoutExt = _currentImageName.replaceAll(RegExp(r'\.(png|jpg|jpeg|avif)$'), '');
        _currentModelName = nameWithoutExt.replaceAll(RegExp(r'_\d+$'), '');
        
        // 3D 뷰어 리로드
        _has3DError = false;
        _reloadCounter++;
        
        debugPrint('=== 3D 뷰어 색상 변경 ===');
        debugPrint('선택된 색상 인덱스: $index');
        debugPrint('색상 seq: $selectedColorSeq');
        debugPrint('새 이미지: $_currentImageName');
        debugPrint('새 모델 이름: $_currentModelName');
        debugPrint('모델 URL: $_modelUrl');
        debugPrint('========================');
      } else {
        // 이미지가 없으면 3D 뷰어 숨김
        _currentImageName = '';
        _currentModelName = '';
        _has3DError = true;
        debugPrint('선택된 색상에 이미지가 없습니다.');
      }
    });

    _updateAvailableOptions();
    
    // 색상 변경 후, 새로운 색상의 가장 작은 사이즈로 설정
    if (_availableSizes.isNotEmpty) {
      _selectedSizeIndex = 0;
    } else {
      _selectedSizeIndex = null;
    }
    
    _updateCurrentProduct();
  }

  /// 사이즈 선택 변경
  void _onSizeSelected(int? sizeSeq) {
    if (sizeSeq == null) {
      setState(() {
        _selectedSizeIndex = null;
        _selectedGenderIndex = null;
      });
      _updateAvailableOptions();
      _updateCurrentProduct();
      return;
    }

    final index = _availableSizes.indexWhere((s) => s.sc_seq == sizeSeq);
    if (index == -1) return;

    setState(() {
      _selectedSizeIndex = index;
      _selectedGenderIndex = null;
    });

    _updateAvailableOptions();
    _updateCurrentProduct();
  }

  /// 성별 선택 변경
  void _onGenderSelected(int index) {
    if (index == _selectedGenderIndex) return;

    setState(() {
      _selectedGenderIndex = index;
    });

    _updateCurrentProduct();
  }

  /// 현재 제품 정보 업데이트
  void _updateCurrentProduct() {
    if (_selectedColorIndex == null || _colorSeqList.isEmpty || _allColorProducts.isEmpty) {
      _currentProduct = _allColorProducts.isNotEmpty ? _allColorProducts[0] : _initialProduct;
      return;
    }

    final selectedColorSeq = _colorSeqList[_selectedColorIndex!];

    Product? foundProduct;

    if (_selectedSizeIndex != null && _availableSizes.isNotEmpty &&
        _selectedGenderIndex != null && _availableGenders.isNotEmpty) {
      // 색상, 사이즈, 성별 모두 선택된 경우
      final selectedSizeSeq = _availableSizes[_selectedSizeIndex!].sc_seq;
      final selectedGenderSeq = _availableGenders[_selectedGenderIndex!].gc_seq;

      foundProduct = _allColorProducts.firstWhere(
        (p) => p.cc_seq == selectedColorSeq &&
            p.sc_seq == selectedSizeSeq &&
            p.gc_seq == selectedGenderSeq,
        orElse: () {
          // 해당 조건에 맞는 제품이 없으면 선택된 색상의 첫 번째 제품 반환
          return _allColorProducts.firstWhere(
            (p) => p.cc_seq == selectedColorSeq,
            orElse: () => _allColorProducts.first,
          );
        },
      );
    } else if (_selectedSizeIndex != null && _availableSizes.isNotEmpty) {
      // 색상, 사이즈만 선택된 경우
      final selectedSizeSeq = _availableSizes[_selectedSizeIndex!].sc_seq;

      foundProduct = _allColorProducts.firstWhere(
        (p) => p.cc_seq == selectedColorSeq && p.sc_seq == selectedSizeSeq,
        orElse: () {
          // 해당 사이즈가 없으면 가장 작은 사이즈의 제품 반환
          final productsWithSelectedColor = _allColorProducts
              .where((p) => p.cc_seq == selectedColorSeq)
              .toList();
          if (productsWithSelectedColor.isNotEmpty) {
            productsWithSelectedColor.sort((a, b) => a.sc_seq.compareTo(b.sc_seq));
            return productsWithSelectedColor.first;
          }
          return _allColorProducts.first;
        },
      );
    } else {
      // 색상만 선택된 경우: 가장 작은 사이즈의 제품 반환
      final productsWithSelectedColor = _allColorProducts
          .where((p) => p.cc_seq == selectedColorSeq)
          .toList();
      if (productsWithSelectedColor.isNotEmpty) {
        productsWithSelectedColor.sort((a, b) => a.sc_seq.compareTo(b.sc_seq));
        foundProduct = productsWithSelectedColor.first;
      } else {
        foundProduct = _allColorProducts.firstWhere(
          (p) => p.cc_seq == selectedColorSeq,
          orElse: () => _allColorProducts.first,
        );
      }
    }

    setState(() {
      _currentProduct = foundProduct;
    });
  }

  /// 장바구니에 추가
  void _addToCart() {
    if (_currentProduct == null) {
      Get.snackbar(
        '오류',
        '제품 정보가 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // _currentProduct에 이미 모든 정보가 있으므로, 인덱스 검증 없이 진행
    // 제품 상세 페이지에서 이미 색상과 성별 정보를 가지고 들어오고,
    // 사이즈도 드롭박스에서 선택된 상태이므로 추가 검증 불필요

    final cartItem = {
      'p_seq': _currentProduct!.p_seq,
      'p_name': _currentProduct!.p_name,
      'p_price': _currentProduct!.p_price,
      'cc_seq': _currentProduct!.cc_seq,
      'cc_name': _currentProduct!.p_color ?? '',
      'sc_seq': _currentProduct!.sc_seq,
      'sc_name': _currentProduct!.p_size ?? '',
      'gc_seq': _currentProduct!.gc_seq,
      'gc_name': _currentProduct!.p_gender ?? '',
      'quantity': _quantity,
      'p_image': _currentProduct!.p_image,
    };

    CartStorage.addToCart(cartItem);

    final p = context.palette;
    Get.snackbar(
      '성공',
      '장바구니에 추가되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: p.stockAvailable,
      colorText: p.textOnPrimary,
    );
  }

  /// 장바구니 페이지로 이동
  void _goToCart() {
    _addToCart();
    Get.to(() => MainCartView());
  }

  /// 바로구매
  void _buyNow() {
    if (_currentProduct == null) {
      Get.snackbar(
        '오류',
        '제품 정보가 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 현재 선택된 제품 정보로 바로 구매 (장바구니 거치지 않음)
    final cartItem = {
      'p_seq': _currentProduct!.p_seq,
      'p_name': _currentProduct!.p_name,
      'p_price': _currentProduct!.p_price,
      'cc_seq': _currentProduct!.cc_seq,
      'cc_name': _currentProduct!.p_color ?? '',
      'sc_seq': _currentProduct!.sc_seq,
      'sc_name': _currentProduct!.p_size ?? '',
      'gc_seq': _currentProduct!.gc_seq,
      'gc_name': _currentProduct!.p_gender ?? '',
      'quantity': _quantity,
      'p_image': _currentProduct!.p_image,
    };

    // 바로 구매 페이지로 이동 (장바구니에 추가하지 않음)
    Get.to(
      () => MainPaymentView(),
      arguments: [cartItem],
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentProduct == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('제품 상세')),
        body: const Center(child: Text('제품 정보를 불러올 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('제품 상세'),
        titleTextStyle: mainAppBarTitleStyle,
        centerTitle: mainAppBarCenterTitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 3D 뷰어 또는 이미지
            _build3DViewerOrImage(),
            const SizedBox(height: mainDefaultSpacing),
            // 제품 정보
            Padding(
              padding: mainDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final p = context.palette;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentProduct!.p_name,
                            style: mainLargeTitleStyle.copyWith(color: p.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentProduct!.p_maker ?? ''} / ${_currentProduct!.p_color ?? ''}',
                            style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: mainDefaultSpacing),
                  Builder(
                    builder: (context) {
                      final p = context.palette;
                      return Text(
                        '${_currentProduct!.p_price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                        style: mainPriceStyle.copyWith(color: p.priceHighlight),
                      );
                    },
                  ),
                  const SizedBox(height: mainDefaultSpacing),
                  if (_currentProduct!.p_description.isNotEmpty)
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: p.background,
                            borderRadius: mainSmallBorderRadius,
                          ),
                          child: Text(
                            _currentProduct!.p_description,
                            style: TextStyle(color: p.textPrimary),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: mainDefaultSpacing),
                  // 색상 선택
                  _buildColorSelection(),
                  const SizedBox(height: mainDefaultSpacing),
                  // 사이즈 선택
                  _buildSizeSelection(),
                  const SizedBox(height: mainDefaultSpacing),
                  // 성별 선택
                  _buildGenderSelection(),
                  const SizedBox(height: mainDefaultSpacing),
                  // 수량 선택
                  _buildQuantitySelection(),
                  const SizedBox(height: mainLargeSpacing),
                  // 장바구니/바로구매 버튼
                  _buildActionButtons(),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3D 뷰어 또는 이미지 위젯
  Widget _build3DViewerOrImage() {
    // 모델 이름이 없거나 에러가 발생한 경우 일반 이미지 표시
    final shouldShow3D = _currentModelName.isNotEmpty && !_has3DError;
    
    debugPrint('=== 3D 뷰어 표시 조건 체크 ===');
    debugPrint('현재 모델 이름: $_currentModelName');
    debugPrint('현재 이미지: $_currentImageName');
    debugPrint('3D 에러 발생: $_has3DError');
    debugPrint('3D 뷰어 표시 여부: $shouldShow3D');
    debugPrint('3D 모델 URL: ${shouldShow3D ? _modelUrl : "N/A"}');
    debugPrint('============================');
    
    // 에러가 발생했거나 모델 이름이 없으면 일반 이미지 표시
    if (!shouldShow3D) {
      final imageToShow = _currentImageName.isNotEmpty ? _currentImageName : (_currentProduct?.p_image ?? '');
      debugPrint('일반 이미지 표시: $imageToShow');
      return Builder(
        builder: (context) {
          final p = context.palette;
          return Container(
            width: double.infinity,
            height: main3DViewerHeight,
            color: p.background,
            child: imageToShow.isNotEmpty
                ? Image.network(
                    'https://cheng80.myqnapcloud.com/images/$imageToShow',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 64, color: p.textSecondary);
                    },
                  )
                : Icon(Icons.image_not_supported, size: 64, color: p.textSecondary),
          );
        },
      );
    }

    // 3D 뷰어 표시 (ProductDetail3D와 동일한 로직: PHP에 요청하고, 에러 발생 시 onWebResourceError에서 처리)
    debugPrint('3D 뷰어 표시: $_modelUrl');
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Container(
          width: double.infinity,
          height: main3DViewerHeight,
          color: p.background,
          child: Stack(
        children: [
          O3D(
            key: ValueKey('${_modelUrl}_$_reloadCounter'),
            controller: _o3dController,
            src: _modelUrl,
            autoRotate: false,
            cameraControls: true,
            onWebViewCreated: (WebViewController webViewController) async {
              await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
              webViewController.setNavigationDelegate(
                NavigationDelegate(
                  onPageStarted: (String url) {
                    if (mounted) {
                      setState(() {
                        _is3DLoading = true;
                        _has3DError = false; // 새 로딩 시작 시 에러 상태 초기화
                      });
                    }
                  },
                  onPageFinished: (String url) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          _is3DLoading = false;
                        });
                      }
                    });
                  },
                  onWebResourceError: (WebResourceError error) {
                    debugPrint('=== 3D 뷰어 WebView 에러 ===');
                    debugPrint('에러 설명: ${error.description}');
                    debugPrint('에러 코드: ${error.errorCode}');
                    debugPrint('에러 타입: ${error.errorType}');
                    debugPrint('요청 URL: ${error.url}');
                    debugPrint('3D 모델 이름: $_currentModelName');
                    debugPrint('3D 모델 URL: $_modelUrl');
                    debugPrint('==========================');
                    // 에러 발생 시 일반 이미지로 전환하기 위해 상태 업데이트
                    if (mounted) {
                      setState(() {
                        _has3DError = true;
                        _is3DLoading = false;
                      });
                    }
                  },
                ),
              );
            },
          ),
          if (_is3DLoading)
            Builder(
              builder: (context) {
                final p = context.palette;
                return Center(
                  child: CircularProgressIndicator(color: p.textOnPrimary),
                );
              },
            ),
          // 리셋 버튼 (3D 모델이 있을 때만 표시)
          if (_currentModelName.isNotEmpty && !_has3DError)
            Builder(
              builder: (context) {
                final p = context.palette;
                return Positioned(
                  bottom: mainDefaultSpacing,
                  right: mainDefaultSpacing,
                  child: FloatingActionButton(
                    onPressed: _is3DLoading ? null : _reloadInitialModel,
                    backgroundColor: p.primary.withOpacity(_is3DLoading ? 0.4 : 0.8),
                    tooltip: _is3DLoading ? '로딩 중...' : '현재 모델 리로드',
                    heroTag: 'reload_initial',
                    mini: true,
                    child: _is3DLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(p.textOnPrimary),
                            ),
                          )
                        : Icon(Icons.refresh, color: p.textOnPrimary),
                  ),
                );
              },
            ),
        ],
          ),
        );
      },
    );
  }

  /// 색상 선택 위젯
  Widget _buildColorSelection() {
    if (_colorSeqList.isEmpty) return const SizedBox.shrink();

    final p = context.palette;
    
    // _colorSeqList를 기준으로 색상 선택 UI 생성 (이미 색상별로 정리되어 있음)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '색상',
          style: mainTitleStyle.copyWith(color: p.textPrimary),
        ),
        const SizedBox(height: mainSmallSpacing),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorSeqList.asMap().entries.map((entry) {
            final index = entry.key;
            final colorSeq = entry.value;
            
            // 해당 색상의 첫 번째 제품을 찾아서 색상명 가져오기
            final colorProduct = _allColorProducts.firstWhere(
              (p) => p.cc_seq == colorSeq,
              orElse: () => _allColorProducts.first,
            );
            
            final isSelected = index == _selectedColorIndex;

            return ChoiceChip(
              label: Text(colorProduct.p_color ?? ''),
              selected: isSelected,
              selectedColor: p.chipSelectedBg,
              labelStyle: TextStyle(
                color: isSelected ? p.chipSelectedText : p.chipUnselectedText,
              ),
              onSelected: (selected) {
                if (selected) {
                  _onColorSelected(index);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 사이즈 선택 위젯
  Widget _buildSizeSelection() {
    final p = context.palette;
    
    if (_availableSizes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사이즈',
            style: mainTitleStyle.copyWith(color: p.textPrimary),
          ),
          const SizedBox(height: mainSmallSpacing),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: p.divider),
              borderRadius: mainSmallBorderRadius,
            ),
            child: Text(
              '사이즈 정보를 불러오는 중...',
              style: mainBodyTextStyle.copyWith(color: p.textSecondary),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사이즈',
          style: mainTitleStyle.copyWith(color: p.textPrimary),
        ),
        const SizedBox(height: mainSmallSpacing),
        DropdownButtonFormField<int>(
          initialValue: _availableSizes.isNotEmpty && _selectedSizeIndex != null && _selectedSizeIndex! < _availableSizes.length
              ? _availableSizes[_selectedSizeIndex!].sc_seq
              : (_availableSizes.isNotEmpty ? _availableSizes[0].sc_seq : null),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: p.divider),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: TextStyle(color: p.textPrimary),
          dropdownColor: p.cardBackground,
          items: _availableSizes.map((size) {
            return DropdownMenuItem<int>(
              value: size.sc_seq,
              child: Text(
                size.sc_name,
                style: TextStyle(color: p.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (value) {
            _onSizeSelected(value);
          },
        ),
      ],
    );
  }

  /// 성별 선택 위젯
  Widget _buildGenderSelection() {
    if (_availableGenders.isEmpty) return const SizedBox.shrink();

    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: mainTitleStyle.copyWith(color: p.textPrimary),
        ),
        const SizedBox(height: mainSmallSpacing),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableGenders.asMap().entries.map((entry) {
            final index = entry.key;
            final gender = entry.value;
            final isSelected = index == _selectedGenderIndex;

            return ChoiceChip(
              label: Text(gender.gc_name),
              selected: isSelected,
              selectedColor: p.chipSelectedBg,
              labelStyle: TextStyle(
                color: isSelected ? p.chipSelectedText : p.chipUnselectedText,
              ),
              onSelected: (selected) {
                if (selected) {
                  _onGenderSelected(index);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 수량 선택 위젯
  Widget _buildQuantitySelection() {
    final p = context.palette;
    final totalPrice = (_currentProduct?.p_price ?? 0) * _quantity;
    final formattedTotalPrice = CustomCommonUtil.formatPrice(totalPrice);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '수량',
          style: mainTitleStyle.copyWith(color: p.textPrimary),
        ),
        const SizedBox(height: mainSmallSpacing),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_quantity > 1) {
                  setState(() {
                    _quantity--;
                  });
                }
              },
              icon: Icon(Icons.remove, color: p.textPrimary),
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '$_quantity',
                style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _quantity++;
                });
              },
              icon: Icon(Icons.add, color: p.textPrimary),
            ),
            const Spacer(),
            Text(
              '합계: $formattedTotalPrice',
              style: mainPriceStyle.copyWith(color: p.priceHighlight),
            ),
          ],
        ),
      ],
    );
  }

  /// 액션 버튼 위젯
  Widget _buildActionButtons() {
    final p = context.palette;
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _goToCart,
            style: mainElevatedButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(p.cardBackground),
              foregroundColor: WidgetStateProperty.all(p.textPrimary),
              side: WidgetStateProperty.all(BorderSide(color: p.divider)),
            ),
            child: const Text('장바구니'),
          ),
        ),
        const SizedBox(width: mainDefaultSpacing),
        Expanded(
          child: ElevatedButton(
            onPressed: _buyNow,
            style: mainPrimaryButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(p.paymentButton),
              foregroundColor: WidgetStateProperty.all(p.paymentButtonText),
            ),
            child: const Text('바로구매'),
          ),
        ),
      ],
    );
  }
}

