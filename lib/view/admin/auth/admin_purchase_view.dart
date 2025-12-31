import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/purchase_item_join.dart';

class AdminPurchaseView extends StatefulWidget {
  const AdminPurchaseView({super.key});

  @override
  State<AdminPurchaseView> createState() => _AdminPurchaseViewState();
}

class _AdminPurchaseViewState extends State<AdminPurchaseView> {
  late List<PurchaseItemJoin> data;
  late int purchase_item_seq;

  @override
  void initState() {
    super.initState();
    data = [];
    purchase_item_seq = 1;
    getJSONData();
  }

  Future<void> getJSONData() async{
    var url = Uri.parse('http://127.0.0.1:8000/api/purchase_items/purchase_items/${purchase_item_seq}/full_detail');
    print(url);
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print(result);
    PurchaseItemJoin item = PurchaseItemJoin.fromJson(result);
    data = [item];
    print(data[0].b_seq);
    setState(() {});

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자'),
        centerTitle: true,
        toolbarHeight: 48, // 앱바 높이 최소화
      ),
      drawer: Drawer(
        child: data.isEmpty
        ? Text('데이터가 없습니다.')
        : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final purchase_item = data[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${purchase_item.p_seq}'),
                  Text('${purchase_item.u_name}')
                ],
              ),
            );
          }
        )
      ),
    );
  }
}