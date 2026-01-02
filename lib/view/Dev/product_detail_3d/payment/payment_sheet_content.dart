import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/model/branch.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment_config.dart' show boldLabelStyle, smallTextStyle, bottomSheetTopBorderRadius, defaultBorderRadius, mediumBorderRadius, smallVerticalSpacing, mediumPadding, defaultVerticalSpacing, defaultButtonHeight;

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
          borderRadius: bottomSheetTopBorderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: p.divider,
                borderRadius: defaultBorderRadius,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(Icons.payment),
                const SizedBox(width: 8),
                Text("결제 확인", style: boldLabelStyle.copyWith(color: p.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("수령 지점", style: boldLabelStyle.copyWith(color: p.textPrimary)),
            ),
            smallVerticalSpacing,

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: p.divider),
                borderRadius: mediumBorderRadius,
              ),
              child: DropdownButton<Branch>(
                value: _selectedBranch,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                style: boldLabelStyle.copyWith(color: p.textPrimary),
                items: widget.branches
                    .map((branch) => DropdownMenuItem<Branch>(
                          value: branch,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.br_name,
                                style: boldLabelStyle.copyWith(color: p.textPrimary),
                              ),
                              Text(
                                branch.br_address,
                                style: smallTextStyle.copyWith(color: p.textSecondary),
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
              child: Text("결제수단", style: boldLabelStyle.copyWith(color: p.textPrimary)),
            ),
            smallVerticalSpacing,
            Container(
              width: double.infinity,
              padding: mediumPadding,
              decoration: BoxDecoration(
                border: Border.all(color: p.divider),
                borderRadius: mediumBorderRadius,
              ),
              child: Text("카드(더미)", style: boldLabelStyle.copyWith(color: p.textPrimary)),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: mediumPadding,
              decoration: BoxDecoration(
                border: Border.all(color: p.divider),
                borderRadius: mediumBorderRadius,
              ),
              child: Row(
                children: [
                  Expanded(child: Text("총액", style: boldLabelStyle.copyWith(color: p.textPrimary))),
                  Text(CustomCommonUtil.formatPrice(widget.totalPrice), style: boldLabelStyle.copyWith(color: p.textPrimary)),
                ],
              ),
            ),

            defaultVerticalSpacing,

            SlideAction(
              text: _confirmed ? "결제 처리중..." : "오른쪽으로 밀어서 결제 확정",
              textStyle: boldLabelStyle.copyWith(color: p.textPrimary),
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
                  // 홈 화면으로 이동
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _confirmed = false;
                  });

                  Get.back();
                  Get.dialog(
                    AlertDialog(
                      title: const Text('구매 실패'),
                      content: Text(e.toString().replaceFirst('Exception: ', '')),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('확인'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 장바구니 복원
                            for (final item in widget.cart) {
                              CartStorage.addToCart(item);
                            }
                            Get.back();
                            // 장바구니 화면으로 이동
                            Get.until((route) => route.isFirst);
                          },
                          child: const Text('장바구니로 이동'),
                        ),
                      ],
                    ),
                  );
                }
              } : null,
              alignment: Alignment.center,
              height: defaultButtonHeight,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// 변경 이력
// ============================================
// 2026-01-01: 
//   - 자치구 리스트에서 브랜치 리스트로 변경
//   - 브랜치 이름과 주소를 드롭다운에 표시
//   - 선택한 브랜치를 콜백으로 전달
//   - GetX snackbar/dialog 사용
//   - config.dart 상수를 payment_config.dart로 이동 (boldLabelStyle, smallTextStyle, bottomSheetTopBorderRadius, defaultBorderRadius, mediumBorderRadius, smallVerticalSpacing, mediumPadding, defaultVerticalSpacing, defaultButtonHeight 등)

