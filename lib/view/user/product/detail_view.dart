import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/model/product.dart';
import 'package:shoes_shop_app/utils/cart_storage.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment/user_purchase_list.dart';
import 'package:shoes_shop_app/view/user/product/detail_module_3d.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class CartItem {
  int p_seq;
  String p_name;
  int p_price;
  int cc_seq;
  String cc_name;
  int sc_seq;
  String sc_name;
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
      'quantity': quantity,
      'p_image': p_image,
    };
  }
}

class _ProductDetailViewState extends State<ProductDetailView> {
  Product? product = Get.arguments;
  int selectedGender = 0;
  int selectedColor = 0;
  int selectedSize = 6;
  int quantity = 1;
  // Map<String, dynamic> genderList = {'남성': 1, '여성': 2, '공통': 3};
  List<String> genderList = ['남성', '여성', '공통'];
  List<String> colorList = ['블랙', '화이트', '그레이', '레드', '블루', '그린', '옐로우'];
  // Map<String, dynamic> colorList = {'블랙': 1, '화이트': 2, '그레이': 3, '레드': 4, '블루': 5, '그린': 6, '옐로우': 7};
  List<int> sizeList = [220, 225, 230, 235, 240, 250, 260, 270, 275, 280, 290];

  // == UI관련 색깔
  // 선택 버튼 background
  final Color selectedBgColor = Colors.blue;
  // 선택 버튼 foreground(Text Color)
  final Color selectedFgColor = Colors.white;
  // Title Font Size
  final double titleFontSize = 15.0;

  @override
  void initState() {
    super.initState();
    // 가능한 사이즈 리스트 가져오기
    // sizeList = [220, 225, 230, 235, 240, 250, 260, 270, 275, 280, 290];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Detail ====')),
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
                  child: GTProductDetail3D()
                ),
            
                Text(
                  "상품명: ${product!.p_name}",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "가격: ${product!.p_price}원",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            
                // 제품 설명
                Container(
                  width: MediaQuery.of(context).size.width,
            
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(product!.p_description),
                  ),
                ),
            
                // Gender
                _genderWidget(),
            
                // Size
                _sizeWidget(),
                // color
                _colorWidget(),
                // 수량
                Row(
                  spacing: 10,
                  children: [
                    _quantityWidget(),
                    ElevatedButton(
                      onPressed: () => _addCart(),
                      child: Text("장바구니 추가"),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        List xx = CartStorage.getCart();
            
                        for (var v in xx) {
                          print("===${v}");
                        }
                      }, // => Get.to(() => const UserPurchaseList()),
            
                      child: Text("장바구니 보기"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 카트에 추가
                      },
                      child: Text("바로구매"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 카트에서 삭제
                        CartStorage.clearCart();
                        List xx = CartStorage.getCart();
                        print(xx.length);
                      },
                      child: Text("장바구니 clear"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Functions
  void _addCart() {
    // 카트에 추가
    final item = CartItem(
      p_seq: product!.p_seq!,
      p_name: product!.p_name,
      p_price: product!.p_price,
      cc_seq: product!.cc_seq,
      cc_name: product!.p_color!,
      sc_seq: product!.sc_seq,
      sc_name: product!.p_size!,
      quantity: quantity,
      p_image: product!.p_image,
    ).toJson();

    print(item);

    CartStorage.addToCart(item);

    // Get Message
    Get.defaultDialog(
      title: "카트에 추가되었습니다.",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('성공적으로 추가 됬습니다.'),
          Text('상품명: ${product!.p_name}'),
          Text('수 량: ${quantity}'),
          Text('가 격: ${product!.p_price*quantity}원')
        ],
      ),
      actions: [
        TextButton(
          onPressed: (){
           Get.back(); 
          }, child: Text("확인"))
      ]
    );
  }

  // -- Widgets
  Widget _genderWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          spacing: 5,
          children: List.generate(
            genderList.length,
            (index) => ElevatedButton(
              onPressed: () {
                selectedGender = index;
                setState(() {});
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: selectedGender == index
                    ? selectedBgColor
                    : selectedFgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(5),
                ),
              ),
              child: Text(
                genderList[index],
                style: TextStyle(
                  color: selectedGender == index
                      ? selectedFgColor
                      : Colors.black,
                ),
              ),
            ),
          ),

          // genderList.entries
          //     .map(
          //       (entry) => ElevatedButton(
          //         onPressed: () {
          //           selectedGender = entry.value;
          //         },
          //         child: Text(entry.key),
          //       ),
          //     )
          //     .toList(),
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
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            spacing: 5,
            children: List.generate(
              sizeList.length,
              (index) => ElevatedButton(
                onPressed: () {
                  selectedSize = index;
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSize == index
                      ? selectedBgColor
                      : selectedFgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                ),
                child: Text(
                  "${sizeList[index]}",
                  style: TextStyle(
                    color: selectedSize == index
                        ? selectedFgColor
                        : Colors.black,
                  ),
                ),
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
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            spacing: 5,
            children: List.generate(
              colorList.length,
              (index) => ElevatedButton(
                onPressed: () {
                  selectedColor = index;
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor == index
                      ? selectedBgColor
                      : selectedFgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                ),
                child: Text(
                  "${colorList[index]}",
                  style: TextStyle(
                    color: selectedColor == index
                        ? selectedFgColor
                        : Colors.black,
                  ),
                ),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.blue[100],
      ),
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
