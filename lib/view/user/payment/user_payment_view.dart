import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/model/branch.dart';

class UserPaymentView extends StatefulWidget {
  const UserPaymentView({super.key});

  @override
  State<UserPaymentView> createState() =>
      _UserPaymentViewState();
}

class _UserPaymentViewState extends State<UserPaymentView> {
  //property
  late List<Branch> data;
  late int branchSeq;
  Branch? selectedBranch;
  String selectedPayment = 'toss';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = [];
    branchSeq = 1;
    getJSONData();
  }

  Future<void> getJSONData() async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      var url = Uri.parse('$apiBaseUrl/api/branches');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(
          utf8.decode(response.bodyBytes),
        );

        List result = [];
        if (dataConvertedJSON is List) {
          result = dataConvertedJSON;
        } else if (dataConvertedJSON['results'] != null) {
          result = dataConvertedJSON['results'];
        }

        setState(() {
          data = result
              .map((e) => Branch.fromJson(e))
              .toList();
          if (data.isNotEmpty) {
            selectedBranch = data[0];
          }
        });
      }
    } catch (e) {
      print("API 에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('주소/결제방법'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Text(
              '수령지점(자치구)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            DropdownButton<Branch>(
              value: selectedBranch,
              dropdownColor: Colors.white,
              //Theme.of(context).colorScheme.primaryContainer,
              iconEnabledColor: Colors.black,
              //Theme.of(context).colorScheme.error,
              icon: Icon(Icons.keyboard_arrow_down),
              items: data.map((Branch branch) {
                return DropdownMenuItem<Branch>(
                  value: branch,
                  child: Text(branch.br_name),
                );
              }).toList(),
              onChanged: (Branch? newValue) {
                //dropDownValue = value!;
                //imageName = value;
                selectedBranch = newValue;
                setState(() {});
              },
            ),

            SizedBox(height: 60),
            Text(
              '결제수단',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            DropdownButton(
              dropdownColor: Colors.white,
              //Theme.of(context).colorScheme.primaryContainer,
              iconEnabledColor: Colors.black,
              //Theme.of(context).colorScheme.error,
              value: selectedPayment,
              icon: Icon(Icons.keyboard_arrow_down),
              items: ['toss', '카드결제', '계좌이체'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      //Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedPayment = newValue!;
                //dropDownValue = value!;
                //imageName = value;
                setState(() {});
              },
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: selectedBranch == null
                  ? null
                  : () {
                      print(
                        "지점:${selectedBranch!.br_name},결제:$selectedPayment",
                      );
                    },
              child: Text('변경'),
            ),
          ],
        ),
      ),
    );
  }
}
