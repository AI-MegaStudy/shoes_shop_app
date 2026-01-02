import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/admin/product/product_insert.dart';
import 'package:shoes_shop_app/view/admin/product/product_management_detail.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/model/product_join.dart';

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
    Get.to(() => const ProductInsert());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제품 관리'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _navigateToProductCreate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _groupedProducts.isEmpty
                ? const Center(
                    child: Text('등록된 제품이 없습니다.'),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _groupedProducts.length,
                      itemBuilder: (context, index) {
                        final groupedProduct = _groupedProducts[index];
                        return _buildProductCard(groupedProduct);
                      },
                    ),
                  ),
      ),
    );
  }

  /// 제품 카드 위젯 (색상별 그룹화된 제품)
  Widget _buildProductCard(Map<String, dynamic> groupedProduct) {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewProductDetail(groupedProduct),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제품 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://cheng80.myqnapcloud.com/images/${representative.p_image ?? ''}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 제품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$makerName | $kindName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '색상: $colorName | 사이즈: ${products.length}개',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(representative.p_price ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: totalStock > 0
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '총 재고: $totalStock',
                            style: TextStyle(
                              fontSize: 12,
                              color: totalStock > 0
                                  ? Colors.green[800]
                                  : Colors.red[800],
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
  }

  //----Function Start----
  // (태블릿 관련 함수는 admin_tablet_utils.dart로 이동)

  //----Function End----
}
