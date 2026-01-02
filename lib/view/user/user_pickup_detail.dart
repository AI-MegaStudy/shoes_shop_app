import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/model/pickup_join.dart';
import 'package:shoes_shop_app/config_pluralize.dart';

class UserPickupDetail extends StatefulWidget {
  const UserPickupDetail({super.key});

  @override
  State<UserPickupDetail> createState() => _UserPickupDetailState();
}

class _UserPickupDetailState extends State<UserPickupDetail> {
    // Property
  late PickupJoin data; //구매 묶음에 포함된 구매 목록

  @override
  void initState() {
    super.initState();
    data = Get.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수령 상세'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(edgeSpace),
        child: Center(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    'https://cheng80.myqnapcloud.com/images/${data.p_image}',
                    width: imageWidthBig,
                    height: imageWidthBig,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("제품명: ${data.p_name!}"),
                      Text("수량: ${data.b_quantity}"),
                      Text("수령 지점: ${data.br_name}"),
                      Text("가격: 총 ${data.b_price}원"),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: data.b_status == "1"
                      ? arriveColor
                      : data.b_status == "2"
                        ? pickedupColor
                        : data.b_status == "3"
                          ? refundColor
                          : orderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    productStatus[int.parse(data.b_status!)],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}