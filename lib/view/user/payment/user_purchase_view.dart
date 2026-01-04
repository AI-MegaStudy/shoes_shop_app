import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:shoes_shop_app/model/branch.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/view/main/user/payment/payment_config.dart';
import 'package:shoes_shop_app/view/user/product/list_view.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoes_shop_app/config.dart' as config;

import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';

class CartItem {
  int p_seq, p_price, cc_seq, sc_seq, gc_seq, quantity;
  String p_name, cc_name, sc_name, gc_name, p_image;

  CartItem({
    required this.p_seq,
    required this.p_name,
    required this.p_price,
    required this.cc_seq,
    required this.cc_name,
    required this.sc_seq,
    required this.sc_name,
    required this.gc_seq,
    required this.gc_name,
    required this.quantity,
    required this.p_image,
  });
  Map<String, dynamic> toJson() {
    return {
      'p_seq': p_seq,
      'p_name': p_name,
      'p_price': p_price,
      'cc_seq': cc_seq,
      'cc_name': cc_name,
      'sc_seq': sc_seq,
      'sc_name': sc_name,
      'gc_seq': gc_seq,
      'gc_name': gc_name,
      'quantity': quantity,
      'p_image': p_image,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    p_seq: json['p_seq'],
    p_name: json['p_name'],
    p_price: json['p_price'],
    cc_seq: json['cc_seq'],
    cc_name: json['cc_name'],
    sc_seq: json['sc_seq'],
    sc_name: json['sc_name'],
    gc_seq: json['gc_seq'],
    gc_name: json['gc_name'],
    quantity: json['quantity'],
    p_image: json['p_image'],
  );
}

class UserPurchaseView extends StatefulWidget {
  const UserPurchaseView({super.key});
  @override
  State<UserPurchaseView> createState() => _UserPurchaseViewState();
}

class _UserPurchaseViewState extends State<UserPurchaseView> {
  List<CartItem> data = [];
  List<Branch> datas = [];
  Branch? selectedBranch;
  String selectedPayment = 'toss';
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  Future<void> getJSONData() async {
    try {
      var url = Uri.parse(
        // 'http://192.168.10.4:8000/api/branches',
        //"${config.customApiBaseUrl}/api/branches"
        "${config.getApiBaseUrl()}/api/branches",
      );
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var decoded = json.decode(utf8.decode(response.bodyBytes));
        List result = (decoded is List) ? decoded : decoded['results'] ?? [];
        setState(() {
          datas = result.map((e) => Branch.fromJson(e)).toList();
          if (datas.isNotEmpty) {
            selectedBranch = datas[0];
          } else {
            selectedBranch = null;
          }
        });
      }
      loadCartData();
    } catch (e) {
      debugPrint("API 에러: $e");
    }
  }

  void loadCartData() {
    for (var d in CartStorage.getCart()) {
      totalPrice += int.parse(d['p_price'].toString()) * int.parse(d['quantity'].toString());
      data.add(CartItem.fromJson(d));
    }
    // List<CartItem> tempList = [
    //   CartItem(
    //     p_seq: 1,
    //     p_name: "에어 포스 1 '07",
    //     p_price: 139000,
    //     cc_seq: 1,
    //     cc_name: "화이트",
    //     sc_seq: 1,
    //     sc_name: "270",
    //     gc_seq: 1,
    //     gc_name: "남성",
    //     quantity: 1,
    //     p_image:
    //         "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/389b709e-5102-4e55-aa5d-077774a877df/air-force-1-07-shoes-Wr0Q19.png",
    //   ),
    // ];
    // int tempTotal = 0;
    // for (var item in tempList) {
    //   tempTotal += item.p_price * item.quantity;
    // }

    setState(() {});
    // data = tempList;
    // totalPrice = tempTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('결제'), centerTitle: true),
      body: data.isEmpty
          ? Center(child: Text('데이터가 없습니다.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) => Card(
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Image.network(
                          //data[index].p_image,
                          'https://cheng80.myqnapcloud.com/images/${data[index].p_image}',
                          width: 60,
                          // errorBuilder: (context, e, s) =>
                          //     Icon(Icons.error),
                        ),
                        title: Text(
                          data[index].p_name,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text("${data[index].cc_name} / ${data[index].sc_name} / ${data[index].quantity}개"),
                        trailing: Text("${CustomCommonUtil.formatPrice(data[index].p_price)}"),
                      ),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        // color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총액 : ${CustomCommonUtil.formatPrice(totalPrice)}',
            style: TextStyle(
              //fontSize: 18,
              // fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(onPressed: showPurchaseBottomSheet, child: Text('결제하기')),
        ],
      ),
    );
  }

