import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/model/product.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/view/user/product/detail_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  String mainUrl = "http://127.0.0.1:8000/";
  List products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    // 요청하여 값을 가져온다.
    final url = Uri.parse(mainUrl + "api/products");
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    products = jsonData["results"].map((d) => Product.fromJson(d)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Page')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,

                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.green),

                child: Text('aaa'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 430,
                child: GridView.builder(
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10, // 가로
                    mainAxisSpacing: 10, // 세로
                  ),
                  itemBuilder: (context, index) {
                    return _displayProduct(products[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // body:Center(
      //   // 물건 정보
      //   child:
      //       ListView.builder(
      //       itemCount: products.length,
      //       itemBuilder: (context, index) {
      //           return _displayProduct(products[index]);
      //       },),

      // )
    );
  }

  Widget _displayProduct(Product p) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailView(), arguments: p),
      child: Card(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset('images/Nike_Air_1/Nike_Air_1_Black_01.avif', fit: BoxFit.contain),

            Column(children: [Text(p.pName), Text("${p.pPrice}")]),
          ],
        ),
      ),
    );
  }
}
