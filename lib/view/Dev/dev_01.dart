//dev_01.dart (작업자 : 이광태)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/view/user/product/list_view.dart';

class Dev_01 extends StatefulWidget {
  const Dev_01({super.key});

  @override
  State<Dev_01> createState() => _Dev_01State();
}

class _Dev_01State extends State<Dev_01> {
  //Property
  //late 는 초기화를 나중으로 미룸

  @override
  void initState() {
    //페이지가 새로 생성 될때 무조건 1번 사용 됨
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
        title: const Text("이광태 페이지"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ElevatedButton(onPressed: () => Get.to(() => ProductListView()), child: Text('제품'))],
        ),
      ),
    );
  }

  //--------Functions ------------

  //------------------------------
}
