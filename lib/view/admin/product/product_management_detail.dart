import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/admin/product/product_update.dart';
import 'package:shoes_shop_app/model/product_join.dart';

/// 제품 관리 상세 화면
/// 색상과 사이즈를 선택할 수 있고, Edit/Delete 버튼 제공
class ProductManagementDetail extends StatefulWidget {
  final Map<String, dynamic> groupedProduct;

  const ProductManagementDetail({
    super.key,
    required this.groupedProduct,
  });

  @override
  State<ProductManagementDetail> createState() => _ProductManagementDetailState();
}

class _ProductManagementDetailState extends State<ProductManagementDetail> {
  /// 선택된 색상
  String? _selectedColorName;
  
  /// 선택된 사이즈
  String? _selectedSizeName;
  
  /// 선택된 제품
  ProductJoin? _selectedProduct;

  /// 사용 가능한 색상 목록 (같은 제품의 다른 색상들)
  List<String> _availableColors = [];
  
  /// 선택된 색상의 사용 가능한 사이즈 목록
  List<String> _availableSizes = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// 데이터 초기화
  void _initializeData() {
    final products = widget.groupedProduct['products'] as List<ProductJoin>;
    
    // 사용 가능한 색상 목록 추출 (중복 제거)
    final colorSet = <String>{};
    for (var product in products) {
      if (product.cc_name != null && product.cc_name!.isNotEmpty) {
        colorSet.add(product.cc_name!);
      }
    }
    _availableColors = colorSet.toList()..sort();
    
    // 기본 색상 선택 (첫 번째 색상 또는 그룹의 대표 색상)
    final representative = widget.groupedProduct['representative'] as ProductJoin;
    _selectedColorName = representative.cc_name ?? _availableColors.firstOrNull;
    
    _updateAvailableSizes();
  }

  /// 선택된 색상에 따라 사용 가능한 사이즈 목록 업데이트
  void _updateAvailableSizes() {
    if (_selectedColorName == null) {
      _availableSizes = [];
      _selectedSizeName = null;
      _selectedProduct = null;
      return;
    }

    final products = widget.groupedProduct['products'] as List<ProductJoin>;
    
    // 선택된 색상의 제품들만 필터링
    final colorProducts = products.where(
      (p) => p.cc_name == _selectedColorName,
    ).toList();
    
    // 사이즈 목록 추출 (중복 제거)
    final sizeSet = <String>{};
    for (var product in colorProducts) {
      if (product.sc_name != null && product.sc_name!.isNotEmpty) {
        sizeSet.add(product.sc_name!);
      }
    }
    _availableSizes = sizeSet.toList()..sort();
    
    // 기본 사이즈 선택 (첫 번째 사이즈)
    if (_availableSizes.isNotEmpty) {
      _selectedSizeName = _availableSizes.first;
      _updateSelectedProduct();
    } else {
      _selectedSizeName = null;
      _selectedProduct = null;
    }
  }

  /// 선택된 색상과 사이즈에 따라 제품 찾기
  void _updateSelectedProduct() {
    if (_selectedColorName == null || _selectedSizeName == null) {
      _selectedProduct = null;
      return;
    }

    final products = widget.groupedProduct['products'] as List<ProductJoin>;
    
    // 색상과 사이즈가 일치하는 제품 찾기
    _selectedProduct = products.firstWhere(
      (p) => p.cc_name == _selectedColorName && p.sc_name == _selectedSizeName,
      orElse: () => products.first, // 일치하는 제품이 없으면 첫 번째 제품
    );
  }

  /// 색상 선택
  void _selectColor(String colorName) {
    setState(() {
      _selectedColorName = colorName;
      _updateAvailableSizes();
    });
  }

  /// 사이즈 선택
  void _selectSize(String sizeName) {
    setState(() {
      _selectedSizeName = sizeName;
      _updateSelectedProduct();
    });
  }

  /// Edit 버튼 클릭
  void _onEditPressed() {
    if (_selectedProduct == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '제품을 선택해주세요.',
      );
      return;
    }

    // 제품 수정 페이지로 이동
    Get.to(() => ProductUpdate(product: _selectedProduct!));
  }

  /// Delete 버튼 클릭
  void _onDeletePressed() {
    if (_selectedProduct == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '제품을 선택해주세요.',
      );
      return;
    }

    // 일단 간단한 스넥바만 표시
    CustomCommonUtil.showSuccessSnackbar(
      context: context,
      title: '알림',
      message: '삭제 기능은 준비 중입니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final representative = widget.groupedProduct['representative'] as ProductJoin;
    final productName = widget.groupedProduct['product_name'] as String;
    final makerName = widget.groupedProduct['maker_name'] as String;
    final kindName = widget.groupedProduct['kind_name'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('제품 상세'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지와 기본 정보를 Row로 배치
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제품 이미지
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://cheng80.myqnapcloud.com/images/${representative.p_image ?? ''}',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 64);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // 제품 기본 정보 및 선택 옵션 (Column)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제품 기본 정보
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$makerName | $kindName',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 색상 선택
                      const Text(
                        '색상 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableColors.map((colorName) {
                          final isSelected = _selectedColorName == colorName;
                          return ChoiceChip(
                            label: Text(colorName),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _selectColor(colorName);
                              }
                            },
                            selectedColor: Colors.blue[100],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.blue[900] : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // 사이즈 선택
                      const Text(
                        '사이즈 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _availableSizes.isEmpty
                          ? const Text(
                              '선택한 색상의 사이즈가 없습니다.',
                              style: TextStyle(color: Colors.grey),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedSizeName,
                              decoration: const InputDecoration(
                                labelText: '사이즈',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _availableSizes.map((sizeName) {
                                return DropdownMenuItem<String>(
                                  value: sizeName,
                                  child: Text(sizeName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _selectSize(value);
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 선택된 제품 정보
            if (_selectedProduct != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '선택된 제품 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('가격: ${(_selectedProduct!.p_price ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'),
                    Text('재고: ${_selectedProduct!.p_stock ?? 0}'),
                    Text('성별: ${_selectedProduct!.gc_name ?? ''}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Edit / Delete 버튼
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onEditPressed,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onDeletePressed,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

