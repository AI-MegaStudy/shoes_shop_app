import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;

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

  String get mainUrl => "${config.getApiBaseUrl()}/api";

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
    String url0 = "$mainUrl/chatting/by_user_seq?u_seq=${current_user["id"]}&is_closed=false";

    print('[checkGetChatting] API 호출 시작');
    print('   URL: $url0');
    print('   User ID: ${current_user["id"]}');
    
    var url = Uri.parse(url0);
    var response = await http.get(url, headers: {});
    var jsonData = json.decode(utf8.decode(response.bodyBytes));
    
    print('[checkGetChatting] API 응답:');
    print('   Status Code: ${response.statusCode}');
    print('   Response Body: $jsonData');
    
    if (jsonData["result"] != null && jsonData["result"] != "Error") {
      // 존재 함.
      final result = jsonData["result"];
      fb_doc_id = result["fb_doc_id"] ?? '';
      
      print('[checkGetChatting] DB에 채팅 세션 존재');
      print('   fb_doc_id: $fb_doc_id');
      print('   chatting_seq: ${result["chatting_seq"]}');
      print('   is_closed: ${result["is_closed"]}');
      
      // Firebase 문서 존재 여부 확인
      if (fb_doc_id.isNotEmpty) {
        print('[checkGetChatting] Firebase 문서 존재 여부 확인 중...');
        final firebaseDoc = await FirebaseFirestore.instance
            .collection(fb_collection_id)
            .doc(fb_doc_id)
            .get();
        
        if (firebaseDoc.exists) {
          print('[checkGetChatting] Firebase 문서 존재 확인됨');
          print('   문서 데이터 키: ${firebaseDoc.data()?.keys.toList()}');
        } else {
          print('[checkGetChatting] Firebase 문서가 존재하지 않음!');
          print('   DB에는 fb_doc_id가 있지만 Firebase에는 문서가 없습니다.');
          print('   새 문서를 생성합니다...');
          
          // Firebase 문서 재생성
          await createDocId();
          
          // DB의 fb_doc_id 업데이트
          await _updateChattingDocId(result["chatting_seq"], fb_doc_id);
        }
      } else {
        print('[checkGetChatting] fb_doc_id가 비어있음');
        print('   새 문서를 생성합니다...');
        await createDocId();
        await _updateChattingDocId(result["chatting_seq"], fb_doc_id);
      }
    } else {
      print('[checkGetChatting] DB에 채팅 세션 없음');
      print('   새 채팅 세션 생성 시작...');
      
      // 존재 안함.
      await createDocId();
      print('[checkGetChatting] Firebase 문서 생성 완료');
      print('   생성된 fb_doc_id: $fb_doc_id');
      
      // Insert Chatting
      url0 = "$mainUrl/chatting";
      var request = http.MultipartRequest('POST', Uri.parse(url0));

      request.fields['u_seq'] = "${current_user["id"]}";
      request.fields['fb_doc_id'] = fb_doc_id;
      request.fields['s_seq'] = "0";
      request.fields['is_closed'] = "false";
      
      print('[checkGetChatting] DB에 채팅 세션 저장 중...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('[checkGetChatting] DB 저장 응답:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: $responseBody');
      
      if (response.statusCode == 200) {
        print('[checkGetChatting] DB 저장 성공');
      } else {
        print('[checkGetChatting] DB 저장 실패');
        print('   Firebase 문서는 생성되었지만 DB 저장에 실패했습니다.');
        // Todo: Snack Message
      }
    }
    setState(() {});
  }
  
  // DB의 채팅 세션 fb_doc_id 업데이트
  Future<void> _updateChattingDocId(int chattingSeq, String newDocId) async {
    try {
      print('[_updateChattingDocId] DB 업데이트 시작');
      print('   chatting_seq: $chattingSeq');
      print('   new_fb_doc_id: $newDocId');
      
      String url0 = "$mainUrl/chatting/$chattingSeq";
      var request = http.MultipartRequest('POST', Uri.parse(url0));
      
      request.fields['chatting_seq'] = "$chattingSeq";
      request.fields['u_seq'] = "${current_user["id"]}";
      request.fields['fb_doc_id'] = newDocId;
      request.fields['s_seq'] = "0";
      request.fields['is_closed'] = "false";
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('[_updateChattingDocId] 업데이트 응답:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: $responseBody');
      
      if (response.statusCode == 200) {
        print('[_updateChattingDocId] DB 업데이트 성공');
      } else {
        print('[_updateChattingDocId] DB 업데이트 실패');
      }
    } catch (e) {
      print('[_updateChattingDocId] 에러 발생: $e');
    }
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
              SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                // decoration: BoxDecoration(color: Colors.grey[200]),
                child: fb_doc_id == ''
                    ? Center(child: Text('wait'))
                    : StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).snapshots(),

                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            print('[StreamBuilder] 에러 발생: ${snapshot.error}');
                            print('   fb_doc_id: $fb_doc_id');
                            return Center(child: Text('에러 발생: ${snapshot.error}'));
                          }
                          
                          if (!snapshot.hasData) {
                            print('[StreamBuilder] snapshot.hasData가 false');
                            print('   fb_doc_id: $fb_doc_id');
                            return const Center(child: Text('데이터를 불러오는 중...'));
                          }
                          
                          if (!snapshot.data!.exists) {
                            print('[StreamBuilder] Firebase 문서가 존재하지 않음');
                            print('   fb_doc_id: $fb_doc_id');
                            print('   Collection: $fb_collection_id');
                            print('   문서가 삭제되었거나 잘못된 ID일 수 있습니다.');
                            
                            // 문서가 없으면 재생성 시도
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _handleMissingDocument();
                            });
                            
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('채팅방이 존재하지 않습니다.'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _handleMissingDocument(),
                                    child: const Text('채팅방 재생성'),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          final docData = snapshot.data!.data() as Map<String, dynamic>?;
                          if (docData == null || !docData.containsKey('data')) {
                            return const Center(child: Text('채팅 데이터가 없습니다.'));
                          }
                          
                          final arrData = docData['data'] as List<dynamic>?;
                          if (arrData == null) {
                            return const Center(child: Text('채팅 메시지가 없습니다.'));
                          }
                          
                          print("${arrData.length} =====");
                          return ListView.builder(
                            itemCount: arrData.length,
                            itemBuilder: (context, index) {
                              return _buildWidget(arrData[index]);
                            },
                          );
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
    print('[createDocId] Firebase 문서 생성 시작');
    print('   Collection: $fb_collection_id');
    print('   User ID: ${current_user["id"]}');
    print('   User Name: ${current_user["name"]}');
    
    try {
      CollectionReference chattings = FirebaseFirestore.instance.collection(fb_collection_id);
      
      // Add the data and get the DocumentReference of the new document
      DocumentReference documentRef = await chattings.add({
        'created_at': Timestamp.fromDate(DateTime.now()),
        'is_closed': false,
        'user_seq': current_user["id"],
        'data': [
          {'datetime': Timestamp.fromDate(DateTime.now()), 'message': '상담사와 연결중입니다. 잠시 기다려 주십시요.', 'name': '시스템'},
        ],
      });
      
      // Access the auto-generated document ID
      String docId = documentRef.id;
      fb_doc_id = docId;
      
      print('[createDocId] Firebase 문서 생성 완료');
      print('   생성된 문서 ID: $fb_doc_id');
      
      // 생성된 문서 확인
      final verifyDoc = await documentRef.get();
      if (verifyDoc.exists) {
        print('[createDocId] 문서 존재 확인됨');
        print('   문서 데이터: ${verifyDoc.data()}');
      } else {
        print('[createDocId] 문서 생성 후 확인 실패!');
      }
      
      setState(() {});
    } catch (e) {
      print('[createDocId] 에러 발생: $e');
      print('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // 문서가 없을 때 처리
  Future<void> _handleMissingDocument() async {
    print('[_handleMissingDocument] 문서 재생성 시작');
    print('   현재 fb_doc_id: $fb_doc_id');
    
    // 새 문서 생성
    await createDocId();
    
    // DB 업데이트 시도 (chatting_seq가 있으면)
    // 여기서는 간단히 setState만 호출
    setState(() {});
  }
  
  Future<void> insertMessage(String value) async {
    // Doc Id가 존재 한지 확인 존재 안하면 생성
    // final test = await FirebaseFirestore.instance.collection(fb_collection_id).doc('1111').get();
    // print('====== ${test} ======');

    final response = await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).get();
    
    if (!response.exists) {
      print('채팅 문서가 존재하지 않습니다.');
      return;
    }
    
    final docData = response.data();
    if (docData == null || !docData.containsKey('data')) {
      print('채팅 데이터가 없습니다.');
      return;
    }
    
    final arrData = List<dynamic>.from(docData['data'] as List? ?? []);
    value = teMessageController.text.trim();
    
    if (value.isEmpty) {
      return;
    }

    arrData.add({"name": current_user["name"], "message": value, "datetime": Timestamp.fromDate(DateTime.now())});

    await FirebaseFirestore.instance.collection(fb_collection_id).doc(fb_doc_id).set({'data': arrData}, SetOptions(merge: true)).then((data) {
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
                SizedBox(width: MediaQuery.of(context).size.width, child: Text(m.message)),
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
