import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/model/maker.dart';
import 'package:shoes_shop_app/model/kind_category.dart';
import 'package:shoes_shop_app/model/color_category.dart';
import 'package:shoes_shop_app/model/size_category.dart';
import 'package:shoes_shop_app/model/gender_category.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/view/main/user/product/main_product_detail.dart';
import 'package:shoes_shop_app/view/main/user/menu/main_user_drawer_menu.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:http/http.dart' as http;

/// 메인 제품 목록 페이지
/// 
/// 제품 목록을 그리드 레이아웃으로 표시하고, 필터링 및 검색 기능을 제공합니다.
/// 같은 제품명의 다른 색상은 각각 개별 카드로 표시됩니다.
class MainProductList extends StatefulWidget {
  const MainProductList({super.key});

  @override
  State<MainProductList> createState() => _MainProductListState();
}

class _MainProductListState extends State<MainProductList> {
  /// 검색바 컨트롤러
  late TextEditingController _searchController;

  /// 제품 목록
  List<Product> _products = [];

  /// 필터링용 카테고리 목록
  List<Maker> _makers = [];
  List<KindCategory> _kindCategories = [];
  List<ColorCategory> _colorCategories = [];
  List<SizeCategory> _sizeCategories = [];
  List<GenderCategory> _genderCategories = [];

  /// 선택된 필터
  int? _selectedMakerSeq;
  int? _selectedKindSeq;
  int? _selectedColorSeq;
  int? _selectedSizeSeq;
  int? _selectedGenderSeq;

