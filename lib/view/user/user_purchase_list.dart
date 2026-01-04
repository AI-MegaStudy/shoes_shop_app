
import 'package:shoes_shop_app/view/main/user/auth/user_auth_ui_config.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config_pluralize.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/purchase_item_bundle.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/user/user_purchase_detail.dart';

class UserPurchaseList extends StatefulWidget {
  const UserPurchaseList({super.key});

  @override
  State<UserPurchaseList> createState() => _UserPurchaseListState();
}

class _UserPurchaseListState extends State<UserPurchaseList> {
  // Property
  late List<PurchaseItemBundle> data; //유저의 구매 목록
  late TextEditingController searchController;

  late int userSeq;
  final storage = GetStorage(); // 유저 정보 담은 get storage

  late String selectedOrder;
  late List<String> orderList;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    data = [];
    searchController = TextEditingController();
    selectedOrder = "최신순";
    orderList = ["최신순", "오래된 순", "가격 높은순", "가격 낮은순"];
    initStorage();
    getJSONData();
  }

  void initStorage(){
    final userJson = storage.read<String>('user');
    final user = User.fromJson(jsonDecode(userJson!));
    userSeq = user.uSeq!;
  }

  Future<void> getJSONData() async{
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // config.dart의 getApiBaseUrl() 사용하여 로컬/원격 서버 자동 선택
      final apiBaseUrl = config.getApiBaseUrl();
      final keyword = searchController.text.trim();
      final queryParams = <String, String>{};
      if (keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      queryParams['order'] = selectedOrder;
      
      var url = Uri.parse('$apiBaseUrl/api/purchase_items/by_user/$userSeq/user_bundle')
          .replace(queryParameters: queryParams);
      
      // 타임아웃 30초로 설정
      var response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.');
        },
      );

      if (response.statusCode == 200) {
        data.clear();
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
        List result = dataConvertedJSON['results'];
        data = result.map((e) =>  PurchaseItemBundle.fromJson(e),).toList();
        _errorMessage = null;
      } else {
        _errorMessage = '데이터를 불러오는데 실패했습니다. (상태 코드: ${response.statusCode})';
        data.clear();
      }
    } catch (e) {
      _errorMessage = '네트워크 오류가 발생했습니다: ${e.toString()}';
      data.clear();
      if (mounted) {
        Get.snackbar(
          '오류',
          _errorMessage!,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        centerTitle: true,
      ),
      body: Padding(
        padding: userAuthDefaultPadding,
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  isDense: true,
                  suffixIcon: IconButton(
                    onPressed: () {
                      getJSONData();
                      setState(() {});
                    }, 
                    icon: Icon(Icons.search)
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onChanged: (value) {
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width/3,
                    height: dropboxHeight,
                    child: DropdownButtonFormField<String>( //정렬 드롭다운
                      initialValue: selectedOrder,
                      isDense: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      items: orderList.map(
                        (e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 12
                              ),
                              ),
                          );
                        }
                      ).toList(), 
                      onChanged: (value) {
                        selectedOrder = value!;
                        getJSONData();
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _errorMessage != null
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: getJSONData,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                )
              : data.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text('데이터가 없습니다.'),
                  ),
                )
              : Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(cardSpace),
                      child: GestureDetector(
                        onTap: (){
                          Get.to(
                            UserPurchaseDetail(),
                            arguments: data[index].items
                          )!.then(
                            (value) => setState(() {})
                          );
                        },
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  child: Image.network(
                                    'https://cheng80.myqnapcloud.com/images/${data[index].items!.first.p_image}',
                                    width: imageWidth,
                                    height: imageWidth,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: SizedBox( //주문 묶음 한 개
                                    width: MediaQuery.of(context).size.width/3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${data[index].order_date!}  ${data[index].order_time}"),
                                        Text(data[index].items!.first.p_name!),
                                        data[index].item_count == 1
                                        ? Text("")
                                        : Text("외 ${data[index].item_count!-1}건"),
                                        Text("총 ${data[index].total_amount.toString()}원")
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: data[index].items!.first.b_status == "3"
                                    ? refundColor
                                    : data[index].items!.first.b_status == "2"
                                        ? pickedupColor
                                        : data[index].items!.first.b_status == "1"
                                            ? arriveColor
                                            : orderColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  productStatus[int.parse(data[index].items!.first.b_status!)],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          ]
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}