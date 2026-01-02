import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config_testsy.dart' as config_testsy;
import 'package:shoes_shop_app/model/refund_admin.dart';

class AdminRefundView extends StatefulWidget {
  const AdminRefundView({super.key});

  @override
  State<AdminRefundView> createState() => _AdminRefundViewState();
}

class _AdminRefundViewState extends State<AdminRefundView> {
  late List data;
  late Map dataSeq;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    data = [];
    dataSeq = {};
    getJSONData();
    _searchController = TextEditingController();
  }

  Future<void> getJSONData({String? search}) async{
    var urlStr = 'http://127.0.0.1:8000/api/refunds/admin/all';
    if (search != null && search.isNotEmpty){
      urlStr += '?search=$search';
    }
    var url = Uri.parse(urlStr);
    print('Request URL: $url');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    data = result.map((e) => RefundAdmin.fromJson(e)).toList(); // model의 factory형태

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('반품 목록'),
        centerTitle: true,
        toolbarHeight: 48, // 앱바 높이 최소화
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: data.isEmpty
            ? Text('데이터가 없습니다.')
            : Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '고객명/반품번호 찾기',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) => getJSONData(search: value),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final refund = data[index];
                      return GestureDetector(
                        onTap: () => getJSONrefSeqData(data[index].ref_seq),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${refund.ref_seq}', style: config_testsy.titleStyle),
                                Text('${refund.u_name}', style: config_testsy.mediumTextStyle)
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ],
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
                  Card(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('반품 번호: ${dataSeq['ref_seq']}', style: config_testsy.titleStyle),
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Card(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('고객 상세 정보',
                              style: config_testsy.titleStyle,
                            ),
                            Text('이름: ${dataSeq['u_name']}\n연락처: ${dataSeq['u_phone']}\n이메일: ${dataSeq['u_email']}',
                              style: config_testsy.mediumTextStyle,
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Card(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('반품 상품',
                              style: config_testsy.titleStyle,
                            ),
                            Text('${dataSeq['p_name']}  |  ${dataSeq['color_name']}  |  ${dataSeq['size_name']}  |  ${dataSeq['b_quantity']}개',
                              style: config_testsy.mediumTextStyle,
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
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
  Future<void> getJSONrefSeqData(int r_seq) async{
    var url = Uri.parse('http://127.0.0.1:8000/api/refunds/admin/${r_seq}/full_detail');
    print(url);
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    dataSeq = dataConvertedJSON['results'];
    print(dataSeq);

    setState(() {});
  }
  

}

/*

변경 이력
2025-01-02: 임소연
  - 전체 반품내역, 반품내역 클릭시 상세 반품정보 제공
  - 검색 기능 추가
*/