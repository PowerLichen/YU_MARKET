/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 내가 차단한 대상에 대한 목록을 확인하고 목록 수정을 할 수 있는 기능 페이지
* */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yu_market/mypage/setting.dart';

class Ban {
  String userName;
  Ban(this.userName);
}

String uid = FirebaseAuth.instance.currentUser.uid;

class BanList extends StatefulWidget {
  @override
  _BanListState createState() => _BanListState();
}

class _BanListState extends State<BanList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.block),
            SizedBox(
              width: 10,
            ),
            Text('사용자 차단 설정',style: TextStyle(fontFamily: mySetting.font))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('User')
                  .document(uid)
                  .collection('Ban')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.documents;
                return Expanded(
                  child: ListView(
                    children:
                        documents.map((doc) => _buildBanWidget(doc)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanWidget(DocumentSnapshot doc) {
    final ban = Ban(doc['UserName']);
    return ListTile(
      onTap: () {},
      title: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.white,
                ),
                backgroundColor: Colors.black,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                ban.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,fontFamily: mySetting.font
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 1.0,
            width: 500,
            color: Colors.black,
          ),
        ],
      ),
      trailing: RaisedButton(
        child: Text(
          '차단 해제',
          style: TextStyle(
            color: Colors.white,fontFamily: mySetting.font
          ),
        ),
        color: Colors.black,
        onPressed: () => _deleteBan(doc),
      ),
    );
  }

  void _deleteBan(DocumentSnapshot doc) {
    setState(() {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('정말 차단 해제 하시겠습니까?',style: TextStyle(fontFamily: mySetting.font),),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                  child: Text('예',style: TextStyle(fontFamily: mySetting.font),),
                  onPressed: () {
                    Firestore.instance
                        .collection('User')
                        .document(uid)
                        .collection('Ban')
                        .document(doc.documentID)
                        .delete();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('아니요',style: TextStyle(fontFamily: mySetting.font),),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    });
  }
}
