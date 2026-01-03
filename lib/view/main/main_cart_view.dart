import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/view/main/main_payment_view.dart';
import 'package:shoes_shop_app/view/main/main_ui_config.dart';
import 'package:shoes_shop_app/view/main/payment_config.dart' show PurchaseErrorMessage;

/// 메인 장바구니 화면
/// 
/// 로컬 저장소(GetStorage)에 저장된 장바구니 항목을 표시하고,
/// 수량 조절, 삭제, 결제하기 기능을 제공합니다.
class MainCartView extends StatefulWidget {
  const MainCartView({super.key});

  @override
  State<MainCartView> createState() => _MainCartViewState();
}

class _MainCartViewState extends State<MainCartView> {
  List<Map<String, dynamic>> cart = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
    // API base URL 설정
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
  }

  /// 장바구니 로드
  void _loadCart() {
    setState(() {
      cart = CartStorage.getCart();
      loading = false;
    });
  }

  /// 장바구니 저장
  void _saveCart() {
    CartStorage.saveCart(cart);
    setState(() {}); // UI 갱신
  }

  /// 동적 값을 int로 변환
  int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  /// 총 금액 계산
  int get totalPrice {
    return cart.fold<int>(0, (sum, e) {
      final q = _asInt(e['quantity'], 1);
      final p = _asInt(e['p_price'] ?? e['unitPrice'], 0);
      return sum + (q * p);
    });
  }

  /// 수량 증가
  Future<void> _inc(int index) async {
    final pSeq = _asInt(cart[index]['p_seq']);
    if (pSeq == 0) return;

    // API에서 현재 재고 확인
    try {
      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/products/id/$pSeq',
        fromJson: (json) => json,
      );

      if (!response.success || response.data == null) {
        Get.snackbar(
          '오류',
          PurchaseErrorMessage.loadProductFailed,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final productData = response.data!['result'] as Map<String, dynamic>;
      final stock = _asInt(productData['p_stock'], 0);
      final currentQty = _asInt(cart[index]['quantity'], 1);
      final newQuantity = currentQty + 1;

      // 재고 초과 체크
      if (newQuantity > stock) {
        CustomCommonUtil.showSuccessDialog(
          context: context,
          title: '수량 초과',
          message: '재고가 부족합니다.\n'
              '현재 재고: ${CustomCommonUtil.formatNumber(stock)}개\n'
              '구매 가능한 최대 수량: ${CustomCommonUtil.formatNumber(stock)}개',
          confirmText: '확인',
          onConfirm: () {},
        );
        return;
      }

      // 수량 증가
      cart[index]['quantity'] = newQuantity;
      _saveCart();
    } catch (e) {
      Get.snackbar(
        '오류',
        PurchaseErrorMessage.checkStockError,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 수량 감소
  void _dec(int index) {
    final q = _asInt(cart[index]['quantity'], 1);
    if (q <= 1) return;
    cart[index]['quantity'] = q - 1;
    _saveCart();
  }

  /// 항목 삭제
  void _remove(int index) {
    cart.removeAt(index);
    _saveCart();
  }

  /// 결제 화면으로 이동
  void _goPurchase() {
    if (cart.isEmpty) {
      Get.snackbar(
        '알림',
        '장바구니가 비어있습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // 결제 화면으로 이동 + cart 전체 넘김
    Get.to(
      () => const MainPaymentView(),
      arguments: cart,
    );
  }

  /// 장바구니 비우기
  void _clearCart() {
    CustomCommonUtil.showConfirmDialog(
      context: context,
      title: '장바구니 비우기',
      message: '장바구니를 모두 비우시겠습니까?',
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () {
        CartStorage.clearCart();
        cart.clear();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니', style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
        centerTitle: mainAppBarCenterTitle,
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: '전체 삭제',
            ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Text(
                            '장바구니가 비어있습니다',
                            style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];

                            final pName = (item['p_name'] as String?) ?? 'NO NAME';
                            final ccName = (item['cc_name'] as String?) ?? '';
                            final scName = (item['sc_name'] as String?) ?? '';
                            final unitPrice = _asInt(item['p_price'] ?? item['unitPrice'], 0);
                            final qty = _asInt(item['quantity'], 1);
                            final lineTotal = unitPrice * qty;
                            final pImageRaw = (item['p_image'] as String?) ?? '';
                            final pImage = pImageRaw.isNotEmpty 
                                ? 'https://cheng80.myqnapcloud.com/images/$pImageRaw'
                                : '';

                            return Card(
                              elevation: mainCardElevation,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Padding(
                                padding: mainSmallPadding,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 이미지
                                    SizedBox(
                                      width: mainProductImageWidth,
                                      height: mainProductImageHeight,
                                      child: pImage.isNotEmpty
                                          ? Image.network(
                                              pImage,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                            )
                                          : const Icon(Icons.image_not_supported),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pName,
                                            style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '색상: $ccName / 사이즈: $scName',
                                            style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '단가: ${CustomCommonUtil.formatPrice(unitPrice)}',
                                            style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '합계: ${CustomCommonUtil.formatPrice(lineTotal)}',
                                            style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () => _dec(index),
                                              icon: const Icon(Icons.remove),
                                            ),
                                            Text('$qty', style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
                                            IconButton(
                                              onPressed: () => _inc(index),
                                              icon: const Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () => _remove(index),
                                          icon: const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 총액 + 결제 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '총액: ${CustomCommonUtil.formatPrice(totalPrice)}',
                          style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: cart.isEmpty ? null : _goPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cart.isEmpty ? p.divider : p.primary,
                          foregroundColor: p.textOnPrimary,
                        ),
                        child: Text(
                          '결제하기',
                          style: mainBoldLabelStyle.copyWith(color: p.textOnPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
        ),
    );
  }
}

