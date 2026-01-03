import 'package:flutter/material.dart';
import 'package:get/get.dart'
    show Get, GetNavigation, ExtensionSnackbar, SnackPosition;
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:slider_button/slider_button.dart';

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
  State<UserPurchaseView> createState() => _UserPurchaseViewState();
}

class _UserPurchaseViewState extends State<UserPurchaseView> {
  //property
  // Product? product = Get.arguments;
  // String ipAddress = "172.16.250.175";
  List<CartItem> data = [];
  int totalPrice = 0;
  double purchaseBoxHeight = 150.0;
  String selectedLocation = '강남구';
  final List<String> locations = ['강남구', '서초구', '송파구', '마포구', '영등포구'];

  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  // void loadCartData() {
  //   final cartList = CartStorage.getCart();
  //   int tempTotal = 0;
  //   List<CartItem> tempList = [];

  //   for (var d in cartList) {
  //     final item = CartItem.fromJson(d);
  //     tempList.add(item);
  //     tempTotal += item.p_price * item.quantity;
  //   }
  //   setState(() {
  //     data = tempList;
  //     totalPrice = tempTotal;
  //   });
  // }

  void loadCartData() {
    List<CartItem> tempList = [
      CartItem(
        p_seq: 1,
        p_name: "에어 포스 1 '07",
        p_price: 139000,
        cc_seq: 1,
        cc_name: "화이트",
        sc_seq: 1,
        sc_name: "270",
        gc_seq: 1,
        gc_name: "남성",
        quantity: 1,
        p_image:
            "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/389b709e-5102-4e55-aa5d-077774a877df/air-force-1-07-shoes-Wr0Q19.png",
      ),
      CartItem(
        p_seq: 2,
        p_name: "조던 1 레트로 하이 OG",
        p_price: 219000,
        cc_seq: 2,
        cc_name: "레드/블랙",
        sc_seq: 2,
        sc_name: "265",
        gc_seq: 1,
        gc_name: "남성",
        quantity: 2,
        p_image:
            "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/389b709e-5102-4e55-aa5d-077774a877df/air-force-1-07-shoes-Wr0Q19.png",
      ),
    ];

    int tempTotal = 0;
    for (var item in tempList) {
      tempTotal += item.p_price * item.quantity;
    }

    setState(() {
      data = tempList;
      totalPrice = tempTotal;
    });
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
          ? Center(child: Text('데이터가 없습니다.'))
          : Column(
              children: [
                //SingleChildScrollView(
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 150,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          // elevation: 0,
                          //margin: const EdgeInsets.symmetric(
                          //horizontal: 16,
                          //vertical: 8,
                          //),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    // child: SizedBox(
                                    width: 90,
                                    height: 90,
                                    // color: Colors.white,
                                    child: Image.network(
                                      //'http://172.16.250.175:8000/api/products/?t=${DateTime.now().microsecondsSinceEpoch}',
                                      'https://cheng80.myqnapcloud.com/images/${data[index].p_image}',
                                      width: 100,
                                      //fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${data[index].p_name}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${data[index].cc_name} / ${data[index].sc_name} / ${data[index].gc_name}",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "단가: ${data[index].p_price ?? 0}원",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            "${data[index].quantity ?? 1}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
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
                    width: MediaQuery.of(context).size.width,
                    height: purchaseBoxHeight - 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      // color: Colors.blue[100],
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 150, 0),
                          child: Text('총액 : ${totalPrice}원'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showPurchaseBottomSheet();
                            },
                            child: Text('결제하기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  showPurchaseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '최종 결제 확인',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('수령 지점 선택', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedLocation,
                isExpanded: true,
                items: locations
                    .map(
                      (loc) => DropdownMenuItem(value: loc, child: Text(loc)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedLocation = val);
                    Get.back();
                    // showPurchaseBottomSheet();
                  }
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('총액', style: TextStyle(fontSize: 18)),
                  Text(
                    '$totalPrice원',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: SliderButton(
                  action: () async {
                    completePurchase();
                    return true;
                  },
                  label: Text(
                    "밀어서 결제하기",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  width: MediaQuery.of(context).size.width - 40,
                  radius: 10,
                  buttonColor: Colors.blue,
                  backgroundColor: Colors.grey[300]!,
                  highlightedColor: Colors.blue,
                  baseColor: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  completePurchase() {
    Get.back();
    Get.snackbar(
      "결제 완료",
      "성공적으로 주문되었습니다.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
    );
    CartStorage.clearCart();
    setState(() {
      loadCartData();
    });
  }
}
