
import 'package:shoes_shop_app/view/main/user/auth/user_auth_ui_config.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config_pluralize.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/refund_join.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/user/user_refund_detail.dart';

class UserRefundList extends StatefulWidget {
  const UserRefundList({super.key});

  @override
  State<UserRefundList> createState() => _UserRefundListState();
}

class _UserRefundListState extends State<UserRefundList> {
  late List<RefundJoin> data;
  late TextEditingController searchController;

  late int userSeq;
  final storage = GetStorage();

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

  void initStorage() {
    final userJson = storage.read<String>('user');
    final user = User.fromJson(jsonDecode(userJson!));
    userSeq = user.uSeq!;
  }

  Future<void> getJSONData() async {
    final apiBaseUrl = config.getApiBaseUrl();
    final keyword = searchController.text.trim();
    final queryParams = <String, String>{};
    if (keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }
    queryParams['order'] = selectedOrder;
    
    var url = Uri.parse('$apiBaseUrl/api/refunds/refund/by_user/$userSeq/all')
        .replace(queryParameters: queryParams);

    var response = await http.get(url);

    data.clear();
    var decoded = json.decode(utf8.decode(response.bodyBytes));
    List result = decoded['results'] ?? [];
    data = result.map((e) => RefundJoin.fromJson(e)).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('반품 내역'),
        centerTitle: true,
      ),
      body: Padding(
        padding: userAuthDefaultPadding,
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                isDense: true,
                suffixIcon: IconButton(
                  onPressed: () => getJSONData(),
                  icon: Icon(Icons.search),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            if (data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    height: dropboxHeight,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedOrder,
                      isDense: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: orderList.map(
                        (e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        },
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

            data.isEmpty
            ? SizedBox(height: 100, child: Text('데이터가 없습니다.'))
            : Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  return Padding(
                    padding: const EdgeInsets.all(cardSpace),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          UserRefundDetail(),
                          arguments: data[index],
                        )!
                            .then((value) => setState(() {}));
                      },
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Image.network(
                                'https://cheng80.myqnapcloud.com/images/${item.p_image}',
                                width: imageWidth,
                                height: imageWidth,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20),
                                child: SizedBox(
                                  width: MediaQuery.of(context)
                                          .size
                                          .width /
                                      3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${item.ref_date!.substring(0, 10)}  ${item.ref_date!.substring(11, 16)}",
                                      ),
                                      Text(item.p_name!),
                                      Text(
                                        "총 ${(item.b_price ?? 0) * (item.b_quantity ?? 0)}원",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: refundColor,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                productStatus[
                                    int.parse(item.b_status ?? "0")],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
