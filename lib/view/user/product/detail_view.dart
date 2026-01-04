import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config.dart';
import 'package:shoes_shop_app/model/color_category.dart';
import 'package:shoes_shop_app/model/gender_category.dart';
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/model/size_category.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/view/user/payment/gt_user_cart_view.dart';
import 'package:shoes_shop_app/view/user/product/detail_module_3d.dart';
import 'package:http/http.dart' as http;

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

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  Product? product = Get.arguments;

  late int selectedGender = 2;
  late int selectedColor = 0;
  late int selectedSize = 0;
  bool isExist = true;

  int quantity = 1;
  // Map<String, dynamic> genderList = {'남성': 1, '여성': 2, '공통': 3};
  // List<String> genderList = ['남성', '여성', '공통'];
  List genderList = [];
  List colorList = [];
  // List<String> colorList = ['블랙', '화이트', '그레이', '레드', '블루', '그린', '옐로우'];
  // Map<String, dynamic> colorList = {'블랙': 1, '화이트': 2, '그레이': 3, '레드': 4, '블루': 5, '그린': 6, '옐로우': 7};
  // List<int> sizeList = [220, 225, 230, 235, 240, 250, 260, 270, 275, 280, 290];
  List sizeList = [];
  // == UI관련 색깔
  // 선택 버튼 background
  final Color selectedBgColor = Colors.blue;
  // 선택 버튼 foreground(Text Color)
  final Color selectedFgColor = Colors.white;
  // Title Font Size
  final double titleFontSize = 15.0;

  final String mainUrl = customApiBaseUrl + "/api"; //'http://127.0.0.1:8000/api';
  @override
  void initState() {
    super.initState();

    // Set default value before starting.

    // product!.gc_seq = selectedGender+1;
    // product!.sc_seq = selectedSize+1;
    // product!.p_gender = genderList[selectedGender];
    // product!.p_color = colorList[selectedColor];
    // product!.p_size = sizeList[selectedSize].toString();

    initializedData();
  }

  Future<void> initializedData() async {
    // Get Gender Data from Search

    String _url = mainUrl + "/gender_categories";

    var url = Uri.parse(_url);
    var response = await http.get(url, headers: {});
    var jsonData = json.decode(utf8.decode(response.bodyBytes));

    genderList.addAll(jsonData["results"].map((d) => GenderCategory.fromJson(d)).toList());

    _url = mainUrl + "/color_categories";
    url = Uri.parse(_url);
    response = await http.get(url, headers: {});
    jsonData = json.decode(utf8.decode(response.bodyBytes));
    colorList.addAll(jsonData["results"].map((d) => ColorCategory.fromJson(d)).toList());
    selectedColor = colorList.indexWhere((f) => f.cc_seq == product!.cc_seq);

    _url = mainUrl + "/size_categories";
    url = Uri.parse(_url);
    response = await http.get(url, headers: {});
    jsonData = json.decode(utf8.decode(response.bodyBytes));
    sizeList.addAll(jsonData["results"].map((d) => SizeCategory.fromJson(d)).toList());

    // Get Product with color,size,gender
    // price must update
    await getProduct("init");
  }

  Future<void> getProduct(String type) async {
    if (product!.p_seq == -1) {
      String _url = mainUrl + "/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}";

      final url = Uri.parse(_url);
      final response = await http.get(url);
      final jsonData = json.decode(utf8.decode(response.bodyBytes));

      if (jsonData != null && jsonData["results"].length > 0) {
        product = Product.fromJson(jsonData['results'][0]);
        selectedGender = genderList.indexWhere((f) => f.gc_seq == product!.gc_seq);
      }
    } else {
      String _url =
          mainUrl +
          "/products/getBySeqs/?m_seq=${product!.m_seq}&p_name=${product!.p_name}&cc_seq=${product!.cc_seq}&sc_seq=${product!.sc_seq}&gc_seq=${product!.gc_seq}";

      final url = Uri.parse(_url);
      final response = await http.get(url);
      final jsonData = json.decode(utf8.decode(response.bodyBytes));

      if (jsonData != null && jsonData["results"].length > 0) {
        product = Product.fromJson(jsonData['results'][0]);
        selectedGender = genderList.indexWhere((f) => f.gc_seq == product!.gc_seq);
        isExist = true;
      } else {
        isExist = false;
        Get.snackbar("알림", "죄송합니다. 선택한 ${type}의 제품이 존재 하지 않습니다. ", backgroundColor: Colors.blue[200]);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product!.p_name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 450,
                  // color: Colors.green,
                  child: GTProductDetail3D(),
                ),
                Text(
                  "상품명: ${product!.p_name}",
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                ),
                Text(
                  "가격: ${product!.p_price}원",
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                ),

                // 제품 설명
                Container(
                  width: MediaQuery.of(context).size.width,

                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                  child: Padding(padding: const EdgeInsets.all(8.0), child: Text(product!.p_description)),
                ),

                // Gender
                Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: _genderWidget()),

                // Size
                Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: _sizeWidget()),
                // color
                Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: _colorWidget()),
                // 수량
                isExist
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _quantityWidget(),

                            IconButton(
                              onPressed: () => _addCart(true),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green[100],

                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
                              ),

                              icon: Icon(Icons.shopping_cart, color: Colors.black),
                            ),
                            ElevatedButton(
                              onPressed: () => Get.to(() => const GTUserCartView()),

                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))),

                              child: Text('View'),
                            ),
                          ],
                        ),
                      )
                    : Text(''),
                isExist
                    ? Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ElevatedButton(
                          //   onPressed: () => Get.to(() => const GTUserCartView()),
                          //   style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))),

                          //   child: Text("장바구니 보기"),
                          // ),
                          ElevatedButton(
                            onPressed: () async {
                              // 카트에 추가
                              _addCart(false);
                              // Todo: GO to page
                              Get.to(() => GTUserCartView());
                            },
                            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))),

                            child: Text("바로구매"),
                          ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // 카트에서 삭제
                          //     CartStorage.clearCart();
                          //     List xx = CartStorage.getCart();
                          //     print(xx.length);
                          //   },
                          //   child: Text("장바구니 clear"),
                          // ),
                        ],
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Functions
  void _addCart(bool isMessage) {
    // 카트에 추가

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
    // Get Message
    if (isMessage) {
      Get.defaultDialog(
        title: "카트에 추가되었습니다.",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('성공적으로 추가 됬습니다.'),
            Text('상품명: ${product!.p_name} / ${product!.p_gender}'),
            Text('수 량: ${quantity}'),
            Text('가 격: ${product!.p_price * quantity}원'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("확인"),
          ),
        ],
      );
    }
  }

  // -- Widgets
  Widget _genderWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        Row(
          spacing: 5,
          children: List.generate(
            genderList.length,
            (index) => ElevatedButton(
              onPressed: () async {
                selectedGender = index;
                product!.gc_seq = genderList[selectedGender].gc_seq;
                product!.p_gender = genderList[selectedGender].gc_name;
                await getProduct(product!.p_gender!);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: selectedGender == index ? selectedBgColor : selectedFgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
              ),
              child: Text(genderList[index].gc_name, style: TextStyle(color: selectedGender == index ? selectedFgColor : Colors.black)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sizeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            spacing: 5,
            children: List.generate(
              sizeList.length,
              (index) => ElevatedButton(
                onPressed: () async {
                  selectedSize = index;
                  product!.sc_seq = sizeList[selectedSize].sc_seq;
                  product!.p_size = sizeList[selectedSize].sc_name;
                  print("${product!.m_seq},${product!.p_name}, ${product!.cc_seq},${product!.sc_seq}, ${product!.gc_seq}");
                  await getProduct("사이즈(${product!.p_size})");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSize == index ? selectedBgColor : selectedFgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
                ),
                child: Text("${sizeList[index].sc_name}", style: TextStyle(color: selectedSize == index ? selectedFgColor : Colors.black)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            spacing: 5,
            children: List.generate(
              colorList.length,
              (index) => ElevatedButton(
                onPressed: () async {
                  selectedColor = index;
                  product!.cc_seq = colorList[selectedColor].cc_seq;
                  product!.p_color = colorList[selectedColor].cc_name;
                  await getProduct("Color(${product!.p_color})");

                  // setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor == index ? selectedBgColor : selectedFgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5)),
                ),
                child: Text("${colorList[index].cc_name}", style: TextStyle(color: selectedColor == index ? selectedFgColor : Colors.black)),
              ),
            ),

            // colorList.entries
            //     .map(
            //       (entry) => ElevatedButton(
            //         onPressed: () {
            //           selectedColor = entry.value;
            //         },
            //         child: Text(entry.key),
            //       ),
            //     )
            //     .toList(),
          ),
        ),
      ],
    );
  }

  Widget _quantityWidget() {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue[100]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              quantity += 1;
              setState(() {});
            },
            icon: Icon(Icons.add),
          ),
          Container(
            width: 50,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('${quantity}'),
          ),
          IconButton(
            onPressed: () {
              if (quantity > 1) {
                quantity -= 1;
                setState(() {});
              }
            },
            icon: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
