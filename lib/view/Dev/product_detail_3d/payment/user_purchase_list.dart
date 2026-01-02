import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment/order_detail_view.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment_config.dart' show PurchaseErrorMessage, PurchaseLabel, PurchaseDefaultValue, boldLabelStyle, bodyTextStyle, smallTextStyle, screenPadding, defaultBorderRadius, mediumPadding;

class UserPurchaseList extends StatefulWidget {
  const UserPurchaseList({super.key});

  @override
  State<UserPurchaseList> createState() => _UserPurchaseListState();
}

class _UserPurchaseListState extends State<UserPurchaseList> {
  // Property
  List<Map<String, dynamic>> orders = []; // 그룹화된 주문 목록
  int? userSeq;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // API base URL 설정
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
    _loadUserData();
  }

  /// GetStorage에서 사용자 정보 로드
  Future<void> _loadUserData() async {
    try {
      final storage = GetStorage();
      final userJson = storage.read<String>('user');
      
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.uSeq != null) {
          setState(() {
            userSeq = user.uSeq;
          });
          await _loadOrders();
        } else {
          setState(() {
            isLoading = false;
            errorMessage = '사용자 정보를 불러올 수 없습니다.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = '로그인 정보를 찾을 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '사용자 정보 로드 중 오류가 발생했습니다: $e';
      });
    }
  }

  /// 그룹화된 주문 목록 조회
  Future<void> _loadOrders() async {
    if (userSeq == null) return;
    
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/purchase_items/by_user/$userSeq/orders',
        fromJson: (json) => json,
      );

      if (!response.success || response.data == null) {
        setState(() {
          isLoading = false;
          errorMessage = response.error ?? PurchaseErrorMessage.loadListFailed;
        });
        return;
      }

      final responseData = response.data!;
      final List<dynamic> results = responseData['results'] ?? [];
      
      setState(() {
        orders = results.map((e) => e as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '${PurchaseErrorMessage.loadListError}: $e';
      });
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return PurchaseDefaultValue.unknown;
    try {
      // "YYYY-MM-DD HH:MM" 형식이거나 ISO 형식일 수 있음
      if (dateTime.contains('T')) {
        final dt = DateTime.parse(dateTime);
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else {
        return dateTime;
      }
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(PurchaseLabel.orderList, style: boldLabelStyle.copyWith(color: p.textPrimary)),
        centerTitle: true,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: p.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: bodyTextStyle.copyWith(color: p.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 64, color: p.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            PurchaseLabel.noOrderHistory,
                            style: bodyTextStyle.copyWith(color: p.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: screenPadding,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderDatetime = order['order_datetime'] as String? ?? '';
                          final orderTime = order['order_time'] as String? ?? orderDatetime;
                          final branchName = order['branch_name'] as String? ?? PurchaseDefaultValue.branchNameMissing;
                          final itemCount = (order['item_count'] as num?)?.toInt() ?? 0;
                          final totalAmount = (order['total_amount'] as num?)?.toInt() ?? 0;
                          final branchSeq = (order['branch_seq'] as num?)?.toInt();

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: branchSeq != null && userSeq != null
                                  ? () {
                                      Get.to(() => OrderDetailView(
                                            orderDatetime: orderDatetime,
                                            branchSeq: branchSeq,
                                            userSeq: userSeq!,
                                          ));
                                    }
                                  : null,
                              borderRadius: defaultBorderRadius,
                              child: Padding(
                                padding: mediumPadding,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                PurchaseLabel.orderDateTime,
                                                style: smallTextStyle.copyWith(color: p.textSecondary),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDateTime(orderTime),
                                                style: boldLabelStyle.copyWith(color: p.textPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: p.textSecondary,
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '품목 개수',
                                              style: smallTextStyle.copyWith(color: p.textSecondary),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${CustomCommonUtil.formatNumber(itemCount)}개',
                                              style: bodyTextStyle.copyWith(color: p.textPrimary),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '총합',
                                              style: smallTextStyle.copyWith(color: p.textSecondary),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CustomCommonUtil.formatPrice(totalAmount),
                                              style: boldLabelStyle.copyWith(color: p.primary, fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.store, size: 16, color: p.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          branchName,
                                          style: bodyTextStyle.copyWith(color: p.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ============================================
// 변경 이력
// ============================================
// 2026-01-01: 
//   - 개별 주문 항목 표시에서 그룹화된 주문 목록으로 변경
//   - API: /api/purchase_items/by_user/{user_seq}/orders 사용 (날짜+시간 기반 그룹화)
//   - 주문 카드에 총합, 주문 일시, 품목 개수, 지점명 표시
//   - 주문 카드 클릭 시 OrderDetailView로 이동하여 상세 정보 확인
//   - GetX navigation 사용
//   - config.dart 상수를 payment_config.dart로 이동 (boldLabelStyle, bodyTextStyle, smallTextStyle, screenPadding, defaultBorderRadius, mediumPadding, PurchaseErrorMessage, PurchaseLabel, PurchaseDefaultValue 등)

