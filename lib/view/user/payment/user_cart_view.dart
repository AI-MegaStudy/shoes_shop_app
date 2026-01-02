import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/product_join.dart';

class UserCartView extends StatefulWidget {
  const UserCartView({super.key});

  @override
  State<UserCartView> createState() => _UserCartViewState();
}

class _UserCartViewState extends State<UserCartView> {
  // Property
  //String ipAddress = "127.0.0.1"; //ip
  String ipAddress = "172.16.250.175"; //ip
  List<ProductJoin> data = [];
  int productSeq = 1;
  //late List<ProductJoin> data; //유저의 카트 목록
  //late int productSeq;

  @override
  void initState() {
    super.initState();
    initStorage();
    getJSONData();
    //data=[];
  }

  void initStorage() {
    productSeq = 1;
  }

  Future<void> getJSONData() async {
    try {
      var url = Uri.parse(
        'http://$ipAddress:8000/api/products/',
      );
      var response = await http
          .get(url)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List result = dataConvertedJSON['results'] ?? [];

        if (mounted) {
          setState(() {
            data = result
                .map((e) => ProductJoin.fromJson(e))
                .toList();
          });
        }
      }
    } catch (e) {
      print("연결 에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: data.isEmpty
          ? Center(child: Text('데이터가 없습니다.'))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(12),
                          child: Container(
                            width: 90,
                            height: 90,
                            color: Colors.white,
                            child: Image.network(
                              //'http://172.16.250.175:8000/api/products/?t=${DateTime.now().microsecondsSinceEpoch}',
                              'https://cheng80.myqnapcloud.com/images/Newbalnce_U740WN2_Black_01.png',
                              width: 100,
                            ),
                            // child: Image.asset(
                            //   "assets/images/shoes_sample.png", //data[index].p_image
                            //   fit: BoxFit.contain,
                            //   errorBuilder:
                            //       (
                            //         context,
                            //         error,
                            //         stackTrace,
                            //       ) => const Icon(
                            //         Icons
                            //             .image_not_supported,
                            //         size: 40,
                            //         color: Colors.grey,
                            //       ),
                            // ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "U740WN2", //data[index].p_name
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "색상: Gray / 사이즈: 230",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "단가: ${data[index].p_price ?? 0}원",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              // Text(
                              //   "합계: ${(data[index].p_price ?? 0) * (data[index].cc_quantity ?? 1)}원",
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  // onTap: () => _dec(index),
                                  child: Icon(
                                    Icons.remove,
                                    size: 20,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                  // child: Text(
                                  //   "${data[index].cc_quantity ?? 1}",
                                  //   style: TextStyle(
                                  //     fontSize: 18,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ),
                                GestureDetector(
                                  //onTap: () => _inc(index),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25),
                            IconButton(
                              onPressed: () =>
                                  _remove(index),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.black54,
                              ),
                              // constraints: BoxConstraints(),
                              //padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  } //fuction

  // int get totalPrice {
  //   return data.fold(0, (sum, item) {
  //     return sum + ((item.p_price ?? 0) * (item.cc_quantity ?? 1));
  //   });
  // }

  void _inc(int index) {
    //data[index].cc_quantity = (data[index].cc_quantity ?? 1) + 1;
    setState(() {});
  }

  void _dec(int index) {
    // if ((data[index].cc_quantity ?? 1) > 1) {
    //   setState(() {
    //     data[index].cc_quantity = (data[index].cc_quantity ?? 1) - 1;
    //   });
    // }
  }

  void _remove(int index) {
    data.removeAt(index);
    setState(() {});
  }

  void _goPurchase() {
    print("결제 화면 이동 시도");
  }
}
