import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumarket_chat/chat/full_photo.dart';
import 'package:yumarket_chat/transaction/tradeAccept.dart';
import 'package:yumarket_chat/transaction/tradeReq.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String currentId;
  final String peerAvatar;

  const Chat({Key key, this.peerId, this.currentId, this.peerAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방'),
        centerTitle: true,
      ),
      body: ChatScreen(
        currentId: currentId,
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String currentId;
  final String peerAvatar;

  const ChatScreen({Key key, this.currentId, this.peerId, this.peerAvatar})
      : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, currentId: currentId);
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState(
      {Key key,
      @required this.currentId,
      @required this.peerId,
      @required this.peerAvatar});
  String peerId;
  String currentId;
  String peerAvatar;
  String postId;

  //List<QueryDocumentSnapshot> listMessage = new List.from([]);
  DocumentSnapshot postDoc;

  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  String imageUrl;

  int _limit = 20;
  final int _limitIncrement = 20;
  bool isShowFunc;

  final TextEditingController _textController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isComposing = false;

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("$currentId $peerId");
    _focusNode.requestFocus();
    listScrollController.addListener(_scrollListener);

    groupChatId = '';

    isShowFunc = false;
    isLoading = false;
    imageUrl = '';

    readLocal();
  }

  readLocal() async {
    //prefs = await SharedPreferences.getInstance();
    //user id 불러오기, 변경 필요
    if (currentId.hashCode <= peerId.hashCode) {
      setState(() {
        groupChatId = '$currentId-$peerId';
      });
    } else {
      setState(() {
        groupChatId = '$peerId-$currentId';
      });
    }    
    var chatDoc = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .get();
    setState(() {
      postId = chatDoc.data()['PostId'] ?? '';
    });

    postDoc =
        await FirebaseFirestore.instance.collection('Post').doc(postId).get();
  }

  void openFunction() {
    _focusNode.unfocus();
    setState(() {
      isShowFunc = !isShowFunc;
    });
  }

  Widget buildFunc() {
    double buttonSize = MediaQuery.of(context).size.height / 20;
    return Container(
      child: Row(
        children: [
          //사진 보내기 버튼
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.white,
                  child: Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.lightGreen,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.collections),
                      color: Colors.white,
                      iconSize: buttonSize,
                      onPressed: getImage,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  '사진 전송',
                  style: TextStyle(fontSize: buttonSize / 3),
                )
              ],
            ),
          ),
          SizedBox(width: 40.0),
          //거래 요청하기 버튼
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.white,
                  child: Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.lightBlue,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.near_me),
                      color: Colors.white,
                      iconSize: buttonSize,
                      onPressed: () async {                    
                        final bool result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TradeRequestScreen(
                                    postId: postId, postDoc: postDoc)));

                        if (result == true) {
                          _handleSubmitted(postId, 2);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  '거래 요청하기',
                  style: TextStyle(fontSize: buttonSize / 3),
                )
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300], width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(30.0),
      height: MediaQuery.of(context).size.height / 6,
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child("images/$fileName");
    UploadTask uploadTask = reference.putFile(imageFile);

    await uploadTask.whenComplete(() async {
      try {
        imageUrl = await reference.getDownloadURL();
        setState(() {
          isLoading = false;
          _handleSubmitted(imageUrl, 1);
        });
      } on FirebaseException catch (err) {
        setState(() {
          isLoading = false;
        });
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("This file is not an image"),
        ));
      }
    });
  }

  void _handleSubmitted(String content, int type) {
    // type: 0 = 메시지, 1 = image, 2 = 거래요청
    if (content.trim() != '') {
      _textController.clear();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': currentId,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print('nothing to send');
    }
    _textController.clear();
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == currentId) {
      // 오른쪽 (내 메시지)
      return Row(children: [
        document.data()['type'] == 0
            ? Container(
                //normal message
                child: Text(
                  document.data()['content'],
                ),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0)),
                margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
              )
            : document.data()['type'] == 1
                ?
                //image
                imageMessage(document)
                : Container(
                    //거래요청
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${DateFormat("M월 d일(E) h:mm a").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()['timestamp'])))}'),
                        Text('거래 요청이 완료되었습니다.')
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 100,
                    margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                  ),
      ], mainAxisAlignment: MainAxisAlignment.end);
    } else {
      //왼쪽 (상대 메시지)
      return Row(
        children: [
          document.data()['type'] == 0
              ? Container(
                  child: Text(
                    document.data()['content'],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(bottom: 10.0, left: 10.0),
                )
              : document.data()['type'] == 1
                  ?
                  //image
                  imageMessage(document)
                  : Container(
                      //거래승인
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TradeAcceptScreen(
                                      postId: postId,
                                      postDoc: postDoc,
                                      type: postDoc.data()['TradeType'])));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${DateFormat("M월 d일(E) h:mm a").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()['timestamp'])))}'),
                            Text('상대가 거래를 요청하였습니다.'),
                            Text('눌러서 확인해보세요!')
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      ),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      height: 100,
                      width: MediaQuery.of(context).size.width * 0.6,
                      margin: EdgeInsets.only(bottom: 10.0, left: 10.0),
                    ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  Widget imageMessage(DocumentSnapshot document) {
    return Container(
      //image
      child: FlatButton(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              width: 200.0,
              height: 200.0,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'images/img_not_available.jpeg',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: document.data()['content'],
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      FullPhoto(url: document.data()['content'])));
        },
        padding: EdgeInsets.all(0),
      ),
      margin: EdgeInsets.only(bottom: 10.0, right: 10.0, left: 10.0),
    );
  }

  Widget buildListMessage() {
    return Flexible(
        child: groupChatId == ''
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(groupChatId)
                    .collection(groupChatId)
                    .orderBy('timestamp', descending: true)
                    .limit(_limit)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data.docs[index]),
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  }
                },
              ));
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                  icon: Icon(Icons.control_point),
                  onPressed: openFunction,
                ),
              ),
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing
                    ? (value) {
                        _handleSubmitted(_textController.text, 0);
                      }
                    : null,
                decoration:
                    InputDecoration.collapsed(hintText: 'Send a message'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text, 0)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //나가기 버튼 미구현
    return Container(
        child: Stack(
      children: <Widget>[
        Column(
          children: [
            //List of messages
            buildListMessage(),
            Divider(height: 1.0),
            // function
            (isShowFunc ? buildFunc() : Container()),
            //input
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            )
          ],
        )
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
