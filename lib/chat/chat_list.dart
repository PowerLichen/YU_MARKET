/*
* 최초 작성자 : 최민수
* 작성일 : 2020.11.16
* 변경일 : 2020.11.21
* 기능 설명 : 채팅 리스트를 출력하는 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/chat/chat_screen.dart';
import 'package:yu_market/mypage/setting.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;

  const ChatListScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅목록",style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: ChatList(currentUserId: currentUserId),
    );
  }
}

class ChatList extends StatefulWidget {
  final String currentUserId;

  const ChatList({Key key, this.currentUserId}) : super(key: key);
  @override
  _ChatListState createState() => _ChatListState(currentUserId: currentUserId);
}

class _ChatListState extends State<ChatList> {
  _ChatListState({Key key, @required this.currentUserId});

  final String currentUserId;
  String chatWithId;

  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: currentUserId == ''
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('User')
                      .doc(currentUserId)
                      .collection('chatList')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) {
                          return buildItem(
                              context, snapshot.data.documents[index]);
                        },
                        itemCount: snapshot.data.documents.length,
                      );
                    }
                  },
                ),
        ),
        Positioned(
          child: isLoading ? CircularProgressIndicator() : Container(),
        )
      ],
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    var chatWithDoc = FirebaseFirestore.instance
        .collection('User')
        .doc(document.data()['chatWith'])
        .get();
    String peerId = document.data()['chatWith'];

    if (document.data()['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: FutureBuilder<DocumentSnapshot>(
              future: chatWithDoc,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: <Widget>[
                      Material(
                        child:
                            Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Flexible(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '닉네임: ${snapshot.data['UserName']}',
                                  style: TextStyle(color: Colors.black,fontFamily: mySetting.font),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                              ),                              
                            ],
                          ),
                          margin: EdgeInsets.only(left: 20.0),
                        ),
                      ),
                    ],
                  );
                }
                return CircularProgressIndicator();
              }),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          currentId: currentUserId,
                          peerId: peerId,
                          postId: '',
                        )));
          },
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.black)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}