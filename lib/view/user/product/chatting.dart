import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
  String fb_doc_id = ''; //'VL4CihKJcvzws9lcASoZ'; // '9k9U3bHxup6LKg1LdtfH';
  Map<String, dynamic> current_user = {"id": -1, "name": "no name"};

  final String mainUrl = "http://127.0.0.1:8000/api";

  @override
  void initState() {
    super.initState();

    // 유저의 doc id가 존재 한지 DB확인
    // 세션이 종료된지 확인해야 함.
    // GetStorage storage = GetStorage();
    // final userJson = json.decode(storage.read('user'));
    current_user["id"] = 28;
    current_user["name"] = '빌게이츠';

    // create Doc_id for the user.
    // createDocId();
    checkGetChatting();
  }

  // 유저이름으로 쳇팅방이 있나 확인 없으면 방만들고 저장후 시작.
  Future<void> checkGetChatting() async {
    // 요청하여 값을 가져온다.
    // 전체 제품 가져오는 부분
    // String _url = mainUrl + "/products";
    String _url = mainUrl + "/chatting/by_user_seq?u_seq=${current_user["id"]}&is_closed=False";

    var url = Uri.parse(_url);
    var response = await http.get(url, headers: {});
    var jsonData = json.decode(utf8.decode(response.bodyBytes));
    print(jsonData);
    if (jsonData["result"] != null && jsonData["result"] != "Error") {
      // 존재 함.

      fb_doc_id = jsonData["result"]["fb_doc_id"];
      print('====== 존재함 ${fb_doc_id}');
    } else {
      // 존재 안함.
      // await createDocId();
      // Insert Chatting
      _url = mainUrl + "/chatting";
      url = Uri.parse(_url);
      response = await http.post(
        url,
        // headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {"u_seq": "1", "fb_doc_id": "aaa", "s_seq": "0", "is_closed": "0"},
        //{"u_seq": current_user["id"], "fb_doc_id": fb_doc_id, "s_seq": 0, "is_closed": false},
      );
      print(response);
      print('====== 존재 안함');
    }
    setState(() {});
  }

  Future<void> createDocId() async {
    CollectionReference chattings = FirebaseFirestore.instance.collection(fb_collection_id);

    // Add the data and get the DocumentReference of the new document
    DocumentReference documentRef = await chattings.add({
      'created_at': Timestamp.fromDate(DateTime.now()),
      'is_closed': false,
      'user_seq': current_user["id"],
      'data': {'datetime': Timestamp.fromDate(DateTime.now()), 'message': '상담사와 연결중입니다. 잠시 기다려 주십시요.', 'name': '시스템'},
    });

    // Access the auto-generated document ID
    String docId = documentRef.id;
    fb_doc_id = docId;
    // 쳇팅방을 저장한다.

    setState(() {});
    print('============ ${docId}');
  }

  Future<void> deleteDocData() async {
    await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).set({'data': []}).then((data) {
      print("cleared");
    });
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
                  ElevatedButton(onPressed: () => createDocId(), child: Text('CREATE DOC')),
                  ElevatedButton(onPressed: () => deleteDocData(), child: Text('Clear')),
                ],
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
    // final test = await FirebaseFirestore.instance.collection(fb_collection_id).doc('1111').get();
    // print('====== ${test} ======');

    final response = await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).get();
    final arrData = response['data'];
    value = teMessageController.text.trim();

    arrData.add({"name": current_user["name"], "message": value, "datetime": Timestamp.fromDate(DateTime.now())});

    await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).set({'data': arrData}).then((data) {
      teMessageController.text = '';
    });

    // print("${arrData[0]['who']} =============");
    // listMessage.add(
    //   MsgObj(name: user1, message: value, datetime: DateTime.now().toString()),
    // );
    // setState(() {});
    // Create 문서
  }

  Widget _buildWidget(doc) {
    MsgObj m = MsgObj(name: doc['name'], message: doc['message'], datetime: doc['datetime']);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: SizedBox(
        width: 200,
        height: 80,
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
