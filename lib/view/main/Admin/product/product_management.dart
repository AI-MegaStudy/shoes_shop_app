import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/main/Admin/product/product_insert.dart';
import 'package:shoes_shop_app/view/main/Admin/product/product_management_detail.dart';
import 'package:shoes_shop_app/view/main/Admin/auth/admin_drawer_menu.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/model/product_join.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';

// 관리자 제품 관리 화면(제품 목록 보기 / 제품 등록 / 제품 수정 / 제품 삭제 / 제품 상세 보기, 제품 검색 기능)

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  late TextEditingController _searchController;

  /// 제품 목록 (전체)
  List<ProductJoin> _allProducts = [];

  /// 색상별로 그룹화된 제품 목록
  List<Map<String, dynamic>> _groupedProducts = [];

  /// 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 제품 목록 로드
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);

      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/products/with_categories',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final results = response.data!['results'] as List<dynamic>?;
        if (results != null) {
          setState(() {
            _allProducts = results.map((json) {
              // API 응답 필드명을 ProductJoin 모델 필드명에 맞게 변환
              return ProductJoin.fromJson({
                'p_seq': json['p_seq'],
                'p_name': json['p_name'],
                'p_price': json['p_price'],
                'p_stock': json['p_stock'],
                'p_image': json['p_image'],
                'kc_name': json['kind_name'],
                'cc_name': json['color_name'],
                'sc_name': json['size_name'],
                'gc_name': json['gender_name'],
                'm_name': json['maker_name'],
              });
            }).toList();
            
            // 색상별로 그룹화
            _groupProductsByColor();
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '오류',
          message: '제품 목록을 불러오는데 실패했습니다.',
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '오류',
          message: '제품 목록을 불러오는 중 오류가 발생했습니다.',
        );
      }
    }
  }


  /// 제품을 색상별로 그룹화
  void _groupProductsByColor() {
    // 제품명, 제조사, 종류, 색상이 같은 제품들을 하나로 그룹화
    final Map<String, List<ProductJoin>> grouped = {};
    
    for (var product in _allProducts) {
      // 그룹 키: 제품명_제조사_종류_색상
      final key = '${product.p_name ?? ""}_${product.m_name ?? ""}_${product.kc_name ?? ""}_${product.cc_name ?? ""}';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(product);
    }
    
    // 그룹화된 데이터를 리스트로 변환
    _groupedProducts = grouped.entries.map((entry) {
      final products = entry.value;
      // 대표 제품 선택 (첫 번째 제품 또는 이미지가 있는 제품)
      final representative = products.firstWhere(
        (p) => p.p_image != null && p.p_image!.isNotEmpty,
        orElse: () => products.first,
      );
      
      return {
        'key': entry.key,
        'representative': representative,
        'products': products,
        'color_name': representative.cc_name ?? '',
        'product_name': representative.p_name ?? '',
        'maker_name': representative.m_name ?? '',
        'kind_name': representative.kc_name ?? '',
      };
    }).toList();
    
    // 제품명 순으로 정렬
    _groupedProducts.sort((a, b) {
      final nameA = a['product_name'] as String;
      final nameB = b['product_name'] as String;
      return nameA.compareTo(nameB);
    });
  }

  /// 제품 상세 페이지로 이동
  void _viewProductDetail(Map<String, dynamic> groupedProduct) {
    // Get.to를 사용하여 제품 상세 페이지로 이동
    Get.to(() => ProductManagementDetail(
      groupedProduct: groupedProduct,
    ));
  }

  /// 제품 등록 페이지로 이동
  void _navigateToProductCreate() {
    // Get.to를 사용하여 제품 등록 페이지로 이동
    Get.to(() => ProductInsert());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: const Text('제품 관리'),
            centerTitle: mainAppBarCenterTitle,
            titleTextStyle: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
            actions: [
              IconButton(
                onPressed: _navigateToProductCreate,
                icon: Icon(Icons.add, color: p.textPrimary),
              ),
            ],
          ),
          drawer: const AdminDrawerMenu(),
          body: SafeArea(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: p.primary),
                  )
                : _groupedProducts.isEmpty
                    ? Center(
                        child: Text(
                          '등록된 제품이 없습니다.',
                          style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: p.primary,
                        child: ListView.builder(
                          padding: mainDefaultPadding,
                          itemCount: _groupedProducts.length,
                          itemBuilder: (context, index) {
                            final groupedProduct = _groupedProducts[index];
                            return _buildProductCard(groupedProduct);
                          },
                        ),
                      ),
          ),
        );
      },
    );
  }

  /// 제품 카드 위젯 (색상별 그룹화된 제품)
  Widget _buildProductCard(Map<String, dynamic> groupedProduct) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        final representative = groupedProduct['representative'] as ProductJoin;
        final productName = groupedProduct['product_name'] as String;
        final makerName = groupedProduct['maker_name'] as String;
        final kindName = groupedProduct['kind_name'] as String;
        final colorName = groupedProduct['color_name'] as String;
        final products = groupedProduct['products'] as List<ProductJoin>;
        
        // 총 재고 계산
        final totalStock = products.fold<int>(
          0,
          (sum, product) => sum + (product.p_stock ?? 0),
        );
        
        return Card(
          elevation: mainProductCardElevation,
          margin: const EdgeInsets.only(bottom: 12),
          color: p.productCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(mainProductCardBorderRadius),
          ),
          child: InkWell(
            onTap: () => _viewProductDetail(groupedProduct),
            borderRadius: BorderRadius.circular(mainProductCardBorderRadius),
            child: Padding(
              padding: mainDefaultPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제품 이미지
                  Container(
                    width: mainProductImageWidth,
                    height: mainProductImageHeight,
                    decoration: BoxDecoration(
                      color: p.divider,
                      borderRadius: mainSmallBorderRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: mainSmallBorderRadius,
                      child: Image.network(
                        'https://cheng80.myqnapcloud.com/images/${representative.p_image ?? ''}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: p.textSecondary,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: mainDefaultSpacing),
                  // 제품 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: mainProductNameStyle.copyWith(color: p.textPrimary),
                        ),
                        SizedBox(height: mainSmallSpacing),
                        Text(
                          '$makerName | $kindName',
                          style: mainProductSubInfoStyle.copyWith(color: p.textSecondary),
                        ),
                        SizedBox(height: mainSmallSpacing),
                        Text(
                          '색상: $colorName | 사이즈: ${products.length}개',
                          style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                        ),
                        SizedBox(height: mainSmallSpacing),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CustomCommonUtil.formatPrice(representative.p_price ?? 0),
                              style: mainPriceSmallStyle.copyWith(color: p.priceHighlight),
                            ),
                            Container(
                              padding: mainSmallPadding,
                              decoration: BoxDecoration(
                                color: totalStock > 0
                                    ? p.stockAvailable.withOpacity(0.2)
                                    : p.stockOut.withOpacity(0.2),
                                borderRadius: mainSmallBorderRadius,
                              ),
                              child: Text(
                                '총 재고: $totalStock',
                                style: mainSmallTextStyle.copyWith(
                                  color: totalStock > 0
                                      ? p.stockAvailable
                                      : p.stockOut,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //----Function Start----
  // (태블릿 관련 함수는 admin_tablet_utils.dart로 이동)

  //----Function End----
}

