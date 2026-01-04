import 'package:shoes_shop_app/view/main/auth/user_auth_ui_config.dart';

import 'package:get/get.dart';
import 'package:shoes_shop_app/config_pluralize.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop_app/model/purchase_item_join.dart';

class UserPurchaseDetail extends StatefulWidget {
  const UserPurchaseDetail({super.key});

  @override
  State<UserPurchaseDetail> createState() => _UserPurchaseDetailState();
}

class _UserPurchaseDetailState extends State<UserPurchaseDetail> {
  // Property
  late List<PurchaseItemJoin> data; //구매 묶음에 포함된 구매 목록

  @override
  void initState() {
    super.initState();
    data = Get.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 상세'),
        centerTitle: true,
      ),
      body: Padding(
        padding: userAuthDefaultPadding,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text("${data[0].b_date!.substring(0,11)}  ${data[0].b_date!.substring(11)}"),
                      Text("주문자: ${data[0].u_name}"),
                      Text("연락처: ${data[0].u_phone}"),
                      Text("email: ${data[0].u_email}"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(cardSpace),
                      child: Center(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://cheng80.myqnapcloud.com/images/${data[index].p_image}',
                                  width: imageWidthBig,
                                  height: imageWidthBig,
                                  fit: BoxFit.cover,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("제품명: ${data[index].p_name!}"),
                                    Text("수량: ${data[index].b_quantity}"),
                                    Text("주문 지점: ${data[index].br_name}"),
                                    Text("가격: 총 ${data[index].b_price}원"),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: data[index].b_status == "1"
                                    ? arriveColor
                                    : data[index].b_status == "2"
                                      ? pickedupColor
                                      : data[index].b_status == "3"
                                        ? refundColor
                                        : orderColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  productStatus[int.parse(data[index].b_status!)],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}