  void showPurchaseBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '결제 확인',
                  style: TextStyle(
                    //      fontSize: 20,
                    //   fontWeight: FontWeight.bold,
                  ),
                ),

                Text('수령지점(자치구)'),
                DropdownButton<Branch>(
                  value: selectedBranch,
                  //  dropdownColor: Colors.white,
                  //iconEnabledColor: Colors.black,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: datas.map((Branch branch) {
                    return DropdownMenuItem<Branch>(value: branch, child: Text(branch.br_name));
                  }).toList(),
                  onChanged: (newValue) {
                    setModalState(() => selectedBranch = newValue);
                    setState(() => selectedBranch = newValue);
                  },
                ),
                Text(
                  '결제수단',
                  style: TextStyle(
                    //  fontSize: 20,
                    //   fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton(
                  // dropdownColor: Colors.white,
                  // iconEnabledColor: Colors.black,
                  value: selectedPayment,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: ['toss', '카드결제', '계좌이체'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          //   color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedPayment = newValue!;
                    setState(() {});
                  },
                ),
                // Text(
                //                     "총액: ${(data[index].p_price ?? 0) * (data[index].cc_quantity ?? 1)}원",
                //                     style: TextStyle(
                //                       fontSize: 16,
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                SlideAction(
                  onSubmit: () async {
                    // for (CartItem d in data) {
                    //   print(d.toJson());
                    // }
                    await completePurchase();
                    return null;
                  },
                  //innerColor: Colors.blue,
                  outerColor: Colors.grey,
                  sliderButtonIcon: Icon(
                    Icons.shopping_bag_outlined,
                    //  color: Colors.white,
                  ),
                  text: "오른쪽으로 밀어서 결제 확정",
                  textStyle: TextStyle(
                    //color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    // fontSize: 16,
                  ),
                  //height: 60,
                  // borderRadius: 12,
                  //  elevation: 0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> completePurchase() async {
    // Purchase to DB
    // Get Selected Branch
    // try {
    await _savePurchaseItemsToDb(selectedBranch!);
    CartStorage.clearCart();
    Get.snackbar("결제 완료", "성공적으로 주문되었습니다.", snackPosition: SnackPosition.BOTTOM);

    Get.offAll(() => ProductListView());

    // } catch (error) {
    //   Get.back();
    //   Get.snackbar("Error", "죄송합니다. 제고가 부족한것 같습니다.");
    // }
  }

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
    final storage = GetStorage();
    final userJson = storage.read<String>('user');

    if (userJson == null) {
      throw Exception('로그인된 사용자 정보가 없습니다.');
    }
    final user = User.fromJson(jsonDecode(userJson));

    if (user.uSeq == null) {
      throw Exception('로그인된 사용자 정보가 없습니다.');
    }

    // 브랜치 확인
    if (branch.br_seq == null) {
      throw Exception('선택한 지점 정보가 올바르지 않습니다.');
    }

    final now = DateTime.now();
    final bDate = now.toIso8601String();

    // 장바구니의 모든 상품을 PurchaseItem으로 변환하여 저장
    for (final e in data) {
      final productId = e.p_seq;
      final purchaseQuantity = e.quantity;
      final unitPrice = e.p_price;

      // PurchaseItem 저장 (Form 데이터)
      try {
        final request = http.MultipartRequest('POST', Uri.parse('${config.getApiBaseUrl()}/api/purchase_items'));

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
            final pickupRequest = http.MultipartRequest('POST', Uri.parse('${config.getApiBaseUrl()}/api/pickups'));

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

  Future<(bool, List<String>)> _validateStock() async {
    final insufficientItems = <String>[];

    for (final e in data) {
      final productId = e.p_seq;
      final purchaseQuantity = e.quantity;
      final productName = e.p_name;

      // API에서 최신 재고 조회
      try {
        final response = await CustomNetworkUtil.get<Map<String, dynamic>>('/api/products/id/$productId', fromJson: (json) => json);

        if (!response.success || response.data == null) {
          insufficientItems.add('$productName: 제품 정보를 찾을 수 없습니다.');
          continue;
        }

        final productData = response.data!['result'] as Map<String, dynamic>;
        final stock = productData['p_stock'];

        // 재고 부족 체크
        if (stock < purchaseQuantity) {
          insufficientItems.add('$productName: 재고 $stock개 / 구매 요청 $purchaseQuantity개');
        }
      } catch (e) {
        insufficientItems.add('$productName: 재고 확인 실패');
      }
    }
    return (insufficientItems.isEmpty, insufficientItems);
  }
}
