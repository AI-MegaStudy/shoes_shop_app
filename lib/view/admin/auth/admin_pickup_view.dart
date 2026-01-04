import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/config_testsy.dart' as config_testsy;
import 'package:shoes_shop_app/model/pickup_admin.dart';

class AdminPickupView extends StatefulWidget {
  const AdminPickupView({super.key});

  @override
  State<AdminPickupView> createState() => _AdminPickupViewState();
}

class _AdminPickupViewState extends State<AdminPickupView> {
  // 수령 목록 데이터
  late List data;

  // 수령 상세 데이터
  late Map dataSeq;

  // 반품 사유 선택 데이터
  late List refReasons;
  late String dropDownValue;

  // 검색
  late TextEditingController _searchController;


  @override
  void initState() {
    super.initState();
    data = [];
    refReasons = [];
    dataSeq = {};
    getJSONData();
    getJSONrefReasonData();
    dropDownValue = '';
    _searchController = TextEditingController();
  }

  Future<void> getJSONData({String? search}) async{
    final apiBaseUrl = config.getApiBaseUrl();
    var urlStr = '$apiBaseUrl/api/pickups/admin/all';
    if (search != null && search.isNotEmpty){
      urlStr += '?search=$search';
    }
    var url = Uri.parse(urlStr);
    print('Request URL: $url');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    // print('☁️ 수령 목록 ☁️: ${result}');
    data = result.map((e) => PickupAdmin.fromJson(e)).toList();

    setState(() {});
  }

  Future<void> getJSONrefReasonData() async{
    final apiBaseUrl = config.getApiBaseUrl();
    var url = Uri.parse('$apiBaseUrl/api/refund_reason_categories');
    print('Request URL: $url');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    refReasons = List<String>.from(result.map((e) => e['ref_re_name'].toString())).toList();
    print(refReasons);

    dropDownValue = refReasons[0];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config_testsy.PColor.backgroundColor,
      appBar: config_testsy.AdminAppBar(title: '수령 목록'),
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
                      hintText: '고객명/수령번호 찾기',
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
                      final pickup = data[index];
                      return GestureDetector(
                        onTap: () => getJSONpicSeqData(data[index].pic_seq),
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
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${pickup.b_seq}', style: config_testsy.titleStyle),
                                        Text('${pickup.u_name}', style: config_testsy.mediumTextStyle),
                                      ],
                                    ),
                                    pickup.b_status != null 
                                    ? Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, size: 13, color: config_testsy.StatusConfig.bStatusColor(pickup.b_status)),
                                          Text(
                                            ' ${config_testsy.pickupStatus[int.parse(pickup.b_status)]}',
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
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                            child: Text('수령 번호 ${dataSeq['pic_seq']}', style: config_testsy.titleStyle),
                          ),
                          Divider(color: config_testsy.PColor.dividerColor),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                            child: Text('수령 일시 ${dataSeq['created_at'].toString().replaceAll('T', ' ')}', style: config_testsy.titleStyle),
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
                  dataSeq['b_status'] == '2'
                  ? Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ElevatedButton(
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
                      onPressed: () => selectReason(),
                      child: Text('반품 신청', style: TextStyle(color: Colors.black))
                    ),
                  )
                  : Text(''),
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
    final apiBaseUrl = config.getApiBaseUrl();
    var url = Uri.parse('$apiBaseUrl/api/pickups/admin/$pic_seq/full_detail');
    print(url);
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print('☁️ 상세 페이지 ☁️: ${result}');
    dataSeq = result;

    setState(() {});
  }

  void selectReason(){
    Get.dialog(
      AlertDialog(
        title: const Text('반품 사유 선택'),
        backgroundColor: Colors.white,
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return DropdownButton<String>(
              dropdownColor: Colors.white,
              isExpanded: true,
              value: refReasons.contains(dropDownValue) ? dropDownValue : (refReasons.isNotEmpty ? refReasons.first : null),
              items: refReasons.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setDialogState(() {
                  dropDownValue = newValue!;
                });
                setState(() {
                  dropDownValue = newValue!;
                });
              },
            );
          },
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            ),
            onPressed: () {
              insertRefund();
              updatePurchaseItem(dataSeq['b_seq']);
            }, 
            child: Text('선택', style: TextStyle(color: Colors.black),)
          )
        ],
      )
    );
  }

  Future<void> insertRefund() async{
    final apiBaseUrl = config.getApiBaseUrl();
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('$apiBaseUrl/api/refunds')
    );

    request.fields['u_seq'] = dataSeq['u_seq'].toString();
    request.fields['s_seq'] = 16.toString(); // staff sequence 추가
    request.fields['pic_seq'] = dataSeq['pic_seq'].toString();
    request.fields['ref_re_name'] = dropDownValue;

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
    request.fields['b_status'] = '3';

    var res = await request.send();
    if(res.statusCode == 200){
      _showDialog();
      getJSONData();
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
  - 검색 기능 추가

2025-01-03: 임소연
  - 디자인 수정
*/