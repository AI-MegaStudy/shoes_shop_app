import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/theme/palette_context.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment/cart_view.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment/user_purchase_list.dart';
import 'package:shoes_shop_app/view/user/product/list_view.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment_config.dart' show defaultButtonHeight, boldLabelStyle, defaultSpacing, largeSpacing;

class PaymentPreview extends StatefulWidget {
  const PaymentPreview({super.key});

  @override
  State<PaymentPreview> createState() => _PaymentPreviewState();
}

class _PaymentPreviewState extends State<PaymentPreview> {
  //Property
  //late 는 초기화를 나중으로 미룸

  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
    
  }
  
  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text("Hello"),
             // 상품 조회 버튼
              ElevatedButton(
                onPressed: () => Get.to(() => const ProductListView()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.textOnPrimary,
                  minimumSize: Size(double.infinity, defaultButtonHeight),
                ),
                child: Text(
                  '상품 조회',
                  style: boldLabelStyle.copyWith(color: p.textOnPrimary),
                ),
              ),
              
              SizedBox(height: defaultSpacing),
              
              // 장바구니 버튼 (cart.dart로 이동)
              ElevatedButton(
                onPressed: () {
                  final cart = CartStorage.getCart();
                  if (cart.isEmpty) {
                    Get.snackbar(
                      '알림',
                      '장바구니가 비어있습니다.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  Get.to(() => const CartView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.textOnPrimary,
                  minimumSize: Size(double.infinity, defaultButtonHeight),
                ),
                child: Text(
                  '장바구니',
                  style: boldLabelStyle.copyWith(color: p.textOnPrimary),
                ),
              ),
              
              SizedBox(height: defaultSpacing),
              
              // 주문 내역 버튼
              OutlinedButton(
                onPressed: () => Get.to(() => const UserPurchaseList()),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, defaultButtonHeight),
                ),
                child: Text(
                  '주문 내역',
                  style: boldLabelStyle.copyWith(color: p.textPrimary),
                ),
              ),
              
              SizedBox(height: defaultSpacing),
              
              
              SizedBox(height: largeSpacing),
              const Divider(),
              SizedBox(height: largeSpacing),
              
              // 더미 데이터 장바구니 추가 버튼
              OutlinedButton(
                onPressed: () => addDummyProductsToCart(3),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, defaultButtonHeight),
                ),
                child: Text(
                  '더미 상품 3개 장바구니에 추가',
                  style: boldLabelStyle.copyWith(color: p.textPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }


  //--------Functions ------------
  /// 더미 Product 데이터를 장바구니에 추가하는 함수
  /// API에서 상품 목록을 가져와서 처음 몇 개를 장바구니에 추가합니다.
  static Future<void> addDummyProductsToCart(int count) async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);
      
      // 상품 목록 조회 (카테고리 정보 포함)
      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/products/with_categories',
        fromJson: (json) => json,
      );

      if (!response.success || response.data == null) {
        final errorMsg = response.error ?? '알 수 없는 오류';
        Get.snackbar(
          '오류',
          '상품 목록을 불러올 수 없습니다.\n$errorMsg',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final productsData = response.data!['results'] as List<dynamic>?;
      if (productsData == null || productsData.isEmpty) {
        Get.snackbar(
          '알림',
          '등록된 상품이 없습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 각각 다른 종류와 색상의 상품을 선택
      // Set을 사용하여 (kind_name, color_name) 조합 추적
      final Set<String> selectedCombinations = {};
      final List<Map<String, dynamic>> selectedProducts = [];
      
      for (final product in productsData) {
        final kindName = product['kind_name'] as String? ?? '';
        final colorName = product['color_name'] as String? ?? '';
        final combination = '$kindName|$colorName';
        
        // 이미 선택된 조합이 아니고, 필요한 개수만큼만 선택
        if (!selectedCombinations.contains(combination) && selectedProducts.length < count) {
          selectedCombinations.add(combination);
          selectedProducts.add(product);
        }
        
        // 필요한 개수만큼 선택되면 종료
        if (selectedProducts.length >= count) {
          break;
        }
      }
      
      // 선택된 상품들의 상세 정보를 가져와서 장바구니에 추가
      int addedCount = 0;
      int failedCount = 0;
      for (final product in selectedProducts) {
        final productSeq = product['p_seq'] as int?;
        
        if (productSeq == null) {
          failedCount++;
          continue;
        }

        try {
          // 상품 상세 정보 조회 (색상, 사이즈 정보 포함)
          final detailResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
            '/api/products/$productSeq/full_detail',
            fromJson: (json) => json,
          );

          if (detailResponse.success && detailResponse.data != null) {
            final detail = detailResponse.data!['result'] as Map<String, dynamic>?;
            if (detail == null) {
              failedCount++;
              continue;
            }

            final colorCategory = detail['color_category'] as Map<String, dynamic>?;
            final sizeCategory = detail['size_category'] as Map<String, dynamic>?;

            // CartStorage.addToCart가 요구하는 필드 구조에 맞춰서 cartItem 생성
            // full_detail API 응답의 color_category, size_category를 우선 사용
            final cartItem = {
              'p_seq': productSeq,
              'p_name': detail['p_name'] ?? product['p_name'] ?? '상품명 없음',
              'p_price': detail['p_price'] ?? product['p_price'] ?? 0,
              'p_image': detail['p_image'] ?? product['p_image'] ?? '',
              // color_category, size_category는 full_detail API에서만 제공되므로 필수값으로 처리
              // fallback이 필요한 경우 (API 호출 실패 등)에는 0으로 설정
              'cc_seq': colorCategory?['cc_seq'] ?? 0,
              'cc_name': colorCategory?['cc_name'] ?? product['color_name'] ?? '',
              'sc_seq': sizeCategory?['sc_seq'] ?? 0,
              'sc_name': sizeCategory?['sc_name'] ?? product['size_name'] ?? '',
              'quantity': 1,
            };

            CartStorage.addToCart(cartItem);
            addedCount++;
          } else {
            failedCount++;
          }
        } catch (e) {
          failedCount++;
        }
      }

      if (addedCount > 0) {
        Get.snackbar(
          '장바구니 추가',
          '$addedCount개의 상품이 장바구니에 추가되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '알림',
          '장바구니에 추가할 수 있는 상품이 없습니다.\n(실패: $failedCount개)',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '장바구니 추가 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }
  //------------------------------
}

// ============================================
// 변경 이력
// ============================================
// 2026-01-01: 
//   - Payment 관련 화면 미리보기 페이지 생성
//   - 상품 조회, 장바구니, 주문 내역 화면으로 이동하는 버튼 제공
//   - 더미 상품을 장바구니에 추가하는 기능 제공
//   - config.dart 상수를 payment_config.dart로 이동 (defaultButtonHeight, boldLabelStyle, defaultSpacing, largeSpacing 등)
