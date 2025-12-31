import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/purchase_item_join.dart';

class UserPurchaseList extends StatefulWidget {
  const UserPurchaseList({super.key});

  @override
  State<UserPurchaseList> createState() => _UserPurchaseListState();
}

class _UserPurchaseListState extends State<UserPurchaseList> {
  // Property
  String ipAddress = "172.16.250.176"; //ip
  late List<PurchaseItemJoin> data; //유저의 구매 목록

  late int userSeq;
  final storage = GetStorage(); // 유저 정보 담은 get storage

  @override
  void initState() {
    super.initState();
    data = [];
    getJSONData();
  }

  void initStorage(){
    //userSeq = storage.read('user');
    userSeq = 4;
  }

  Future<void> getJSONData() async{
    var url = Uri.parse('http://${ipAddress}:8000/purchase_items/by_user/${userSeq}/with_details');
    var response = await http.get(url);

    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data = result.map((e) =>  PurchaseItemJoin.fromJson(e),).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        centerTitle: true,
      ),
      body: data.isEmpty
      ? Center(
        child: Text('데이터가 없습니다.'),
      )
      : Center(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return SizedBox(
              child: Row(
                children: [
                  Image.asset(data[index].p_image!),
                  Text(data[index].b_date!)
                ]
              ),
            );
          },
        )
      )
    );
  }
}