import 'package:flutter/material.dart';

class AdminPickupView extends StatefulWidget {
  const AdminPickupView({super.key});

  @override
  State<AdminPickupView> createState() => _AdminPickupViewState();
}

class _AdminPickupViewState extends State<AdminPickupView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자'),
      ),
    );
  }
}