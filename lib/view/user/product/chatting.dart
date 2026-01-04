import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart';
// import 'package:get_storage/get_storage.dart';

class Chatting extends StatefulWidget {
  const Chatting({super.key});

  @override
  State<Chatting> createState() => _ChattingState();
}

class MsgObj {
  String name;
  String message;
  Timestamp? datetime;

  MsgObj({required this.name, required this.message, this.datetime});

  factory MsgObj.fromJson(Map<String, dynamic> json) {
    return MsgObj(name: json['name'], message: json['message'], datetime: json['datetime']);
  }
}

class _ChattingState extends State<Chatting> {
  TextEditingController teMessageController = TextEditingController();
  List<MsgObj> listMessage = [];

  String fb_collection_id = 'chatting';
  String fb_doc_id = '';
  Map<String, dynamic> current_user = {"id": -1, "name": "no name"};

  final String mainUrl = customApiBaseUrl + "/api"; //"http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();

    // 유저의 doc id가 존재 한지 DB확인
    // 세션이 종료된지 확인해야 함.
    GetStorage storage = GetStorage();
    final userJson = json.decode(storage.read('user'));
    current_user["id"] = userJson['uSeq'];
    current_user["name"] = userJson['uName'];

    checkGetChatting();
  }

  // 유저이름으로 쳇팅방이 있나 확인 없으면 방만들고 저장후 시작.
  Future<void> checkGetChatting() async {
    String _url = mainUrl + "/chatting/by_user_seq?u_seq=${current_user["id"]}&is_closed=false";

    var url = Uri.parse(_url);
    var response = await http.get(url, headers: {});
    var jsonData = json.decode(utf8.decode(response.bodyBytes));
    print(jsonData);
    if (jsonData["result"] != null && jsonData["result"] != "Error") {
      // 존재 함.
      fb_doc_id = jsonData["result"]["fb_doc_id"] != null ? jsonData["result"]["fb_doc_id"] : '';
      print('====== 존재함 ${fb_doc_id}');
    } else {
      print('====== 존재 안함');
      // 존재 안함.
      await createDocId();
      // Insert Chatting
      _url = mainUrl + "/chatting";
      var request = http.MultipartRequest('POST', Uri.parse(_url));

      request.fields['u_seq'] = "${current_user["id"]}";
      request.fields['fb_doc_id'] = fb_doc_id;
      request.fields['s_seq'] = "0";
      request.fields['is_closed'] = "false";
      final response = await request.send();
      if (response.statusCode == 200) {
        // Success
        print('response ===== $response');
      } else {
        // Failed
        // Todo: Snack Message
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    teMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatting')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 300,
                // decoration: BoxDecoration(color: Colors.grey[200]),
                child: fb_doc_id == ''
                    ? Center(child: Text('wait'))
                    : StreamBuilder(
                        stream: FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).snapshots(),

                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: const CircularProgressIndicator());
                          }
                          final arrData = snapshot.data!['data'];
                          print("${arrData.length} =====");
                          return ListView.builder(
                            itemCount: arrData.length,
                            itemBuilder: (context, index) {
                              return _buildWidget(arrData[index]);
                            },
                          );

                          // ListView(
                          //   children: arrData.map((d) => _buildWidget(d)).toList(),
                          // );
                        },
                      ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 120,
                    child: TextField(
                      // onSubmitted: (value) => insertMessage(value),
                      controller: teMessageController,
                      keyboardType: TextInputType.text,
                      maxLines: 5,
                      minLines: 2,
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '여기에 글을 쓰시면 됩니다.',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () => insertMessage(""),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                      child: Text('SEND'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // == Functions
  Future<void> createDocId() async {
    print('hitted === ');
    CollectionReference chattings = FirebaseFirestore.instance.collection(fb_collection_id);
    print('1 === ');
    // Add the data and get the DocumentReference of the new document
    DocumentReference documentRef = await chattings.add({
      'created_at': Timestamp.fromDate(DateTime.now()),
      'is_closed': false,
      'user_seq': current_user["id"],
      'data': [
        {'datetime': Timestamp.fromDate(DateTime.now()), 'message': '상담사와 연결중입니다. 잠시 기다려 주십시요.', 'name': '시스템'},
      ],
    });
    print('2 == ');
    // Access the auto-generated document ID
    String docId = documentRef.id;
    fb_doc_id = docId;

    setState(() {});
  }

  Future<void> insertMessage(String value) async {
    // Doc Id가 존재 한지 확인 존재 안하면 생성
    // final test = await FirebaseFirestore.instance.collection(fb_collection_id).doc('1111').get();
    // print('====== ${test} ======');

    final response = await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).get();
    final arrData = response['data'];
    value = teMessageController.text.trim();

    arrData.add({"name": current_user["name"], "message": value, "datetime": Timestamp.fromDate(DateTime.now())});

    await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).set({'data': arrData}).then((data) {
      teMessageController.text = '';
    });
  }

  Widget _buildWidget(doc) {
    print(doc);
    if (doc == null || doc['name'] == null) {
      return Text('loading...');
    }
    MsgObj m = MsgObj(name: doc['name'], message: doc['message'], datetime: doc['datetime']);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: SizedBox(
        width: 200,

        child: Card(
          margin: m.name == current_user['name']
              ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 2.5, 0, 0, 0)
              : EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 2.5, 0),
          color: m.name == current_user['name'] ? Colors.blue[100] : Colors.green[100],
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: m.name == current_user['name'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start, // m.name == current_user['name'] ? MainAxisAlignment.end : MainAxisAlignment.start,
              spacing: 3,
              children: [
                Text(m.name, style: TextStyle(color: Colors.grey)),
                Container(width: MediaQuery.of(context).size.width, child: Text(m.message)),
                // m.name == current_user['name'] ? Container(width: MediaQuery.of(context).size.width, child: Text(m.message)) : Text(m.name),

                // m.name == current_user['name'] ? Text(m.name) : Container(width: MediaQuery.of(context).size.width, child: Text(m.message)),
                // Text(m.datetime.toDate().toString())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
