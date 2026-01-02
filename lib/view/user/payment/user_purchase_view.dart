import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart'
    show Get, GetNavigation, ExtensionBottomSheet;
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';

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

class UserPurchaseView extends StatefulWidget {
  const UserPurchaseView({super.key});

  @override
  State<UserPurchaseView> createState() =>
      _UserPurchaseViewState();
}

class _UserPurchaseViewState
    extends State<UserPurchaseView> {
  //property
  Product? product = Get.arguments;
  String ipAddress = "172.16.250.175";
  List<CartItem> data = []; //
  int totalPrice = 0;
  int productSeq = 1;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    loadCartData();
    for (var d in CartStorage.getCart()) {
      totalPrice +=
          int.parse(d['p_price'].toString()) *
          int.parse(d['quantity'].toString());
      data.add(CartItem.fromJson(d));
    }
    initStorage();
    getJSONData();
    _initiateCard();
    // data.addAll(CartStorage.getCart().map((d) => CartItem.fromJson(d)).toList());
  }

  void loadCartData() {
    final cartList = CartStorage.getCart();
    int tempTotal = 0;
    List<CartItem> tempList = [];

    for (var d in cartList) {
      int price =
          int.tryParse(d['p_price'].toString()) ?? 0;
      int qty = int.tryParse(d['quantity'].toString()) ?? 1;
      tempTotal += price * qty;
      tempList.add(CartItem.fromJson(d));
    }

    setState(() {
      data = tempList;
      totalPrice = tempTotal;
    });
  }

  void updateTotalPrice() {
    int tempTotal = 0;
    for (var item in data) {
      tempTotal += item.p_price * item.quantity;
    }
    setState(() {
      totalPrice = tempTotal;
    });
  }

  void _initiateCard() {
    final item = CartItem(
      p_seq: product!.p_seq!,
      p_name: product!.p_name,
      p_price: product!.p_price,
      cc_seq: product!.cc_seq,
      cc_name: product!.p_color!,
      sc_seq: product!.sc_seq,
      sc_name: product!.p_size!,
      gc_seq: product!.gc_seq,
      gc_name: product!.p_gender!,
      quantity: quantity,
      p_image: product!.p_image,
    ).toJson();
    print(item);
    CartStorage.addToCart(item);
  }

  void initStorage() {
    productSeq = 1;
  }

  Future<void> getJSONData() async {
    try {
      var url = Uri.parse(
        'http://$ipAddress:8000/api/products/',
      );
      var response = await http
          .get(url)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List result = dataConvertedJSON['results'] ?? [];

        if (mounted) {
          setState(() {
            data = result
                .map((e) => CartItem.fromJson(e))
                .toList();
          });
        }
      }
    } catch (e) {
      print("연결 에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('결제'),
        centerTitle: true,
      ),
      body: data.isEmpty
          ? Center(child: Text('no data'))
          : Column(
              children: [
                Expanded(
                  child: SizedBox(
                    // width: MediaQuery.of(
                    //   context,
                    // ).size.width,
                    // height:
                    //     MediaQuery.of(context).size.height -
                    //     150,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          margin:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              16.0,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.white,
                                    child: Image.network(
                                      //'http://172.16.250.175:8000/api/products/?t=${DateTime.now().microsecondsSinceEpoch}',
                                      'https://cheng80.myqnapcloud.com/images/${data[index].p_image}',
                                      width: 100,
                                      loadingBuilder:
                                          (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress ==
                                                null)
                                              return child;
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },

                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            print(
                                              "이미지 로딩 에러: $error",
                                            );
                                            return Container(
                                              width: 100,
                                              height: 90,
                                              color: Colors
                                                  .grey[200],
                                              child: Icon(
                                                Icons.error,
                                                color: Colors
                                                    .red,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        "${data[index].p_name}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${data[index].cc_name} / ${data[index].sc_name} / ${data[index].gc_name}",
                                        style: TextStyle(
                                          color: Colors
                                              .black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "단가: ${data[index].p_price ?? 0}원",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.symmetric(
                                                horizontal:
                                                    10,
                                              ),
                                          child: Text(
                                            "${data[index].quantity ?? 1}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(
                      context,
                    ).size.width,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.blue[100],
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                0,
                                0,
                                150,
                                0,
                              ),
                          child: Text(
                            '총액 : ${totalPrice}원',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => showGetBottomSheet(),
            child: const Text('결제하기'),
          ),
        ),
      ),
    );
  }

  //function
  showTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Type #1 Bottom Sheet'),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showType2BottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Type #1 Bottom Sheet'),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showGetBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 200,
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Type #1 Bottom Sheet'),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
