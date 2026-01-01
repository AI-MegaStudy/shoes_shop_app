import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/model/product.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  Product? product = Get.arguments;
  int selectedGender = 0;
  Map<String, dynamic> genderList = {'남성': 1, '여성': 2, '공통': 3};
  Map<String, dynamic> colorList = {'블랙': 1, '화이트': 2, '그레이': 3, '레드': 4, '블루': 5, '그린': 6, '옐로우': 7};
  List<int> sizeList = [];

  @override
  void initState() {
    super.initState();
    // 가능한 사이즈 리스트 가져오기
    sizeList = [220, 225, 230, 235, 240, 250, 260, 270, 275, 280, 290];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Detail ====')),
      body: Center(
        child: Column(
          children: [
            Container(width: MediaQuery.of(context).size.width, height: 200, color: Colors.green, child: Text('image')),

            // Gender
            _genderWidget(),

            // Size
            _sizeWidget(),
            // color
            _colorWidget(),
            // 제품 설명
            // Description
            Text(product!.p_name),
            Text(product!.p_description),
            Text(product!.p_price.toString()),
          ],
        ),
      ),
    );
  }

  // -- Widgets
  Widget _genderWidget() {
    return Row(
      children: genderList.entries
          .map(
            (entry) => ElevatedButton(
              onPressed: () {
                selectedGender = entry.value;
              },
              child: Text(entry.key),
            ),
          )
          .toList(),
    );
  }

  Widget _sizeWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        spacing: 5,
        children: List.generate(
          sizeList.length,
          (index) => ElevatedButton(
            onPressed: () {
              selectedGender = sizeList[index];
            },
            child: Text("${sizeList[index]}"),
          ),
        ),
      ),
    );
  }

  Widget _colorWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        spacing: 5,
        children: colorList.entries
            .map(
              (entry) => ElevatedButton(
                onPressed: () {
                  selectedGender = entry.value;
                },
                child: Text(entry.key),
              ),
            )
            .toList(),
      ),
    );
  }
}
