import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/branch.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shoes_shop_app/config.dart' as config;
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
    loadCartData();
  }

  Future<void> getJSONData() async {
    try {
      var url = Uri.parse(config.getApiBaseUrl() + "/api/branches");
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

    setState(() {
      // data = tempList;
      // totalPrice = tempTotal;
    });
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
              //mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최종 결제 확인',
                  style: TextStyle(
                    //      fontSize: 20,
                    //   fontWeight: FontWeight.bold,
                  ),
                ),

                Text('수령지점'),
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
                SlideAction(
                  onSubmit: () async {
                    completePurchase();
                    return null;
                  },
                  //innerColor: Colors.blue,
                  outerColor: Colors.grey[300]!,
                  sliderButtonIcon: Icon(
                    Icons.shopping_bag_outlined,
                    //  color: Colors.white,
                  ),
                  text: "밀어서 결제하기",
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

  void completePurchase() {
    Get.back();
    Get.snackbar("결제 완료", "성공적으로 주문되었습니다.", snackPosition: SnackPosition.BOTTOM);
    CartStorage.clearCart();
    loadCartData();
  }
}
