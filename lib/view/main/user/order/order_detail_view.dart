import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/view/main/user/payment/payment_config.dart' show PurchaseErrorMessage, PurchaseLabel, PurchaseDefaultValue, getPurchaseItemStatusText;

/// 주문 상세 화면
/// 
/// 선택한 주문의 모든 항목들을 표시합니다.
class OrderDetailView extends StatefulWidget {
  final String orderDatetime;
  final int branchSeq;
  final int userSeq;

  const OrderDetailView({
    super.key,
    required this.orderDatetime,
    required this.branchSeq,
    required this.userSeq,
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  Map<String, dynamic>? orderInfo;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
    _loadOrderDetail();
  }

  /// 주문 상세 정보 조회
  Future<void> _loadOrderDetail() async {
    // 이미 로딩 중이면 중복 요청 방지
    if (isLoading) {
      return;
    }

    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/purchase_items/by_datetime/with_details',
        queryParams: {
          'user_seq': widget.userSeq.toString(),
          'order_datetime': widget.orderDatetime, // CustomNetworkUtil이 자동으로 인코딩함
          'branch_seq': widget.branchSeq.toString(),
        },
        fromJson: (json) => json,
      );

      if (!response.success || response.data == null) {
        // 422 에러의 경우 상세 메시지 파싱
        String detailedError = response.error ?? PurchaseErrorMessage.loadDetailFailed;
        if (response.statusCode == 422 && response.rawBody != null && response.rawBody!.isNotEmpty) {
          try {
            final errorJson = jsonDecode(response.rawBody!);
            if (errorJson is Map && errorJson.containsKey('detail')) {
              final detail = errorJson['detail'];
              if (detail is List && detail.isNotEmpty) {
                final firstError = detail[0];
                if (firstError is Map && firstError.containsKey('msg')) {
                  detailedError = firstError['msg'] as String? ?? detailedError;
                }
              }
            }
          } catch (e) {
            // 에러 메시지 파싱 실패 무시
          }
        }
        
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = detailedError;
        });
        return;
      }

      final result = response.data!['result'] as Map<String, dynamic>?;
      if (result == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = PurchaseErrorMessage.orderNotFound;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        orderInfo = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = '${PurchaseErrorMessage.loadDetailError}: $e';
      });
    }
  }

  String _getStatusText(String? status) {
    return getPurchaseItemStatusText(status);
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return PurchaseDefaultValue.unknown;
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          PurchaseLabel.orderDetail,
          style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
      ),
      body: SafeArea(
        child: isLoading
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
                        style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrderDetail,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : orderInfo == null
                  ? Center(
                      child: Text(
                        PurchaseErrorMessage.orderNotFound,
                        style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrderDetail,
                      child: SingleChildScrollView(
                        padding: mainDefaultPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 주문 정보 카드
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: mainMediumPadding,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      PurchaseLabel.orderInfo,
                                      style: mainTitleStyle.copyWith(color: p.textPrimary),
                                    ),
                                    const Divider(),
                                    _buildInfoRow(
                                      icon: Icons.access_time,
                                      label: PurchaseLabel.orderDateTime,
                                      value: _formatDateTime(orderInfo!['b_date'] ?? orderInfo!['order_datetime']),
                                      p: p,
                                    ),
                                    if (orderInfo!['branch_name'] != null)
                                      _buildInfoRow(
                                        icon: Icons.store,
                                        label: '수령 지점',
                                        value: orderInfo!['branch_name'] as String,
                                        p: p,
                                      ),
                                    if (orderInfo!['branch_address'] != null)
                                      _buildInfoRow(
                                        icon: Icons.location_on,
                                        label: '지점 주소',
                                        value: orderInfo!['branch_address'] as String,
                                        p: p,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: mainDefaultSpacing),
                            
                            // 주문 항목들
                            Text(
                              PurchaseLabel.orderItems,
                              style: mainTitleStyle.copyWith(color: p.textPrimary),
                            ),
                            const SizedBox(height: mainDefaultSpacing),
                            
                            ...((orderInfo!['items'] as List<dynamic>?) ?? []).map((itemData) {
                              final item = itemData as Map<String, dynamic>;
                              final product = item['product'] as Map<String, dynamic>?;
                              final productName = product?['p_name'] as String? ?? PurchaseDefaultValue.productNameMissing;
                              final productImageRaw = product?['p_image'] as String? ?? '';
                              final productImage = productImageRaw.isNotEmpty 
                                  ? 'https://cheng80.myqnapcloud.com/images/$productImageRaw'
                                  : '';
                              final colorName = product?['color_name'] as String? ?? '';
                              final sizeName = product?['size_name'] as String? ?? '';
                              final bPrice = (item['b_price'] as num?)?.toInt() ?? 0;
                              final bQuantity = (item['b_quantity'] as num?)?.toInt() ?? 1;
                              final bStatus = item['b_status'] as String?;
                              final totalPrice = bPrice * bQuantity;
                              
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: mainMediumPadding,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 상품 이미지
                                      if (productImage.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: mainDefaultBorderRadius,
                                          child: Image.network(
                                            productImage,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 80,
                                              height: 80,
                                              color: p.divider,
                                              child: Icon(Icons.image_not_supported, color: p.textSecondary),
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: p.divider,
                                            borderRadius: mainDefaultBorderRadius,
                                          ),
                                          child: Icon(Icons.image_not_supported, color: p.textSecondary),
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // 색상과 사이즈를 한 줄로 표시
                                            if (colorName.isNotEmpty || sizeName.isNotEmpty)
                                              Text(
                                                [
                                                  if (colorName.isNotEmpty) '색상: $colorName',
                                                  if (sizeName.isNotEmpty) '사이즈: $sizeName',
                                                ].join('  |  '),
                                                style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                                              ),
                                            if (colorName.isNotEmpty || sizeName.isNotEmpty) const SizedBox(height: 4),
                                            // 수량과 단가를 한 줄로 표시
                                            Text(
                                              '수량: ${CustomCommonUtil.formatNumber(bQuantity)}개  |  단가: ${CustomCommonUtil.formatPrice(bPrice)}',
                                              style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '합계: ${CustomCommonUtil.formatPrice(totalPrice)}',
                                              style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: p.primary.withOpacity(0.1),
                                                borderRadius: mainSmallBorderRadius,
                                              ),
                                              child: Text(
                                                _getStatusText(bStatus),
                                                style: mainSmallTextStyle.copyWith(color: p.primary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            
                            // 총합
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: mainMediumPadding,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '총 주문 금액',
                                      style: mainBoldLabelStyle.copyWith(color: p.textPrimary),
                                    ),
                                    Text(
                                      CustomCommonUtil.formatPrice(
                                        ((orderInfo!['items'] as List<dynamic>?) ?? []).fold<int>(
                                          0,
                                          (sum, item) {
                                            final itemData = item as Map<String, dynamic>;
                                            final price = (itemData['b_price'] as num?)?.toInt() ?? 0;
                                            final qty = (itemData['b_quantity'] as num?)?.toInt() ?? 1;
                                            return sum + (price * qty);
                                          },
                                        ),
                                      ),
                                      style: mainPriceStyle.copyWith(color: p.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required AppColorScheme p,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: p.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: mainMediumTextStyle.copyWith(color: p.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

