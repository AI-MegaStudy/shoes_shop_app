import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPurchaseList extends StatefulWidget {
  const UserPurchaseList({super.key});

  @override
  State<UserPurchaseList> createState() => _UserPurchaseListState();
}

class _UserPurchaseListState extends State<UserPurchaseList> {
  // Property
  String ipAddress = "127.0.0.1"; //ip
  late List data; //

  @override
  void initState() {
    super.initState();
    data = [];
    getJSONData();
  }

  Future<void> getJSONData() async{
    var url = Uri.parse('http://${ipAddress}:8000/select');
    var response = await http.get(url);

    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data = result.map((e) => ,).toList;

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
          itemBuilder: itemBuilder
        )
      )
    );
  }
}