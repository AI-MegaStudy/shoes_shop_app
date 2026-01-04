import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/main/Admin/product/product_update.dart';
import 'package:shoes_shop_app/model/product_join.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:http/http.dart' as http;

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

  /// 재고 수정 버튼 클릭
  void _onStockEditPressed() {
    if (_selectedProduct == null || _selectedProduct!.p_seq == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '제품을 선택해주세요.',
      );
      return;
    }

    _showStockEditDialog();
  }

  /// 재고 수정 다이얼로그 표시
  void _showStockEditDialog() {
    final currentStock = _selectedProduct!.p_stock ?? 0;
    final stockController = TextEditingController(text: currentStock.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        final p = context.palette;
        return AlertDialog(
          backgroundColor: p.cardBackground,
          title: Text(
            '재고 수정',
            style: mainTitleStyle.copyWith(color: p.textPrimary),
          ),
          content: TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '재고 수량',
              border: const OutlineInputBorder(),
              labelStyle: TextStyle(color: p.textSecondary),
            ),
            style: TextStyle(color: p.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '취소',
                style: TextStyle(color: p.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newStock = int.tryParse(stockController.text);
                if (newStock == null || newStock < 0) {
                  CustomCommonUtil.showErrorSnackbar(
                    context: context,
                    title: '오류',
                    message: '올바른 재고 수량을 입력해주세요.',
                  );
                  return;
                }
                
                Get.back();
                await _updateStock(newStock);
              },
              child: Text(
                '확인',
                style: TextStyle(color: p.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 재고 업데이트
  Future<void> _updateStock(int newStock) async {
    if (_selectedProduct == null || _selectedProduct!.p_seq == null) {
      return;
    }

    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
    
    try {
      final baseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl/api/products/${_selectedProduct!.p_seq}/stock');
      
      final response = await http.post(
        uri,
        body: {'p_stock': newStock.toString()},
      );

      if (response.statusCode == 200) {
        // 재고 업데이트 성공
        setState(() {
          _selectedProduct!.p_stock = newStock;
        });
        
        // 그룹화된 제품 목록도 업데이트
        final products = widget.groupedProduct['products'] as List<ProductJoin>;
        for (var product in products) {
          if (product.p_seq == _selectedProduct!.p_seq) {
            product.p_stock = newStock;
            break;
          }
        }

        CustomCommonUtil.showSuccessSnackbar(
          context: context,
          title: '성공',
          message: '재고가 수정되었습니다.',
        );
      } else {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '오류',
          message: '재고 수정에 실패했습니다.',
        );
      }
    } catch (e) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '재고 수정 중 오류가 발생했습니다: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        final representative = widget.groupedProduct['representative'] as ProductJoin;
        final productName = widget.groupedProduct['product_name'] as String;
        final makerName = widget.groupedProduct['maker_name'] as String;
        final kindName = widget.groupedProduct['kind_name'] as String;

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: const Text('제품 상세'),
            centerTitle: mainAppBarCenterTitle,
            titleTextStyle: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: mainDefaultPadding,
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
                      color: p.divider,
                      borderRadius: mainDefaultBorderRadius,
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: mainDefaultBorderRadius,
                        child: Image.network(
                          'https://cheng80.myqnapcloud.com/images/${representative.p_image ?? ''}',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: p.textSecondary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: mainLargeSpacing),
                // 제품 기본 정보 및 선택 옵션 (Column)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제품 기본 정보
                      Text(
                        productName,
                        style: mainLargeTitleStyle.copyWith(color: p.textPrimary),
                      ),
                      SizedBox(height: mainSmallSpacing),
                      Text(
                        '$makerName | $kindName',
                        style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                      ),
                      SizedBox(height: mainLargeSpacing),
                      
                      // 색상 선택
                      Text(
                        '색상 선택',
                        style: mainTitleStyle.copyWith(color: p.textPrimary),
                      ),
                      SizedBox(height: mainDefaultSpacing),
                      Wrap(
                        spacing: mainSmallSpacing,
                        runSpacing: mainSmallSpacing,
                        children: _availableColors.map((colorName) {
                          final isSelected = _selectedColorName == colorName;
                          return Builder(
                            builder: (context) {
                              final p = context.palette;
                              return ChoiceChip(
                                label: Text(colorName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _selectColor(colorName);
                                  }
                                },
                                selectedColor: p.chipSelectedBg,
                                labelStyle: TextStyle(
                                  color: isSelected ? p.chipSelectedText : p.chipUnselectedText,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: mainLargeSpacing),
                      
                      // 사이즈 선택
                      Text(
                        '사이즈 선택',
                        style: mainTitleStyle.copyWith(color: p.textPrimary),
                      ),
                      SizedBox(height: mainDefaultSpacing),
                      _availableSizes.isEmpty
                          ? Text(
                              '선택한 색상의 사이즈가 없습니다.',
                              style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                            )
                          : Builder(
                              builder: (context) {
                                final p = context.palette;
                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedSizeName,
                                  decoration: InputDecoration(
                                    labelText: '사이즈',
                                    border: const OutlineInputBorder(),
                                    contentPadding: mainMediumPadding,
                                    labelStyle: TextStyle(color: p.textSecondary),
                                  ),
                                  dropdownColor: p.cardBackground,
                                  style: TextStyle(color: p.textPrimary),
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
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: mainLargeSpacing * 2),

            // 선택된 제품 정보
            if (_selectedProduct != null) ...[
              Builder(
                builder: (context) {
                  final p = context.palette;
                  return Container(
                    padding: mainDefaultPadding,
                    decoration: BoxDecoration(
                      color: p.cardBackground,
                      borderRadius: mainDefaultBorderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선택된 제품 정보',
                          style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
                        ),
                        SizedBox(height: mainSmallSpacing),
                        Text(
                          '가격: ${CustomCommonUtil.formatPrice(_selectedProduct!.p_price ?? 0)}',
                          style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                        ),
                        Row(
                          children: [
                            Text(
                              '재고: ${_selectedProduct!.p_stock ?? 0}',
                              style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                            ),
                            SizedBox(width: mainSmallSpacing),
                            IconButton(
                              icon: Icon(Icons.edit, size: 18, color: p.primary),
                              onPressed: _onStockEditPressed,
                              tooltip: '재고 수정',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        Text(
                          '성별: ${_selectedProduct!.gc_name ?? ''}',
                          style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: mainLargeSpacing),
            ],

            // Edit / Delete 버튼
            Builder(
              builder: (context) {
                final p = context.palette;
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onEditPressed,
                        icon: Icon(Icons.edit, color: p.textOnPrimary),
                        label: const Text('Edit'),
                        style: mainPrimaryButtonStyle.copyWith(
                          backgroundColor: WidgetStateProperty.all(p.primary),
                          foregroundColor: WidgetStateProperty.all(p.textOnPrimary),
                        ),
                      ),
                    ),
                    SizedBox(width: mainDefaultSpacing),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onDeletePressed,
                        icon: Icon(Icons.delete, color: p.textOnPrimary),
                        label: const Text('Delete'),
                        style: mainPrimaryButtonStyle.copyWith(
                          backgroundColor: WidgetStateProperty.all(p.stockOut),
                          foregroundColor: WidgetStateProperty.all(p.textOnPrimary),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

