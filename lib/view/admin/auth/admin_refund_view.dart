import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/refund_detail.dart';

class AdminRefundView extends StatefulWidget {
  const AdminRefundView({super.key});

  @override
  State<AdminRefundView> createState() => _AdminRefundViewState();
}

class _AdminRefundViewState extends State<AdminRefundView> {
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
    var url = Uri.parse('http://127.0.0.1:8000/api/refunds/refunds/all');
    print(url);
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    data = result.map((e) => RefundDetail.fromJson(e)).toList(); // model의 factory형태

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
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: data.isEmpty
            ? Text('데이터가 없습니다.')
            : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final refund = data[index];
                return GestureDetector(
                  onTap: () => getJSONbSeqData(data[index].r_seq),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${refund.b_seq}'),
                        Text('${refund.u_name}')
                      ],
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
            ? Text('데이터가 없습니다.')
            : Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(child: Text('구매 번호: ${dataSeq['b_seq']}')),
                  Card(child: Text('주문자 상세 정보\n이름: ${dataSeq['u_name']}\n연락처: ${dataSeq['u_phone']}\n이메일: ${dataSeq['u_email']}')),
                  Card(child: Text('주문 상품들\n${dataSeq['p_name']}  |  ${dataSeq['color_name']}  |  ${dataSeq['size_name']}')),

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
  Future<void> getJSONbSeqData(int r_seq) async{
    var url = Uri.parse('http://127.0.0.1:8000/api/refunds/${r_seq}/full_detail');
    print(url);
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print(result);
    dataSeq = result;

    setState(() {});
  }
  

}

/*

변경 이력
2025-01-02: 임소연
  - 전체 구매내역, 구매내역 클릭시 상세 구매정보 제공

*/