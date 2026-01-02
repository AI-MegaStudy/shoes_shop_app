import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:shoes_shop_app/model/product.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/view/user/product/detail_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  // 보여지는 부분 height
  final double searchBoxSize = 100;

  final String mainUrl = 'http://172.16.250.187:8000/api'; //"http://127.0.0.1:8000/api";
  List products = [];
  bool isSearch = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts(null);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getProducts(String? kwd) async {
    // 요청하여 값을 가져온다.
    String _url = mainUrl + "/products";

    final url = Uri.parse(_url);
    final response = await http.get(url, headers: {});
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    products = jsonData["results"].map((d) => Product.fromJson(d)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return products.length == 0
        ? const Center(child: const CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(title: Text('Product Page')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: searchBoxSize,

                      child: TextField(
                        controller: searchController,
                        onSubmitted: (context) => _searchProduct(),
                        decoration: InputDecoration(
                          hintText: "원하는 신발을 찾아보세요",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - (searchBoxSize + 130),
                      child: isSearch
                          ? _noResultWidget()
                          : GridView.builder(
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
          );
  }

  // == Functions
  Future<void> _searchProduct() async {
    // Search by product name
    isSearch = true;
    String _url = mainUrl + "/products/search/?kwds=${searchController.text.trim()}";

    final url = Uri.parse(_url);
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));
    print(jsonData);
    print('================');
    if (jsonData != null && jsonData["results"].length > 0) {
      products = jsonData["results"].map((d) => Product.fromJson(d)).toList();
      isSearch = false;
    }
    setState(() {});
  }

  // == Widgets
  Widget _displayProduct(Product p) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailView(), arguments: p),
      child: Card(
        child: Container(
          // alignment: Alignment.bottomCenter,
          width: 50,

          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/Nike_Air_1/Nike_Air_1_Black_01.avif'),
              fit: BoxFit.contain,
              //
            ),
            // color: Colors.green,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(p.p_name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(p.p_maker!, style: TextStyle(fontSize: 13, color: Colors.black54)),
              Text("${p.p_price}원", style: TextStyle(decoration: TextDecoration.underline)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noResultWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('서치 결과가 없습니다.'),
        IconButton(
          onPressed: () {
            isSearch = false;
            searchController.text = '';
            setState(() {});
          },
          icon: Icon(Icons.refresh),
        ),
      ],
    );
  }
}
