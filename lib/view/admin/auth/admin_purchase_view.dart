import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/purchase_item_join.dart';
import 'package:shoes_shop_app/config_testsy.dart' as config_testsy;


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

  @override
  void initState() {
    super.initState();
    data = [];
    dataSeq = {};
    getJSONData();
    _searchController = TextEditingController();
    print(_searchController.text);
  }

  Future<void> getJSONData({String? search}) async{
    var urlStr = 'http://127.0.0.1:8000/api/purchase_items/admin/all';
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

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('구매 목록'),
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
                    hintText: '고객명/구매번호 찾기',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) => getJSONData(search: value),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final purchase_item = data[index];
                      return GestureDetector(
                        onTap: () => getJSONbSeqData(data[index].b_seq),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${purchase_item.b_seq}', style: config_testsy.titleStyle),
                                    purchase_item.b_status != null 
                                    ? Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: config_testsy.StatusConfig.bStatusColor(purchase_item.b_status),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text(
                                        '${config_testsy.pickupStatus[int.parse(purchase_item.b_status)]}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    )
                                    : Text('')
                                  ],
                                ),
                                Text('${purchase_item.u_name}', style: config_testsy.mediumTextStyle),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('구매 번호 ${dataSeq['b_seq']}', style: config_testsy.titleStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('구매 일시 ${dataSeq['b_date'].toString().replaceAll('T', ' ')}', style: config_testsy.titleStyle),
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
                  dataSeq['b_status'] == '1'
                  ? ElevatedButton(
                    onPressed: () {
                      insertPickup();
                      updatePurchaseItem(dataSeq['b_seq']);
                    }, 
                    child: Text('수령 완료')
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
  Future<void> getJSONbSeqData(int b_seq) async{
    var url = Uri.parse('http://127.0.0.1:8000/api/purchase_items/admin/${b_seq}/full_detail');
    print(url);
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print(result);
    dataSeq = result;
  
    setState(() {});
  }

  Future<void> insertPickup() async{
    var request = http.MultipartRequest( // Form 쓸려면 multipartrequest 써야 함
      'POST', 
      Uri.parse('http://127.0.0.1:8000/api/pickups')
    );

    request.fields['b_seq'] = dataSeq['b_seq'].toString();
    request.fields['u_seq'] = dataSeq['u_seq'].toString();

    var res = await request.send();
    if(res.statusCode == 200){
      _showDialog();
    }else{
      errorSnackbar();
    }
  }

  Future<void> updatePurchaseItem(int b_seq) async{
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('http://127.0.0.1:8000/api/purchase_items/${b_seq}')
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
*/