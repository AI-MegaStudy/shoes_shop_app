//dev_03.dart (작업자 : 유다원)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/view/user/user_pickup_list.dart';
import 'package:shoes_shop_app/view/user/user_purchase_list.dart';
import 'package:shoes_shop_app/view/user/user_refund_list.dart';

class Dev_03 extends StatefulWidget {
  const Dev_03({super.key});

  @override
  State<Dev_03> createState() => _Dev_03State();
}

class _Dev_03State extends State<Dev_03> {
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
        title: const Text("유다원 페이지"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.to(() => UserPurchaseList()), 
              child: Text('주문 목록')
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => UserPickupList()), 
              child: Text('수령 목록')
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => UserRefundList()), 
              child: Text('반품 목록')
            )
          ],
        ),
      ),
    );
  }


  //--------Functions ------------
  
  //------------------------------
}