  /// 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCategories();
    _loadProducts();
    // API base URL 설정
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 카테고리 목록 로드
  Future<void> _loadCategories() async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);

      final results = await Future.wait([
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/makers',
          fromJson: (json) => json,
        ),
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/kind_categories',
          fromJson: (json) => json,
        ),
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

      setState(() {
        if (results[0].success && results[0].data != null) {
          _makers = (results[0].data!['results'] as List<dynamic>?)
                  ?.map((e) => Maker.fromJson(e))
                  .toList() ??
              [];
        }
        if (results[1].success && results[1].data != null) {
          _kindCategories = (results[1].data!['results'] as List<dynamic>?)
                  ?.map((e) => KindCategory.fromJson(e))
                  .toList() ??
              [];
        }
        if (results[2].success && results[2].data != null) {
          _colorCategories = (results[2].data!['results'] as List<dynamic>?)
                  ?.map((e) => ColorCategory.fromJson(e))
                  .toList() ??
              [];
        }
        if (results[3].success && results[3].data != null) {
          _sizeCategories = (results[3].data!['results'] as List<dynamic>?)
                  ?.map((e) => SizeCategory.fromJson(e))
                  .toList() ??
              [];
        }
        if (results[4].success && results[4].data != null) {
          _genderCategories = (results[4].data!['results'] as List<dynamic>?)
                  ?.map((e) => GenderCategory.fromJson(e))
                  .toList() ??
              [];
        }
      });
    } catch (e) {
      debugPrint('카테고리 로드 오류: $e');
    }
  }

  /// 제품 목록 로드
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);

      // 필터링 파라미터 구성
      final Map<String, String> queryParams = {};
      if (_selectedMakerSeq != null) {
        queryParams['maker_seq'] = _selectedMakerSeq.toString();
      }
      if (_selectedKindSeq != null) {
        queryParams['kind_seq'] = _selectedKindSeq.toString();
      }
      if (_selectedColorSeq != null) {
        queryParams['color_seq'] = _selectedColorSeq.toString();
      }
      if (_selectedSizeSeq != null) {
        queryParams['size_seq'] = _selectedSizeSeq.toString();
      }
      if (_selectedGenderSeq != null) {
        queryParams['gender_seq'] = _selectedGenderSeq.toString();
      }

      String url = '$apiBaseUrl/api/products/with_categories';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url += '?$queryString';
      }

      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(utf8.decode(response.bodyBytes));

      if (jsonData['results'] != null) {
        // 모든 제품을 먼저 파싱
        final allProducts = (jsonData['results'] as List)
            .map((d) {
              // 카테고리 이름으로 seq 찾기
              final kindSeq = _kindCategories.firstWhere(
                (k) => k.kc_name == d['kind_name'],
                orElse: () => KindCategory(kc_seq: 1, kc_name: d['kind_name'] ?? ''),
              ).kc_seq ?? 1;
              
              final colorSeq = _colorCategories.firstWhere(
                (c) => c.cc_name == d['color_name'],
                orElse: () => ColorCategory(cc_seq: 1, cc_name: d['color_name'] ?? ''),
              ).cc_seq ?? 1;
              
              final sizeSeq = _sizeCategories.firstWhere(
                (s) => s.sc_name == d['size_name'],
                orElse: () => SizeCategory(sc_seq: 1, sc_name: d['size_name'] ?? ''),
              ).sc_seq;
              
              final genderSeq = _genderCategories.firstWhere(
                (g) => g.gc_name == d['gender_name'],
                orElse: () => GenderCategory(gc_seq: 1, gc_name: d['gender_name'] ?? ''),
              ).gc_seq ?? 1;
              
              final makerSeq = _makers.firstWhere(
                (m) => m.m_name == d['maker_name'],
                orElse: () => Maker(m_seq: 1, m_name: d['maker_name'] ?? '', m_phone: '', m_address: ''),
              ).m_seq ?? 1;
              
              return Product.fromJson({
                'p_seq': d['p_seq'],
                'kc_seq': kindSeq,
                'cc_seq': colorSeq,
                'sc_seq': sizeSeq,
                'gc_seq': genderSeq,
                'm_seq': makerSeq,
                'p_name': d['p_name'],
                'p_price': d['p_price'],
                'p_stock': d['p_stock'],
                'p_image': d['p_image'],
                'p_description': d['p_description'] ?? '',
                'p_color': d['color_name'],
                'p_size': d['size_name'],
                'p_gender': d['gender_name'],
                'p_maker': d['maker_name'],
              });
            })
            .toList();

        // 제품명(p_name) + 제조사명(p_maker) + 색상명(p_color) 기준으로 그룹화
        // 같은 제품명과 제조사와 색상 조합은 하나의 카드로만 표시 (사이즈, 성별 무시)
        // maker_name을 직접 사용하여 키 생성 (m_seq 매칭 오류 방지)
        // 가장 작은 사이즈(sc_seq가 가장 작은) 제품을 대표로 선택
        final Map<String, Product> groupedProducts = {};
        for (final product in allProducts) {
          // 그룹 키: 제품명_제조사명_색상명 (문자열로 직접 비교)
          final key = '${product.p_name}_${product.p_maker ?? ''}_${product.p_color ?? ''}';
          if (!groupedProducts.containsKey(key)) {
            // 해당 조합의 첫 번째 제품을 대표로 선택
            groupedProducts[key] = product;
          } else {
            // 이미 있는 경우, 사이즈가 더 작은 제품으로 교체 (sc_seq가 작을수록 작은 사이즈)
            final existingProduct = groupedProducts[key]!;
            if (product.sc_seq < existingProduct.sc_seq) {
              groupedProducts[key] = product;
            }
          }
        }

        setState(() {
          // 그룹화된 제품 목록을 리스트로 변환 (색상별로 하나씩만 표시)
          _products = groupedProducts.values.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar(
          '오류',
          '제품 목록을 불러오는데 실패했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// 검색 실행
  void _searchProducts() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      _loadProducts();
      return;
    }

    // 검색 API 호출
    _loadProducts();
  }

  /// 필터 초기화
  void _resetFilters() {
    setState(() {
      _selectedMakerSeq = null;
      _selectedKindSeq = null;
      _selectedColorSeq = null;
      _selectedSizeSeq = null;
      _selectedGenderSeq = null;
    });
    _loadProducts();
  }

  /// 제품 상세 페이지로 이동
  void _navigateToDetail(Product product) {
    Get.to(
      () => const MainProductDetail(),
      arguments: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoes Shop'),
        titleTextStyle: mainAppBarTitleStyle,
        centerTitle: mainAppBarCenterTitle,
      ),
      drawer: const MainUserDrawerMenu(),
      body: SafeArea(
        child: Column(
          children: [
          // 검색바
          Padding(
                    padding: mainDefaultPadding,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _searchProducts(),
                            decoration: InputDecoration(
                              hintText: '원하는 신발을 찾아보아요',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(mainSearchBarBorderRadius),
                              ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchProducts();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {}); // suffixIcon 업데이트를 위한 상태 갱신
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final p = context.palette;
                    return ElevatedButton.icon(
                      onPressed: _searchProducts,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: p.primary,
                        foregroundColor: p.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(mainSearchBarBorderRadius),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('검색'),
                    );
                  },
                ),
              ],
            ),
          ),
          // 필터 영역
          Builder(
            builder: (context) {
              final p = context.palette;
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // 필터 초기화 버튼
                    if (_selectedMakerSeq != null ||
                        _selectedKindSeq != null ||
                        _selectedColorSeq != null ||
                        _selectedSizeSeq != null ||
                        _selectedGenderSeq != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('초기화'),
                          onSelected: (_) => _resetFilters(),
                          backgroundColor: p.filterInactive,
                          labelStyle: TextStyle(color: p.textPrimary),
                        ),
                      ),
                    // 제조사 필터
                    if (_makers.isNotEmpty)
                      Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_selectedMakerSeq != null
                          ? _makers.firstWhere((m) => m.m_seq == _selectedMakerSeq).m_name
                          : '제조사'),
                      selected: _selectedMakerSeq != null,
                      onSelected: (selected) {
                        if (selected) {
                          _showMakerFilter();
                        } else {
                          setState(() {
                            _selectedMakerSeq = null;
                          });
                          _loadProducts();
                        }
                      },
                    ),
                  ),
                    // 종류 필터
                    if (_kindCategories.isNotEmpty)
                      Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_selectedKindSeq != null
                          ? _kindCategories.firstWhere((k) => k.kc_seq == _selectedKindSeq).kc_name
                          : '종류'),
                      selected: _selectedKindSeq != null,
                      onSelected: (selected) {
                        if (selected) {
                          _showKindFilter();
                        } else {
                          setState(() {
                            _selectedKindSeq = null;
                          });
                          _loadProducts();
                        }
                      },
                    ),
                  ),
                    // 색상 필터
                    if (_colorCategories.isNotEmpty)
                      Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_selectedColorSeq != null
                          ? _colorCategories.firstWhere((c) => c.cc_seq == _selectedColorSeq).cc_name
                          : '색상'),
                      selected: _selectedColorSeq != null,
                      onSelected: (selected) {
                        if (selected) {
                          _showColorFilter();
                        } else {
                          setState(() {
                            _selectedColorSeq = null;
                          });
                          _loadProducts();
                        }
                      },
                    ),
                  ),
                    // 사이즈 필터
                    if (_sizeCategories.isNotEmpty)
                      Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_selectedSizeSeq != null
                          ? _sizeCategories.firstWhere((s) => s.sc_seq == _selectedSizeSeq).sc_name
                          : '사이즈'),
                      selected: _selectedSizeSeq != null,
                      onSelected: (selected) {
                        if (selected) {
                          _showSizeFilter();
                        } else {
                          setState(() {
                            _selectedSizeSeq = null;
                          });
                          _loadProducts();
                        }
                      },
                    ),
                  ),
                    // 성별 필터
                    if (_genderCategories.isNotEmpty)
                      Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_selectedGenderSeq != null
                          ? _genderCategories.firstWhere((g) => g.gc_seq == _selectedGenderSeq).gc_name
                          : '성별'),
                      selected: _selectedGenderSeq != null,
                      onSelected: (selected) {
                        if (selected) {
                          _showGenderFilter();
                        } else {
                          setState(() {
                            _selectedGenderSeq = null;
                          });
                          _loadProducts();
                        }
                      },
                    ),
                  ),
                  ],
                ),
              );
            },
          ),
          // 제품 그리드
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('제품이 없습니다.'))
                    : GridView.builder(
                        padding: mainDefaultPadding,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(_products[index]);
                        },
                      ),
          ),
        ],
        ),
      ),
    );
  }

  /// 제품 카드 위젯
  Widget _buildProductCard(Product product) {
    final p = context.palette;
    final imageUrl = 'https://cheng80.myqnapcloud.com/images/${product.p_image}';

    return GestureDetector(
      onTap: () => _navigateToDetail(product),
      child: Card(
        elevation: mainProductCardElevation,
        color: p.productCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mainProductCardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제품 이미지
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(mainProductCardBorderRadius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(mainProductCardBorderRadius),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                ),
              ),
            ),
            // 제품 정보
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.p_name,
                    style: mainProductNameStyle.copyWith(color: p.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.p_maker ?? ''} / ${product.p_color ?? ''}',
                    style: mainProductSubInfoStyle.copyWith(color: p.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.p_price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: mainPriceSmallStyle.copyWith(color: p.priceHighlight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 제조사 필터 선택 다이얼로그
  void _showMakerFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: mainDefaultPadding,
                child: Text(
                  '제조사 선택',
                  style: mainTitleStyle,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _makers.length,
                  itemBuilder: (context, index) {
                    final maker = _makers[index];
                    return ListTile(
                      title: Text(maker.m_name),
                      onTap: () {
                        setState(() {
                          _selectedMakerSeq = maker.m_seq;
                        });
                        Get.back();
                        _loadProducts();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 종류 필터 선택 다이얼로그
  void _showKindFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: mainDefaultPadding,
                child: Text(
                  '종류 선택',
                  style: mainTitleStyle,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _kindCategories.length,
                  itemBuilder: (context, index) {
                    final kind = _kindCategories[index];
                    return ListTile(
                      title: Text(kind.kc_name),
                      onTap: () {
                        setState(() {
                          _selectedKindSeq = kind.kc_seq;
                        });
                        Get.back();
                        _loadProducts();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 색상 필터 선택 다이얼로그
  void _showColorFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: mainDefaultPadding,
                child: Text(
                  '색상 선택',
                  style: mainTitleStyle,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _colorCategories.length,
                  itemBuilder: (context, index) {
                    final color = _colorCategories[index];
                    return ListTile(
                      title: Text(color.cc_name),
                      onTap: () {
                        setState(() {
                          _selectedColorSeq = color.cc_seq;
                        });
                        Get.back();
                        _loadProducts();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 사이즈 필터 선택 다이얼로그
  void _showSizeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: mainDefaultPadding,
                child: Text(
                  '사이즈 선택',
                  style: mainTitleStyle,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _sizeCategories.length,
                  itemBuilder: (context, index) {
                    final size = _sizeCategories[index];
                    return ListTile(
                      title: Text(size.sc_name),
                      onTap: () {
                        setState(() {
                          _selectedSizeSeq = size.sc_seq;
                        });
                        Get.back();
                        _loadProducts();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 성별 필터 선택 다이얼로그
  void _showGenderFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: mainDefaultPadding,
                child: Text(
                  '성별 선택',
                  style: mainTitleStyle,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _genderCategories.length,
                  itemBuilder: (context, index) {
                    final gender = _genderCategories[index];
                    return ListTile(
                      title: Text(gender.gc_name),
                      onTap: () {
                        setState(() {
                          _selectedGenderSeq = gender.gc_seq;
                        });
                        Get.back();
                        _loadProducts();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

