import 'package:flutter/material.dart';
import 'package:get/get.dart'
    show Get, GetNavigation, ExtensionBottomSheet;
import 'package:shoes_shop_app/model/purchase_item_bundle.dart';

class UserPurchaseView extends StatefulWidget {
  const UserPurchaseView({super.key});

  @override
  State<UserPurchaseView> createState() =>
      _UserPurchaseViewState();
}

class _UserPurchaseViewState
    extends State<UserPurchaseView> {
  //property
  String ipAddress = "172.16.250.175";
  List<PurchaseItemBundle> data = []; //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('결제하기'),
        centerTitle: true,
      ),
      body: data.isEmpty
          ? Center(child: Text('no data'))
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
                              // Text(
                              //   "단가: ${data[index].p_price ?? 0}원",
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //   ),
                              // ),
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
                            // IconButton(
                            //   onPressed: () =>
                            //       _remove(index),
                            //   icon: Icon(
                            //     Icons.delete_outline,
                            //     color: Colors.black54,
                            //   ),
                            //   // constraints: BoxConstraints(),
                            //   //padding: EdgeInsets.zero,
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  //function
  showType1BottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Type #1 Bottom Sheet'),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showType2BottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Type #1 Bottom Sheet'),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showGet1BottomSheet() {
    Get.bottomSheet(
      Container(
        height: 200,
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Type #1 Bottom Sheet'),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
