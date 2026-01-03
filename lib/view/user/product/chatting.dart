import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class Chatting extends StatefulWidget {
  const Chatting({super.key});

  @override
  State<Chatting> createState() => _ChattingState();
}

class MsgObj {
  String name;
  String message;
  Timestamp datetime;

  MsgObj({required this.name, required this.message, required this.datetime});

  factory MsgObj.fromJson(Map<String, dynamic> json) {
    return MsgObj(name: json['name'], message: json['message'], datetime: json['datetime']);
  }
}

class _ChattingState extends State<Chatting> {
  TextEditingController teMessageController = TextEditingController();
  List<MsgObj> listMessage = [];

  String fb_collection_id = 'chatting';
  String fb_doc_id = ''; // '9k9U3bHxup6LKg1LdtfH';
  Map<String, dynamic> current_user = {"id": -1, "name": "no name"};

  @override
  void initState() {
    super.initState();

    // 유저의 doc id가 존재 한지 DB확인
    // 세션이 종료된지 확인해야 함.
    GetStorage storage = GetStorage();
    final userJson = json.decode(storage.read('user'));
    current_user["id"] = userJson["uSeq"];
    current_user["name"] = userJson["uName"];
    print('${userJson['uEmail']} - ${userJson['uSeq']}');

    // create Doc_id for the user.
    createDocId();
  }

  Future<void> createDocId() async {}

  @override
  void dispose() {
    teMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatting')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 250,

            child: StreamBuilder(
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

            // child: ListView.builder(
            //   itemCount: listMessage.length,
            //   itemBuilder: (context, index) {
            //     return Card(
            //       child: Row(
            //         spacing: 10,
            //         children: [
            //           Text(listMessage[index].name),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [Text(listMessage[index].message)],
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
          ),

          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: TextField(
                  // onSubmitted: (value) => insertMessage(value),
                  controller: teMessageController,
                  keyboardType: TextInputType.text,
                  maxLines: 5,
                  minLines: 2,
                  decoration: InputDecoration(labelText: 'Text'),
                ),
              ),
              ElevatedButton(onPressed: () => insertMessage(""), child: Text('SEND')),
            ],
          ),
        ],
      ),
    );
  }

  // == Functions
  Future<void> createDoc() async {
    // final chattingDocName = await FirebaseFirestore.instance.collection('chatting')
    // .add({"chatId":'1','user':'test','datetime':DateTime.now().toString()});
    // print("${chattingDocName}======================");
    // 유저의 doc

    // Document->field:
    // {
    //   "userId":1,
    //   "chatId": 'firstchatId-1',
    //   'length': 2,
    //   "data": [
    //     {"who":'유저1', "message":"헬로우"},
    //     {"who":'담당자1', "message":'무엇을 도와 드릴까요?'},
    //   ]

    // }
  }

  Future<void> insertMessage(String value) async {
    // Doc Id가 존재 한지 확인 존재 안하면 생성
    final test = await FirebaseFirestore.instance.collection(fb_collection_id).doc('1111').get();
    print('====== ${test} ======');

    // final response = await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).get();
    // final arrData = response['data'];
    // value = teMessageController.text.trim();

    // arrData.add({"name":current_user["name"],"message":value,"datetime":Timestamp.fromDate(DateTime.now())});

    // await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).set({'data':arrData}).then((data){
    //   print("${arrData.length}=====");

    // });

    // print("${arrData[0]['who']} =============");
    // listMessage.add(
    //   MsgObj(name: user1, message: value, datetime: DateTime.now().toString()),
    // );
    // setState(() {});
    // Create 문서
  }

  Widget _buildWidget(doc) {
    MsgObj m = MsgObj(name: doc['name'], message: doc['message'], datetime: doc['datetime']);

    return Card(
      child: Row(
        spacing: 10,
        children: [
          Text(m.name),
          Text(m.message),
          // Text(m.datetime.toDate().toString())
        ],
      ),
    );
  }
}
