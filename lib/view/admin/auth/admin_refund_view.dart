import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/config_testsy.dart' as config_testsy;
import 'package:shoes_shop_app/model/refund_admin.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';

class AdminRefundView extends StatefulWidget {
  const AdminRefundView({super.key});

  @override
  State<AdminRefundView> createState() => _AdminRefundViewState();
}

class _AdminRefundViewState extends State<AdminRefundView> {
  // 반품 목록 데이터
  late List data;

  // 반품 상세 데이터
  late Map dataSeq;

  // 검색
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
    final apiBaseUrl = config.getApiBaseUrl();
    var urlStr = '$apiBaseUrl/api/refunds/admin/all';
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
      backgroundColor: config_testsy.PColor.backgroundColor,
      appBar: config_testsy.AdminAppBar(title: '반품 목록'),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: data.isEmpty
            ? Text('데이터가 없습니다.')
            : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '고객명/반품번호 찾기',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: () {
                          getJSONData(search: _searchController.text);
                        },
                        icon: Icon(Icons.search)
                      )
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final refund = data[index];
                      return GestureDetector(
                        onTap: () => getJSONrefSeqData(data[index].ref_seq),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Card(
                            color: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: config_testsy.PColor.dividerColor, // 테두리 색상
                                width: 1.0,               // 테두리 두께
                              ),
                              borderRadius: BorderRadius.circular(12.0), // 모서리 곡률
                            ),
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
                        ),
                      );
                    }
                  ),
                ),
              ],
            )
          ),
          VerticalDivider(color: config_testsy.PColor.dividerColor),
          Expanded(
            flex: 2,
            child: dataSeq.isEmpty
            ? Text('')
            : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: config_testsy.PColor.dividerColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                            child: Text('반품 번호 ${dataSeq['ref_seq']}', style: config_testsy.titleStyle),
                          ),
                          Divider(color: config_testsy.PColor.dividerColor),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                            child: Text('반품 일시 ${dataSeq['ref_date'].toString().replaceAll('T', ' ')}', style: config_testsy.titleStyle),
                          ),
                          Divider(color: config_testsy.PColor.dividerColor),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('고객 상세 정보',
                                  style: config_testsy.titleStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text('이름: ${dataSeq['u_name']}',
                                    style: config_testsy.mediumTextStyle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                  child: Text('연락처: ${dataSeq['u_phone']}',
                                    style: config_testsy.mediumTextStyle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                  child: Text('이메일: ${dataSeq['u_email']}',
                                    style: config_testsy.mediumTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: config_testsy.PColor.dividerColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                    padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('반품 상품',
                            style: config_testsy.titleStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text('${dataSeq['p_name']}  |  ${dataSeq['color_name']}  |  ${dataSeq['size_name']}  |  ${dataSeq['b_quantity']}개',
                              style: config_testsy.mediumTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('총 가격: ${CustomCommonUtil.formatPrice(dataSeq['b_price'])}', style: config_testsy.titleStyle)),
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
  Future<void> getJSONrefSeqData(int r_seq) async{
    final apiBaseUrl = config.getApiBaseUrl();
    var url = Uri.parse('$apiBaseUrl/api/refunds/admin/$r_seq/full_detail');
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

2025-01-03: 임소연
  - 디자인 수정

*/