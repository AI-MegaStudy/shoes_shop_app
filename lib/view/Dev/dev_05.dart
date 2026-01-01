//dev_05.dart (작업자 : 정진석)

import 'package:flutter/material.dart';

class Dev_05 extends StatefulWidget {
  const Dev_05({super.key});

  @override
  State<Dev_05> createState() => _Dev_05State();
}

class _Dev_05State extends State<Dev_05> {
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
        title: const Text("정진석 페이지"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text("Hello"),
          ],
        ),
      ),
    );
  }


  //--------Functions ------------
  
  //------------------------------
}