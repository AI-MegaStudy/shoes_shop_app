import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/model/branch.dart';
import 'package:shoes_shop_app/view/main/user/payment/payment_sheet_content.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/view/main/user/payment/payment_config.dart' show PurchaseItemStatus, PurchaseErrorMessage, district;

/// 메인 결제 화면
///
/// 장바구니에 담긴 상품들의 목록을 보여주고, 결제를 진행할 수 있는 화면입니다.
/// Cart 화면에서 전달받은 장바구니 정보를 표시하고, 결제 확정 시 PurchaseItem을 API에 저장합니다.
class MainPaymentView extends StatefulWidget {
  const MainPaymentView({super.key});

  @override
  State<MainPaymentView> createState() => _MainPaymentViewState();
}

class _MainPaymentViewState extends State<MainPaymentView> {
  late final List<Map<String, dynamic>> cart;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // API base URL 설정
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Cart 화면에서 전달받은 장바구니 리스트
      final raw = ModalRoute.of(context)?.settings.arguments;
      final List list = (raw is List) ? raw : [];
      cart = list.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        return Map<String, dynamic>.from(e as Map);
      }).toList();
      _initialized = true;
    }
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

  /// 장바구니 비우기
  void _clearCart() {
    CartStorage.clearCart();
  }

  /// 구매 전 재고 확인
  ///
  /// 장바구니의 모든 상품의 재고를 확인하여 구매 가능한지 검증합니다.
  /// 반환값: (구매 가능 여부, 재고 부족 상품 목록)
  Future<(bool, List<String>)> _validateStock() async {
    final insufficientItems = <String>[];

    for (final e in cart) {
      final productId = _asInt(e['p_seq']);
      final purchaseQuantity = _asInt(e['quantity'], 1);
      final productName = e['p_name'] as String? ?? '알 수 없는 상품';

      // API에서 최신 재고 조회
      try {
        final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/products/id/$productId',
          fromJson: (json) => json,
        );

        if (!response.success || response.data == null) {
          insufficientItems.add('$productName: 제품 정보를 찾을 수 없습니다.');
          continue;
        }

        final productData = response.data!['result'] as Map<String, dynamic>;
        final stock = _asInt(productData['p_stock'], 0);

        // 재고 부족 체크
        if (stock < purchaseQuantity) {
          insufficientItems.add(
            '$productName: 재고 $stock개 / 구매 요청 $purchaseQuantity개',
          );
        }
      } catch (e) {
        insufficientItems.add('$productName: 재고 확인 실패');
      }
    }

    return (insufficientItems.isEmpty, insufficientItems);
  }

  /// 현재 로그인한 사용자 정보 가져오기
  User? _getCurrentUser() {
    try {
      final storage = GetStorage();
      final userJson = storage.read<String>('user');
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      // 사용자 정보 로드 실패
    }
    return null;
  }


  /// 결제 확정 시 PurchaseItem과 Pickup을 API에 저장
  ///
  /// 1. 구매 전 재고 확인 (다른 사용자의 구매로 재고가 부족할 수 있음)
  /// 2. 현재 로그인한 사용자 ID를 가져옵니다.
  /// 3. 선택된 브랜치 사용
  /// 4. PurchaseItem들을 API에 저장합니다.
  /// 5. Pickup 정보를 API에 저장합니다.
  ///
  /// 재고가 부족하면 Exception을 발생시킵니다.
  Future<void> _savePurchaseItemsToDb(Branch branch) async {
    // 구매 전 재고 확인 (다른 사용자의 구매로 재고가 변경되었을 수 있음)
    final (isValid, insufficientItems) = await _validateStock();
    if (!isValid) {
      final errorMessage =
          '재고가 부족한 상품이 있습니다:\n${insufficientItems.join('\n')}\n\n'
          '다른 사용자가 구매하여 재고가 변경되었을 수 있습니다.';
      throw Exception(errorMessage);
    }

    // 현재 로그인한 사용자 ID 가져오기
    final user = _getCurrentUser();
    if (user == null || user.uSeq == null) {
      throw Exception('로그인된 사용자 정보가 없습니다.');
    }

    // 브랜치 확인
    if (branch.br_seq == null) {
      throw Exception('선택한 지점 정보가 올바르지 않습니다.');
    }

    final now = DateTime.now();
    final bDate = now.toIso8601String();

    // 장바구니의 모든 상품을 PurchaseItem으로 변환하여 저장
    for (final e in cart) {
      final productId = _asInt(e['p_seq']);
      final purchaseQuantity = _asInt(e['quantity'], 1);
      final unitPrice = _asInt(e['p_price'] ?? e['unitPrice'], 0);

      // PurchaseItem 저장 (Form 데이터)
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${config.getApiBaseUrl()}/api/purchase_items'),
        );
        
        request.fields['br_seq'] = branch.br_seq!.toString();
        request.fields['u_seq'] = user.uSeq!.toString();
        request.fields['p_seq'] = productId.toString();
        request.fields['b_price'] = unitPrice.toString();
        request.fields['b_quantity'] = purchaseQuantity.toString();
        request.fields['b_date'] = bDate;
        request.fields['b_status'] = PurchaseItemStatus.initial;

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          final errorBody = jsonDecode(response.body);
          final errorMsg = errorBody['errorMsg'] ?? PurchaseErrorMessage.saveFailed;
          throw Exception(errorMsg);
        }

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['result'] == 'Error') {
          final errorMsg = responseData['errorMsg'] ?? PurchaseErrorMessage.saveFailed;
          throw Exception(errorMsg);
        }

        final purchaseItemData = responseData;
        if (purchaseItemData['b_seq'] != null) {
          final bSeq = purchaseItemData['b_seq'] as int;

          // Pickup 정보 저장 (Form 데이터)
          try {
            final pickupRequest = http.MultipartRequest(
              'POST',
              Uri.parse('${config.getApiBaseUrl()}/api/pickups'),
            );
            
            pickupRequest.fields['b_seq'] = bSeq.toString();
            pickupRequest.fields['u_seq'] = user.uSeq!.toString();

            await pickupRequest.send();
            // 픽업 정보 저장 (실패 시 무시)
          } catch (e) {
            // 픽업 정보 저장 중 오류 무시
          }
        }
      } catch (e) {
        throw Exception('${PurchaseErrorMessage.processError}: $e');
      }
    }
  }

  void _openPaymentSheet() async {
    try {
      // 브랜치 리스트 조회
      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/branches',
        fromJson: (json) => json,
      );

      if (!response.success || response.data == null) {
        Get.snackbar(
          '오류',
          '${PurchaseErrorMessage.loadBranchFailed}\n${response.error ?? PurchaseErrorMessage.unknownError}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final branchesData = response.data!['results'] as List<dynamic>;
      if (branchesData.isEmpty) {
        Get.snackbar(
          '알림',
          '등록된 지점이 없습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final branches = branchesData
          .map((data) => Branch.fromJson(data as Map<String, dynamic>))
          .toList();

      // 저장된 브랜치 찾기 (사용자 주소 기반)
      Branch? savedBranch;
      final user = _getCurrentUser();
      if (user?.uAddress != null && user!.uAddress!.isNotEmpty) {
        final districts = district;
        for (final district in districts) {
          if (user.uAddress!.contains(district)) {
            // 해당 자치구에 해당하는 브랜치 찾기
            for (final branch in branches) {
              if (branch.br_address.contains(district)) {
                savedBranch = branch;
                break;
              }
            }
            if (savedBranch != null) break;
          }
        }
      }

      final p = context.palette;
      await Get.bottomSheet(
        PaymentSheetContent(
          initialBranch: savedBranch ?? branches.first,
          branches: branches,
          totalPrice: totalPrice,
          cart: cart,
          onSavePurchase: (branch) => _savePurchaseItemsToDb(branch),
          onClearCart: _clearCart,
        ),
        isScrollControlled: true,
        backgroundColor: p.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: mainBottomSheetTopBorderRadius,
        ),
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '${PurchaseErrorMessage.openPaymentFailed}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '결제',
            style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Text(
              '구매할 상품이 없습니다',
              style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '결제',
          style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
        ),
        centerTitle: mainAppBarCenterTitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final e = cart[index];
                final pName = (e['p_name'] as String?) ?? 'NO NAME';
                final ccName = (e['cc_name'] as String?) ?? '';
                final scName = (e['sc_name'] as String?) ?? '';
                final qty = _asInt(e['quantity'], 1);
                final unitPrice = _asInt(e['p_price'] ?? e['unitPrice'], 0);
                final lineTotal = unitPrice * qty;
                final pImageRaw = (e['p_image'] as String?) ?? '';
                final pImage = pImageRaw.isNotEmpty 
                    ? 'https://cheng80.myqnapcloud.com/images/$pImageRaw'
                    : '';

                return Card(
                  elevation: mainCardElevation,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: mainSmallPadding,
                    child: Row(
                      children: [
                        // 이미지
                        SizedBox(
                          width: mainProductImageWidth,
                          height: mainProductImageHeight,
                          child: pImage.isNotEmpty
                              ? Image.network(
                                  pImage,
                                  width: 90,
                                  height: 90,
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
                                style: mainBoldLabelStyle.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '색상: $ccName / 사이즈: $scName',
                                style: mainBodyTextStyle.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '수량: $qty',
                                style: mainBodyTextStyle.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                              Text(
                                '합계: ${CustomCommonUtil.formatPrice(lineTotal)}',
                                style: mainBoldLabelStyle.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

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
                  onPressed: _openPaymentSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.textOnPrimary,
                  ),
                  child: Text(
                    '결제하기',
                    style: mainBoldLabelStyle.copyWith(
                      color: p.textOnPrimary,
                    ),
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

