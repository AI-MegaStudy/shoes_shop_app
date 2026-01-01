import 'dart:convert';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config_pluralize.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/purchase_item_bundle.dart';
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
        padding: const EdgeInsets.all(edgeSpace),
        child: Center(
          child: data.isEmpty
          ? SizedBox(
            height: 100,
            child: Text('데이터가 없습니다.')
          )
          : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(cardSpace),
                      child: GestureDetector(
                        onTap: (){
                          Get.to(UserPurchaseDetail())!.then(
                            (value) => setState(() {})
                          );
                        },
                        child: SizedBox(
                          child: Row(
                            children: [
                              SizedBox( //주문 묶음 한 개
                                width: MediaQuery.of(context).size.width-100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                      child: Image.asset(
                                        'images/dummy-profile-pic.png',
                                        width: MediaQuery.of(context).size.width-50,                            
                                        ),
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${data[index].b_date!.substring(0,11)}  ${data[index].b_date!.substring(11)}"),
                                            Text(data[index].p_name!),
                                            Text("수량: ${data[index].b_quantity}"),
                                            Text("총 ${data[index].b_price.toString()}원"),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: data[index].b_status == "제품 수령 완료"
                                                ? arriveColor
                                                : orderColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            data[index].b_status ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ]
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}