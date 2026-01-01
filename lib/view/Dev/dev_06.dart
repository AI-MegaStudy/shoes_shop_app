//dev_06.dart (작업자 :  김택권)

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shoes_shop_app/view/Dev/cheng/product_detail_3d.dart';

class Dev_06 extends StatefulWidget {
  const Dev_06({super.key});

  @override
  State<Dev_06> createState() => _Dev_06State();
}

class _Dev_06State extends State<Dev_06> {
  //Property
  //late 는 초기화를 나중으로 미룸

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello"),
            // const SizedBox(height: 40),
            // // U740WN2 버튼
            // ElevatedButton(
            //   onPressed: () {
            //     Get.to(
            //       () => const ProductDetail3D(),
            //       arguments: {
            //         'imageNames': [
            //           'Newbalnce_U740WN2_Black_01.png',
            //           'Newbalnce_U740WN2_Gray_01.png',
            //           'Newbalnce_U740WN2_White_01.png',
            //         ],
            //         'initialIndex': 0,
            //       },
            //     );
            //   },
            //   child: const Text('U740WN2 (3D 뷰어)'),
            // ),
            // const SizedBox(height: 20),
            // // Nike Air 1 버튼
            // ElevatedButton(
            //   onPressed: () {
            //     Get.to(
            //       () => const ProductDetail3D(),
            //       arguments: {
            //         'imageNames': [
            //           'Nike_Air_1_Black_01.png',
            //           'Nike_Air_1_Gray_01.png',
            //           'Nike_Air_1_White_01.png',
            //         ],
            //         'initialIndex': 0,
            //       },
            //     );
            //   },
            //   child: const Text('Nike Air 1 (3D 뷰어)'),
            // ),
            // const SizedBox(height: 20),
            // // Nike Pegasus 버튼
            // ElevatedButton(
            //   onPressed: () {
            //     Get.to(
            //       () => const ProductDetail3D(),
            //       arguments: {
            //         'imageNames': [
            //           'Nike_Pegasus_Black_01.png',
            //           'Nike_Pegasus_Gray_01.png',
            //           'Nike_Pegasus_White_01.png',
            //         ],
            //         'initialIndex': 0,
            //       },
            //     );
            //   },
            //   child: const Text('Nike Pegasus (3D 뷰어)'),
            // ),
            // const SizedBox(height: 20),
            // // Nike Shox TL 버튼
            // ElevatedButton(
            //   onPressed: () {
            //     Get.to(
            //       () => const ProductDetail3D(),
            //       arguments: {
            //         'imageNames': [
            //           'Nike_Shox_TL_Black_01.png',
            //           'Nike_Shox_TL_Gray_01.png',
            //           'Nike_Shox_TL_White_01.png',
            //         ],
            //         'initialIndex': 0,
            //       },
            //     );
            //   },
            //   child: const Text('Nike Shox TL (3D 뷰어)'),
            // ),
          ],
        ),
      ),
    );
  }


  //--------Functions ------------
  
  //------------------------------
}