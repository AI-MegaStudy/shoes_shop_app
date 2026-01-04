import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/model/product.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/view/main/main_user_drawer_menu.dart';
import 'package:shoes_shop_app/view/user/product/chatting.dart';
import 'package:shoes_shop_app/view/user/product/detail_view.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  // 보여지는 부분 height
  final double searchBoxSize = 100;
  // API Base URL
  String get mainUrl => config.getApiBaseUrl() + "/api";
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
    // 전체 제품 가져오는 부분
    // String _url = mainUrl + "/products";
    String _url = mainUrl + "/products/group_by_name";

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
            appBar: AppBar(title: Text('제품목록')),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Get.to(() => Chatting()),
              foregroundColor: Colors.green,
              backgroundColor: Colors.white,

              child: const Icon(Icons.chat_rounded),
            ),
            drawer: MainUserDrawerMenu(), //MainUserDrawerMenu,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
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
                          width: 75,
                          height: searchBoxSize - 45,
                          child: ElevatedButton(
                            onPressed: () => _searchProduct(),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('검색'),
                          ),
                        ),
                      ],
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
    String _url = mainUrl + "/products/searchByMain/?kwds=${searchController.text.trim()}";

    final url = Uri.parse(_url);
    final response = await http.get(url);
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.network('https://cheng80.myqnapcloud.com/images/${p.p_image}', height: 100),
            Text(p.p_name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text("${p.p_maker!} / ${p.p_color}", style: TextStyle(fontSize: 13, color: Colors.black54)),
            Text("${CustomCommonUtil.formatPrice(p.p_price)}"),
          ],
        ),
        // Container(
        //   // alignment: Alignment.bottomCenter,
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: NetworkImage('https://cheng80.myqnapcloud.com/images/${p.p_image}'),
        //       fit: BoxFit.contain,
        //       //
        //     ),
        //   ),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       Text(p.p_name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        //       Text("${p.p_maker!} / ${p.p_color}", style: TextStyle(fontSize: 13, color: Colors.black54)),
        //       Text("${CustomCommonUtil.formatPrice(p.p_price)}"),
        //     ],
        //   ),
        // ),
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
