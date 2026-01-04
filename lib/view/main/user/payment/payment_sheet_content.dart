import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/model/branch.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/view/main/user/product/main_product_list.dart';
import 'package:shoes_shop_app/view/main/user/cart/main_cart_view.dart';

/// 결제 시트 내용 위젯
/// 
/// BottomSheet 내에서 표시되는 결제 확인 UI입니다.
/// 지점 선택, 결제 수단, 총액 표시 및 결제 확정 기능을 제공합니다.
class PaymentSheetContent extends StatefulWidget {
  final Branch initialBranch;
  final List<Branch> branches;
  final int totalPrice;
  final List<Map<String, dynamic>> cart;
  final Future<void> Function(Branch branch) onSavePurchase;
  final void Function() onClearCart;

  const PaymentSheetContent({
    super.key,
    required this.initialBranch,
    required this.branches,
    required this.totalPrice,
    required this.cart,
    required this.onSavePurchase,
    required this.onClearCart,
  });

  @override
  State<PaymentSheetContent> createState() => _PaymentSheetContentState();
}

class _PaymentSheetContentState extends State<PaymentSheetContent> {
  late Branch _selectedBranch;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.initialBranch;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: BoxDecoration(
          color: p.cardBackground,
          borderRadius: mainBottomSheetTopBorderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: p.divider,
                borderRadius: mainDefaultBorderRadius,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(Icons.payment),
                const SizedBox(width: 8),
                Text("결제 확인", style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("수령 지점", style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
            ),
            mainSmallVerticalSpacing,

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: p.divider),
                borderRadius: mainMediumBorderRadius,
              ),
              child: DropdownButton<Branch>(
                value: _selectedBranch,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                items: widget.branches
                    .map((branch) => DropdownMenuItem<Branch>(
                          value: branch,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.br_name,
                                style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                              ),
                              Text(
                                branch.br_address,
                                style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedBranch = v;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("결제수단", style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
            ),
            mainSmallVerticalSpacing,
            Container(
              width: double.infinity,
              padding: mainMediumPadding,
              decoration: BoxDecoration(
                border: Border.all(color: p.divider),
                borderRadius: mainMediumBorderRadius,
              ),
              child: Text("카드(더미)", style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: mainMediumPadding,
              decoration: BoxDecoration(
                border: Border.all(color: p.divider),
                borderRadius: mainMediumBorderRadius,
              ),
              child: Row(
                children: [
                  Expanded(child: Text("총액", style: mainBoldLabelStyle.copyWith(color: p.textPrimary))),
                  Text(CustomCommonUtil.formatPrice(widget.totalPrice), style: mainBoldLabelStyle.copyWith(color: p.textPrimary)),
                ],
              ),
            ),

            mainDefaultVerticalSpacing,

            SlideAction(
              text: _confirmed ? "결제 처리중..." : "오른쪽으로 밀어서 결제 확정",
              textStyle: mainBoldLabelStyle.copyWith(color: p.textPrimary),
              outerColor: p.divider,
              innerColor: p.cardBackground,
              sliderButtonIcon: Icon(
                Icons.double_arrow_rounded,
                color: p.primary,
              ),
              sliderButtonIconPadding: 12,
              borderRadius: 18,
              elevation: 0,
              onSubmit: !_confirmed ? () async {
                setState(() {
                  _confirmed = true;
                });

                try {
                  await widget.onSavePurchase(_selectedBranch);
                  widget.onClearCart();

                  if (!mounted) return;
                  Get.back();
                  Get.snackbar(
                    '결제 완료',
                    "수령지: ${_selectedBranch.br_name} / 총액: ${CustomCommonUtil.formatPrice(widget.totalPrice)}",
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  if (!mounted) return;
                  // 결제 완료 후 제품 목록 페이지로 이동
                  Get.to(() => MainProductList());
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _confirmed = false;
                  });

                  Get.back();
                  CustomCommonUtil.showConfirmDialog(
                    context: context,
                    title: '구매 실패',
                    message: e.toString().replaceFirst('Exception: ', ''),
                    confirmText: '장바구니로 이동',
                    cancelText: '확인',
                    onConfirm: () {
                      // 장바구니 복원
                      for (final item in widget.cart) {
                        CartStorage.addToCart(item);
                      }
                      // 장바구니 화면으로 이동
                      Get.to(() => MainCartView());
                    },
                  );
                }
              } : null,
              alignment: Alignment.center,
              height: mainButtonHeight,
            ),
          ],
        ),
      ),
    );
  }
}

