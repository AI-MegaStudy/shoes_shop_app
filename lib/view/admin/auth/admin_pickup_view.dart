import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config_testsy.dart' as config_testsy;
import 'package:shoes_shop_app/model/pickup_admin.dart';

class AdminPickupView extends StatefulWidget {
  const AdminPickupView({super.key});

  @override
  State<AdminPickupView> createState() => _AdminPickupViewState();
}

class _AdminPickupViewState extends State<AdminPickupView> {
  late List data;
  late Map dataSeq;

  @override
  void initState() {
    super.initState();
    data = [];
    dataSeq = {};
    getJSONData();
  }

  Future<void> getJSONData() async{
    var url = Uri.parse('http://127.0.0.1:8000/api/pickups/admin/all');
    print(url);
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print('☁️ 수령 목록 ☁️: ${result}');
    data = result.map((e) => PickupAdmin.fromJson(e)).toList(); // model의 factory형태

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('수령 목록'),
        centerTitle: true,
        toolbarHeight: 48, // 앱바 높이 최소화
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: data.isEmpty
            ? Text('데이터가 없습니다.')
            : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final pickup = data[index];
                return GestureDetector(
                  onTap: () => getJSONpicSeqData(data[index].pic_seq),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${pickup.pic_seq}', style: config_testsy.titleStyle),
                              Text('${config_testsy.pickupStatus[int.parse(pickup.b_status)]}'),
                            ],
                          ),
                          Text('${pickup.u_name}', style: config_testsy.mediumTextStyle),
                        ],
                      ),
                    ),
                  ),
                );
              }
            )
          ),
          VerticalDivider(),
          Expanded(
            flex: 2,
            child: dataSeq.isEmpty
            ? Text('')
            : Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('수령 번호 ${dataSeq['pic_seq']}', style: config_testsy.titleStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('수령 일시 ${dataSeq['created_at'].toString().replaceAll('T', ' ')}', style: config_testsy.titleStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('주문자 상세 정보',
                            style: config_testsy.titleStyle,
                          ),
                          Text('이름: ${dataSeq['u_name']}\n연락처: ${dataSeq['u_phone']}\n이메일: ${dataSeq['u_email']}',
                            style: config_testsy.mediumTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('주문 상품',
                            style: config_testsy.titleStyle,
                          ),
                          Text('${dataSeq['p_name']}  |  ${dataSeq['color_name']}  |  ${dataSeq['size_name']}  |  ${dataSeq['b_quantity']}개',
                            style: config_testsy.mediumTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => insertRefund(), 
                    child: Text('반품 신청')
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('총 가격: ${dataSeq['b_price']}', style: config_testsy.titleStyle)),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  } // build

  // --- widgets ---

  // --- functions ---
  Future<void> getJSONpicSeqData(int pic_seq) async{
    var url = Uri.parse('http://127.0.0.1:8000/api/pickups/admin/${pic_seq}/full_detail');
    print(url);
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print('☁️ 상세 페이지 ☁️: ${result}');
    dataSeq = result;

    setState(() {});
  }

  Future<void> insertRefund() async{
    // Get.dialog(
    //   AlertDialog(
    //     title: Text('반품 사유 선택'),
    //     actions: [

    //     ],
    //   )
    // );
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('http://127.0.0.1:8000/api/refunds')
    );

    request.fields['u_seq'] = dataSeq['u_seq'].toString();
    request.fields['s_seq'] = 1.toString(); // staff sequence 추가
    request.fields['pic_seq'] = dataSeq['pic_seq'].toString();
    // 반품 사유 추가

    var res = await request.send();
    if(res.statusCode == 200){
      _showDialog();
    }else{
      errorSnackbar();
    }
  }
  void _showDialog(){
    Get.defaultDialog(
      title: '반품 완료',
      middleText: '반품이 완료되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          }, 
          child: Text('OK')
        )
      ]
    );
  }

  void errorSnackbar(){
    Get.snackbar(
      'Error', 
      '문제가 발생했습니다.'
    );
  }

}

/*

변경 이력
2025-01-02: 임소연
  - 전체 수령내역, 수령내역 클릭시 상세 수령정보 제공
  - 반품 신청 버튼 클릭시 refund 테이블에 정보 추가(수정필요)
*/