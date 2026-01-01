//dev_06.dart (작업자 :  김택권)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/payment_preview.dart';
import 'package:shoes_shop_app/view/Dev/product_detail_3d/product_detail_3d.dart';

class Dev_06 extends StatefulWidget {
  const Dev_06({super.key});

  @override
  State<Dev_06> createState() => _Dev_06State();
}

class _Dev_06State extends State<Dev_06> {
  //Property
  //late 는 초기화를 나중으로 미룸
  
  // 색상 옵션 리스트 (한글, 실제 제품 데이터에 있는 색상)
  static const List<String> colorOptions = ['블랙', '그레이', '화이트'];
  
  // 각 제품별 초기 색상 인덱스 (0: 블랙, 1: 그레이, 2: 화이트)
  int _u740wn2ColorIndex = 0;
  int _nikeAir1ColorIndex = 0;
  int _nikePegasusColorIndex = 0;
  int _nikeShoxTLColorIndex = 0;

  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
    
  }
  
  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("김택권 페이지"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          spacing: 40,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
         
            // U740WN2 - 드롭다운 + 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 색상 선택 드롭다운
                  DropdownButton<String>(
                    value: colorOptions[_u740wn2ColorIndex],
                    items: colorOptions.map((String color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _u740wn2ColorIndex = colorOptions.indexOf(newValue);
                        });
                      }
                    },
                  ),
                  
                  // 3D 뷰어 이동 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => const ProductDetail3D(),
                          arguments: {
                            'imageNames': [
                              'Newbalnce_U740WN2_Black_01.png',
                              'Newbalnce_U740WN2_Gray_01.png',
                              'Newbalnce_U740WN2_White_01.png',
                            ],
                            'colorList': ['블랙', '그레이', '화이트'],
                            'initialIndex': _u740wn2ColorIndex,
                          },
                        );
                      },
                      child: const Text('U740WN2 (3D 뷰어)'),
                    ),
                  ),
                ],
              ),
            ),
            // Nike Air 1 - 드롭다운 + 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 색상 선택 드롭다운
                  DropdownButton<String>(
                    value: colorOptions[_nikeAir1ColorIndex],
                    items: colorOptions.map((String color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _nikeAir1ColorIndex = colorOptions.indexOf(newValue);
                        });
                      }
                    },
                  ),
                  
                  // 3D 뷰어 이동 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => const ProductDetail3D(),
                          arguments: {
                            'imageNames': [
                              'Nike_Air_1_Black_01.png',
                              'Nike_Air_1_Gray_01.png',
                              'Nike_Air_1_White_01.png',
                            ],
                            'colorList': ['블랙', '그레이', '화이트'],
                            'initialIndex': _nikeAir1ColorIndex,
                          },
                        );
                      },
                      child: const Text('Nike Air 1 (3D 뷰어)'),
                    ),
                  ),
                ],
              ),
            ),
            // Nike Pegasus - 드롭다운 + 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 색상 선택 드롭다운
                  DropdownButton<String>(
                    value: colorOptions[_nikePegasusColorIndex],
                    items: colorOptions.map((String color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _nikePegasusColorIndex = colorOptions.indexOf(newValue);
                        });
                      }
                    },
                  ),
                  
                  // 3D 뷰어 이동 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => const ProductDetail3D(),
                          arguments: {
                            'imageNames': [
                              'Nike_Pegasus_Black_01.png',
                              'Nike_Pegasus_Gray_01.png',
                              'Nike_Pegasus_White_01.png',
                            ],
                            'colorList': ['블랙', '그레이', '화이트'],
                            'initialIndex': _nikePegasusColorIndex,
                          },
                        );
                      },
                      child: const Text('Nike Pegasus (3D 뷰어)'),
                    ),
                  ),
                ],
              ),
            ),
            // Nike Shox TL - 드롭다운 + 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 색상 선택 드롭다운
                  DropdownButton<String>(
                    value: colorOptions[_nikeShoxTLColorIndex],
                    items: colorOptions.map((String color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _nikeShoxTLColorIndex = colorOptions.indexOf(newValue);
                        });
                      }
                    },
                  ),
                  
                  // 3D 뷰어 이동 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => const ProductDetail3D(),
                          arguments: {
                            'imageNames': [
                              'Nike_Shox_TL_Black_01.png',
                              'Nike_Shox_TL_Gray_01.png',
                              'Nike_Shox_TL_White_01.png',
                            ],
                            'colorList': ['블랙', '그레이', '화이트'],
                            'initialIndex': _nikeShoxTLColorIndex,
                          },
                        );
                      },
                      child: const Text('Nike Shox TL (3D 뷰어)'),
                    ),
                  ),
                ],
              ),
            ),

            OutlinedButton(
              onPressed: () => Get.to(() => const PaymentPreview()),
              child: const Text('Payment Preview'),
            ),
          ],
        ),
      ),
    );
  }


  //--------Functions ------------
  
  //------------------------------
}