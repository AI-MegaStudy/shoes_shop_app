//dev_06.dart (작업자 :  김택권)

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Dev_06 extends StatefulWidget {
  const Dev_06({super.key});

  @override
  State<Dev_06> createState() => _Dev_06State();
}

class _Dev_06State extends State<Dev_06> {
  //Property
  //late 는 초기화를 나중으로 미룸
  
  // 색상 옵션 리스트 (한글, 실제 제품 데이터에 있는 색상)
  static const List<String> colorOptions = ['블랙', '그레이', '화이트'];
  
  // 각 제품별 초기 색상 인덱스 (0: 블랙, 1: 그레이, 2: 화이트)
  final int _u740wn2ColorIndex = 0;
  final int _nikeAir1ColorIndex = 0;
  final int _nikePegasusColorIndex = 0;
  final int _nikeShoxTLColorIndex = 0;

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
        title: const Text("김택권 페이지"),
        backgroundColor: Colors.blue, // AppBar 배경색
        foregroundColor: Colors.white, // AppBar 글자색
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          spacing: 40,
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