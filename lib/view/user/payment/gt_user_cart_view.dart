import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/product_join.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/view/user/payment/user_purchase_view.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
// Product detail과 같은 class

class CartItem {
  int p_seq;
  String p_name;
  int p_price;
  int cc_seq;
  String cc_name;
  int sc_seq;
  String sc_name;
  int gc_seq;
  String gc_name;
  int quantity;
  String p_image;

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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
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
}

class GTUserCartView extends StatefulWidget {
  const GTUserCartView({super.key});

  @override
  State<GTUserCartView> createState() => _GTUserCartViewState();
}

class _GTUserCartViewState extends State<GTUserCartView> {
  // Property
  List<CartItem> data = [];
  int totalPrice = 0;

  // 장바구니 결제 부분 height
  double purchaseBoxHeight = 250.0;

  @override
  void initState() {
    super.initState();
    for (var d in CartStorage.getCart()) {
      totalPrice += int.parse(d['p_price'].toString()) * int.parse(d['quantity'].toString());
      data.add(CartItem.fromJson(d));
    }
    // data.addAll(CartStorage.getCart().map((d) => CartItem.fromJson(d)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
        centerTitle: true,
        leading: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back)),
      ),
      body: data.isEmpty
          ? Center(child: Text('데이터가 없습니다.'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.white,
                                    child: Image.network(
                                      //'http://172.16.250.175:8000/api/products/?t=${DateTime.now().microsecondsSinceEpoch}',
                                      'https://cheng80.myqnapcloud.com/images/${data[index].p_image}',
                                      width: 100,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${data[index].p_name}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4),
                                      Text(
                                        "${data[index].cc_name} / ${data[index].sc_name} / ${data[index].gc_name}",
                                        style: TextStyle(color: Colors.black54, fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Text("단가: ${CustomCommonUtil.formatPrice(data[index].p_price)}", style: TextStyle(fontSize: 14)),
                                      SizedBox(height: 4),
                                      // Text(
                                      //   "합계: ${(data[index].p_price ?? 0) * (data[index].cc_quantity ?? 1)}원",
                                      //   style: TextStyle(
                                      //     fontSize: 16,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(onTap: () => _dec(index), child: Icon(Icons.remove, size: 20)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text("${data[index].quantity ?? 1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ),
                                        GestureDetector(onTap: () => _inc(index), child: Icon(Icons.add, size: 20)),
                                      ],
                                    ),
                                    SizedBox(height: 25),
                                    IconButton(
                                      onPressed: () => _remove(index),
                                      icon: Icon(Icons.delete_outline, color: Colors.black54),
                                      // constraints: BoxConstraints(),
                                      //padding: EdgeInsets.zero,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: purchaseBoxHeight - 180,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue[100]),
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(padding: const EdgeInsets.fromLTRB(0, 0, 100, 0), child: Text('총액 : ${CustomCommonUtil.formatPrice(totalPrice)}')),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(onPressed: () => Get.to(() => UserPurchaseView()), child: Text('결제 화면')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  } //fuction

  // int get totalPrice {
  //   return data.fold(0, (sum, item) {
  //     return sum + ((item.p_price ?? 0) * (item.cc_quantity ?? 1));
  //   });
  // }

  void _inc(int index) {
    CartStorage.updateQuantity(index, data[index].quantity + 1);
    data[index].quantity += 1;
    totalPrice += data[index].p_price;
    setState(() {});
  }

  void _dec(int index) {
    if (data[index].quantity > 1) {
      CartStorage.updateQuantity(index, data[index].quantity - 1);
      data[index].quantity -= 1;
      totalPrice -= data[index].p_price;
      setState(() {});
    }
  }

  void _remove(int index) {
    CartStorage.removeItem(index);
    data.removeAt(index);
    totalPrice = 0;
    setState(() {});
  }

  void _goPurchase() {
    print("결제 화면 이동 시도");
  }
}
