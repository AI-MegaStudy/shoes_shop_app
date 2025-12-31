import 'package:flutter/material.dart';

class UserPurchaseList extends StatefulWidget {
  const UserPurchaseList({super.key});

  @override
  State<UserPurchaseList> createState() => _UserPurchaseListState();
}

class _UserPurchaseListState extends State<UserPurchaseList> {
  // Property
  late List data;

  @override
  void initState() {
    super.initState();
    data = [];
    getJSONData();
  }

  Future<void> getJSONData() async{
    var url = Uri.parse('http://172.16.250.176:8000/select');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        centerTitle: true,
      ),

    );
  }
}