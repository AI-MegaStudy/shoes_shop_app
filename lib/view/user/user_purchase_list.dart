import 'dart:convert';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config_pluralize.dart';
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
    var url = Uri.parse('http://${ipAddress}:8000/api/purchase_items/purchase_items/by_user/${userSeq}/user_bundle');
    var response = await http.get(url);

    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data = result.map((e) =>  PurchaseItemBundle.fromJson(e),).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(edgeSpace),
        child: Center(
          child: data.isEmpty
          ? SizedBox(
            height: 100,
            child: Text('데이터가 없습니다.')
          )
          : Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  isDense: true,
                  suffixIcon: IconButton(
                    onPressed: () {
                      
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width/3,
                  height: 30,
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
                      setState(() {});
                    },
                  ),
                ),
              ),
              Expanded(
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
                        child: SizedBox(
                          child: Row(
                            children: [
                              SizedBox(
                                child: Image.network(
                                  'https://cheng80.myqnapcloud.com/${data[index].items!.first.p_image}',
                                  width: imageWidth,
                                  height: imageWidth,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox( //주문 묶음 한 개
                                width: MediaQuery.of(context).size.width/3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${data[index].order_date!}  ${data[index].order_time}"),
                                    Text(data[index].items!.first.p_name!),
                                    Text("포함 ${data[index].item_count}건"),
                                    Text("총 ${data[index].total_amount.toString()}원")
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: data[index].items!.first.b_status == "1"
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
                              )
                            ]
                          ),
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