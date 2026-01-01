import 'package:flutter/material.dart';

class UserPurchaseDetail extends StatefulWidget {
  const UserPurchaseDetail({super.key});

  @override
  State<UserPurchaseDetail> createState() => _UserPurchaseDetailState();
}

class _UserPurchaseDetailState extends State<UserPurchaseDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("주문 상세"),
        centerTitle: true,
      ),
    );
  }
}