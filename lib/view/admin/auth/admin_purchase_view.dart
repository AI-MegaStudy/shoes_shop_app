import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/config_testsy.dart' as config_testsy;
import 'package:shoes_shop_app/model/purchase_item_join.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';


class AdminPurchaseView extends StatefulWidget {
  const AdminPurchaseView({super.key});

  @override
  State<AdminPurchaseView> createState() => _AdminPurchaseViewState();
}

class _AdminPurchaseViewState extends State<AdminPurchaseView> {
  // 주문 목록 데이터
  late List data;

  // 주문 상세 데이터
  late Map dataSeq;

  // 검색
  late TextEditingController _searchController;

  // 상품 상태 조회
  late List<String> bStatus;

  @override
  void initState() {
    super.initState();
    data = [];
    dataSeq = {};
    bStatus = [];
    getJSONData();
    _searchController = TextEditingController();
    print(_searchController.text);
  }

  Future<void> getJSONData({String? search}) async{
    final apiBaseUrl = config.getApiBaseUrl();
    var urlStr = '$apiBaseUrl/api/purchase_items/admin/all';
    if (search != null && search.isNotEmpty){
      urlStr += '?search=$search';
    }
    var url = Uri.parse(urlStr);
    print('Request URL: $url');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    print(result);
    data = result.map((e) => PurchaseItemJoin.fromJson(e)).toList(); // model의 factory형태
    bStatus = List<String>.from(result.map((e) => e['b_status'].toString())).toList();
    print(bStatus);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config_testsy.PColor.backgroundColor,
      appBar: config_testsy.AdminAppBar(title: '구매 목록'),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: data.isEmpty
            ? Center(child: Text('데이터가 없습니다.'))
            : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '고객명/구매번호 찾기',
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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statusContainer(0),
                        statusContainer(1),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statusContainer(2),
                        statusContainer(3),
                      ],
                    )
                  ],
                ), // b_status 리스트 만들어서 개수 출력
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final purchase_item = data[index];
                      return GestureDetector(
                        onTap: () => getJSONbSeqData(data[index].b_seq),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Card(
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
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${purchase_item.b_seq}', style: config_testsy.titleStyle),
                                      Text('${purchase_item.u_name}', style: config_testsy.mediumTextStyle),
                                    ],
                                  ),
                                  purchase_item.b_status != null 
                                  ? Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, size: 13, color: config_testsy.StatusConfig.bStatusColor(purchase_item.b_status)),
                                        Text(
                                          ' ${config_testsy.pickupStatus[int.parse(purchase_item.b_status)]}',
                                          style: config_testsy.mediumTextStyle
                                        ),
                                      ],
                                    ),
                                  )
                                  : Text('')
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
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: Text('구매 번호 ${dataSeq['b_seq']}', style: config_testsy.titleStyle),
                          ),
                          Divider(color: config_testsy.PColor.dividerColor),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text('구매 일시 ${dataSeq['b_date'].toString().replaceAll('T', ' ')}', style: config_testsy.titleStyle),
                          ),
                          Divider(color: config_testsy.PColor.dividerColor),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('수령 지점',
                                  style: config_testsy.titleStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text('${dataSeq['br_name']}\n${dataSeq['br_address']}',
                                    style: config_testsy.mediumTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: config_testsy.PColor.dividerColor),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('주문자 상세 정보',
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
                    padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('주문 상품',
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
                  dataSeq['b_status'] == '1'
                  ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: config_testsy.PColor.dividerColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    ),
                    onPressed: () {
                      insertPickup();
                      updatePurchaseItem(dataSeq['b_seq']);
                    }, 
                    child: Text('수령 완료', style: TextStyle(color: Colors.black),)
                  )
                  : Text(''),
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
  Widget statusContainer(int int){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
      child: Container(
        width: MediaQuery.of(context).size.width / 7,
        alignment: Alignment.center, // 텍스트를 박스 중앙에 정렬
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: config_testsy.StatusConfig.bStatusColor(int).withAlpha(200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Text('${config_testsy.pickupStatus[int]}', style: config_testsy.boldWhiteStyle),
              Text('${countStatus()[int]}', style: config_testsy.boldWhiteStyle),
            ],
          ),
        ),
      ),
    );
  }

  // --- functions ---
  List countStatus(){
    int count0 = 0;
    int count1 = 0;
    int count2 = 0;
    int count3 = 0;
    for (String n in bStatus){
      if (n == '0') count0++;
      if (n == '1') count1++;
      if (n == '2') count2++;
      if (n == '3') count3++;
    }
    return [count0, count1, count2, count3];
  }

  Future<void> getJSONbSeqData(int b_seq) async{
    final apiBaseUrl = config.getApiBaseUrl();
    var url = Uri.parse('$apiBaseUrl/api/purchase_items/admin/$b_seq/full_detail');
    print(url);
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print(result);
    dataSeq = result;
  
    setState(() {});
  }

  Future<void> insertPickup() async{
    final apiBaseUrl = config.getApiBaseUrl();
    var request = http.MultipartRequest( // Form 쓸려면 multipartrequest 써야 함
      'POST', 
      Uri.parse('$apiBaseUrl/api/pickups')
    );

    request.fields['b_seq'] = dataSeq['b_seq'].toString();
    request.fields['u_seq'] = dataSeq['u_seq'].toString();
    request.fields['created_at'] = CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd HH:mm:ss');


    var res = await request.send();
    if(res.statusCode == 200){
      _showDialog();
    }else{
      errorSnackbar();
    }
  }

  Future<void> updatePurchaseItem(int b_seq) async{
    final apiBaseUrl = config.getApiBaseUrl();
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('$apiBaseUrl/api/purchase_items/$b_seq')
    );

    request.fields['br_seq'] = dataSeq['br_seq'].toString();
    request.fields['u_seq'] = dataSeq['u_seq'].toString();
    request.fields['p_seq'] = dataSeq['p_seq'].toString();
    request.fields['b_price'] = dataSeq['b_price'].toString();
    request.fields['b_quantity'] = dataSeq['b_quantity'].toString();
    request.fields['b_date'] = dataSeq['b_date'];
    request.fields['b_status'] = '2';

    var res = await request.send();
    if(res.statusCode == 200){
      _showDialog();
    }else{
      errorSnackbar();
    }
  }
  

  void _showDialog(){
    Get.defaultDialog(
      title: '수령 결과',
      middleText: '수령이 완료되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () async{
            Get.back();
            await getJSONData();
            setState(() {});
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
  - 전체 구매내역, 구매내역 클릭시 상세 구매정보 제공
  - 수령 완료 버튼 클릭시 pickup 테이블에 정보 추가
  - 검색 기능 추가
  - b_status = 1(제품 준비 완료)일때만 수령 완료 버튼 노출

2025-01-03: 임소연
  - 디자인 수정
  - 수령 지점 추가
  
*/