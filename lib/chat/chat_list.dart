import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yumarket_chat/chat/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;

  const ChatListScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅목록"),
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
  String nickname, chatWithId;

  bool isLoading = false;

  void initState() {
    super.initState();
  }

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
          child: isLoading ? const Loading() : Container(),
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
                            //document.data()['photoUrl'] != null
                            // ? CachedNetworkImage(
                            //     placeholder: (context, url) => Container(
                            //       child: CircularProgressIndicator(
                            //         strokeWidth: 1.0,
                            //         valueColor:
                            //             AlwaysStoppedAnimation<Color>(themeColor),
                            //       ),
                            //       width: 50.0,
                            //       height: 50.0,
                            //       padding: EdgeInsets.all(15.0),
                            //     ),
                            //     imageUrl: document.data()['photoUrl'],
                            //     width: 50.0,
                            //     height: 50.0,
                            //     fit: BoxFit.cover,
                            //   )
                            // :
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
                                  style: TextStyle(color: Colors.black),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                              ),
                              Container(
                                child: Text(
                                  'ID: $peerId',
                                  style: TextStyle(color: Colors.black),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              )
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
                          peerAvatar: document.data()['photoUrl'],
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

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
