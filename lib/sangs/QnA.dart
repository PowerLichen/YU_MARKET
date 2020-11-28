/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 1:1 문의하기에서 자신이 문의한 내역과 문의하기 버튼을 통해 문의하기가 가능한 페이지
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_market/sangs/QnaRequest.dart';
import 'package:yu_market/mypage/setting.dart';

String uid = FirebaseAuth.instance.currentUser.uid;

class QNA extends StatefulWidget {
  @override
  _QNAState createState() => _QNAState();
}

class _QNAState extends State<QNA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline),
            SizedBox(
              width: 10,
            ),
            Text('1:1 문의 내역',style: TextStyle(fontFamily: mySetting.font),),
          ],
        ),
        actions: [
          RaisedButton(
            color: Colors.blueAccent,
            child: Text('1:1문의',style: TextStyle(fontFamily: mySetting.font),),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteDoc()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('User')
                  .document(uid)
                  .collection('QNA')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.documents;
                return Expanded(
                  child: ListView(
                    children: documents.map((doc) => _list(doc)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(DocumentSnapshot doc) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QNARequest(doc: doc)),
        );
      },
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('작성 날짜',style: TextStyle(fontFamily: mySetting.font),),
                  Text('제목',style: TextStyle(fontFamily: mySetting.font),),
                  Text('내용',style: TextStyle(fontFamily: mySetting.font),),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 60.0,
                width: 1.0,
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc['WriteDate'].toDate().toString().substring(0, 10),style: TextStyle(fontFamily: mySetting.font),),
                  Row(
                    children: [
                      Text(doc['Title'].length > 11
                          ? doc['Title'].substring(0, 11)
                          : doc['Title'],style: TextStyle(fontFamily: mySetting.font),),
                      Text(doc['Title'].length > 11 ? '...' : '',style: TextStyle(fontFamily: mySetting.font),),
                    ],
                  ),
                  Row(
                    children: [
                      Text(doc['Contents'].length > 11
                          ? doc['Contents'].substring(0, 11)
                          : doc['Contents'],style: TextStyle(fontFamily: mySetting.font),),
                      Text(doc['Contents'].length > 11 ? '...' : '',style: TextStyle(fontFamily: mySetting.font),),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              RaisedButton(
                color: doc['AnswerCheck'] ? Colors.blue : Colors.white,
                child: Text(
                  doc['AnswerCheck'] ? '답변 완료' : '접수 완료',
                  style: TextStyle(
                    color: doc['AnswerCheck'] ? Colors.black : Colors.white,fontFamily: mySetting.font
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class WriteDoc extends StatefulWidget {
  @override
  _WriteDocState createState() => _WriteDocState();
}

class _WriteDocState extends State<WriteDoc> {
  final _valueList = ['구매', '판매', '서비스'];
  var _selectedValue = '구매';
  var title, contents;
  @override
  Widget build(BuildContext _context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('1:1 문의',style: TextStyle(fontFamily: mySetting.font),),
        actions: [
          RaisedButton(
            child: Text('문의하기',style: TextStyle(fontFamily: mySetting.font),),
            onPressed: () async {
              if (title != null && contents != null) {
                await Firestore.instance
                    .collection('User')
                    .doc(uid)
                    .collection('QNA')
                    .add({
                  'Title': title,
                  'Contents': contents,
                  'AnswerCheck': false,
                  'WriteDate': Timestamp.now(),
                  'Type': _selectedValue
                });
                title = '';
                contents = '';
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('성공',style: TextStyle(fontFamily: mySetting.font),),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [Text('문의가 접수되었습니다.',style: TextStyle(fontFamily: mySetting.font),)],
                          ),
                        ),
                        actions: [
                          FlatButton(
                            child: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(_context).pop();
                            },
                          ),
                        ],
                      );
                    });
                //Navigator.pop(context);
              } else {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('실패',style: TextStyle(fontFamily: mySetting.font),),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [Text('내용을 입력 해주세요',style: TextStyle(fontFamily: mySetting.font),)],
                          ),
                        ),
                        actions: [
                          FlatButton(
                            child: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '분류 선택',
                  style: TextStyle(
                    fontSize: 20,fontFamily: mySetting.font
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton(
                  value: _selectedValue,
                  items: _valueList.map(
                    (value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value,style: TextStyle(fontFamily: mySetting.font)),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '제목 입력',
              style: TextStyle(fontSize: 30,fontFamily: mySetting.font),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: (text) => title = text,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '내용 입력',
              style: TextStyle(fontSize: 30,fontFamily: mySetting.font),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: (text) => contents = text,
            ),
          ],
        ),
      ),
    );
  }
}
