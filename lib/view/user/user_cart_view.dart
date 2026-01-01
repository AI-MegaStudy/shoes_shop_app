import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/product_join.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  // Property
  //String ipAddress = "127.0.0.1"; //ip
  //late List<ProductJoin> data; //유저의 카트 목록
  //late int productSeq;

  String ipAddress = "10.0.2.2";
  List<ProductJoin> data = [];
  int productSeq = 1;

  @override
  void initState() {
    super.initState();
    //data=[];
    initStorage();
    getJSONData();
  }

  void initStorage() {
    productSeq = 1;
  }

  Future<void> getJSONData() async {
    try {
      var url = Uri.parse(
        'http://$ipAddress:8000/api/products/$productSeq/full_details',
      );
      var response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
        List result = dataConvertedJSON['results'] ?? [];

        if (mounted) {
          setState(() {
            data = result.map((e) => ProductJoin.fromJson(e)).toList();
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
        title: Text('장바구니'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: data.isEmpty
          ? Center(child: Text('데이터가 없습니다.'))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text("상품 번호: ${data[index].cc_seq}"),
                  subtitle: Text("가격: ${data[index].p_price ?? 0}원"),
                );
              },
            ),
    );
  }
}
