//dev_04.dart (작업자 : 임소연)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_pickup_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_purchase_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_refund_view.dart';

class Dev_04 extends StatefulWidget {
  const Dev_04({super.key});

  @override
  State<Dev_04> createState() => _Dev_04State();
}

class _Dev_04State extends State<Dev_04> {
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
        title: const Text("임소연 페이지"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             ElevatedButton(onPressed: () => Get.to(() => AdminPurchaseView()), child: Text('관리자 구매목록')),
             ElevatedButton(onPressed: () => Get.to(() => AdminPickupView()), child: Text('관리자 수령목록')),
             ElevatedButton(onPressed: () => Get.to(() => AdminRefundView()), child: Text('관리자 반품목록')),

          ],
        ),
      ),
    );
  }


  //--------Functions ------------
  
  //------------------------------
}