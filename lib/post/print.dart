//물품 리스트들에서 한 게시글을 클릭했을 시 오게되는 '물품 출력 화면'

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';
import 'package:yu_market/mypage/UserData.dart';
import 'package:yu_market/chat/chat_screen.dart';
import 'package:yu_market/sangs/Bid.dart';
import 'package:yu_market/mypage/setting.dart';


class PrintPage extends StatefulWidget {
  String DocumentID;
  String selleruid;

  PrintPage({Key key, @required this.DocumentID, this.selleruid}) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BuildContext _context;

  String uid = FirebaseAuth.instance.currentUser.uid; // 현재 접속 중인 User의 uid 불러오기

  @override
  Widget build(BuildContext context) {
    var newPost =
    FirebaseFirestore.instance.collection('Post').doc(widget.DocumentID).get();
    _context = context;
    String categorytwo = '의류';
    return Scaffold(
      appBar: AppBar(
          title: Text('',style: TextStyle(fontFamily: mySetting.font),),
          actions: <Widget>[
          FutureBuilder<DocumentSnapshot>(
           future: newPost,
          builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
            return uid==widget.selleruid?
                snapshot.data['Process']!=2?
            IconButton(
                icon: const Icon(Icons.delete, size: 40,),
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text('정말 삭제 하시겠습니까?',style: TextStyle(fontFamily: mySetting.font),),
                              ],
                            ),
                          ),
                          actions: [
                            FlatButton(
                              child: Text('예',style: TextStyle(fontFamily: mySetting.font),),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('Post').doc(widget.DocumentID).collection('TradeReq')
                                    .get().then((snapshot){
                                  for(DocumentSnapshot ds in snapshot.docs) ds.reference.delete();
                                });
                                FirebaseFirestore.instance.collection('Post').doc(
                                    widget.DocumentID).delete();
                                Navigator.of(context).pop();
                                Navigator.of(_context).pop();
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
                }
            ):Text('',style: TextStyle(fontFamily: mySetting.font),):Container();
    })
          ]

      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: newPost,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            if (snapshot.data['CategoryTwo'] == 1) categorytwo = '뷰티';
            if (snapshot.data['CategoryTwo'] == 2) categorytwo = '도서';
            if (snapshot.data['CategoryTwo'] == 3) categorytwo = '기타';
            // Timestamp ts = snapshot.data['WriteDate'];
            // String dt = timestampToStrDateTime(ts);
            return Padding(
                padding: EdgeInsets.all(20),
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Image.network(
                        snapshot.data['ImgPath'],
                        fit: BoxFit.scaleDown,
                      ),
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(width: 15, height: 10,),

                    Column(children: <Widget>[
                      Container(
                        decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.blueAccent)),
                        child: Row(children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.account_circle),
                              onPressed: () {
                                snapshot.data['SellerUID']!=uid?
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>UserData(uuid: snapshot.data['SellerUID']))):
                                Toast.show('본인의 정보입니다. 마이페이지에서 확인해주세요.',context);
                              }),
                          InkWell(
                            child: Text(snapshot.data['Seller'],
                                style: TextStyle(fontSize: 20,fontFamily: mySetting.font)),
                            onTap: () {
                              snapshot.data['SellerUID']!=uid?
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>UserData(uuid: snapshot.data['SellerUID']))):
                              Toast.show('본인의 정보입니다. 마이페이지에서 확인해주세요.',context);
                            },
                          ),
                        ]),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          snapshot.data['Title'],
                          style: TextStyle(fontSize: 30,fontFamily: mySetting.font),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5)),
                      Row(
                        children: <Widget>[
                          Text(
                            categorytwo,
                            style: TextStyle(
                                fontSize: 15, color: Colors.black54,fontFamily: mySetting.font),
                          ),
                          Text(
                            '  .  ' +
                                snapshot.data['WriteDate']
                                    .toDate()
                                    .toString()
                                    .substring(0, 16),
                            style: TextStyle(
                                fontSize: 15, color: Colors.black54,fontFamily: mySetting.font),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(15)),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          snapshot.data['Contents'],
                          style: TextStyle(fontSize: 20,fontFamily: mySetting.font),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(15)),
                      Container(
                        decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.black45)),
                        child: Row(
                          children: <Widget>[
                            Container(
                              decoration: new BoxDecoration(
                                  border:
                                  new Border.all(color: Colors.black45)),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.star,
                                      color: Colors.blue,
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(uid)
                                          .collection('Wish').doc(snapshot.data.id)
                                          .set({
                                        'PostID': snapshot.data.id,
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            snapshot.data['TradeType'] != 2 ?
                            Text(
                              '  ' +
                                  snapshot.data['Price'].toString() +
                                  '원     ',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black,fontFamily: mySetting.font),
                            ) : Text(
                              '  ' +
                                  snapshot.data['AuctionPrice'].toString() +
                                  '원     ',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black,fontFamily: mySetting.font),
                            ),
                            snapshot.data['SellerUID']!=uid?
                            snapshot.data['Process']==0?
                            RaisedButton(
                              child: snapshot.data['TradeType'] != 2 ? Text(
                                  '채팅으로 거래',
                                  style: TextStyle(fontSize: 20,fontFamily: mySetting.font)) : Text('입찰하기',
                                  style: TextStyle(fontSize: 20,fontFamily: mySetting.font)),
                              onPressed: () {
                                if (snapshot.data['TradeType'] == 2) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Bid(postid:snapshot.data['PostID'])));
                                }
                                else {
                                  Navigator.push(context,MaterialPageRoute(builder: (context)=>Chat(currentId: uid,peerId: snapshot.data['SellerUID'],postId:snapshot.data['PostID'])));

                                }
                              },
                            ):snapshot.data['Buyer']==uid && snapshot.data['Process']==1 && snapshot.data['TradeType']==2?
                            RaisedButton(
                              child: Text('채팅',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                              onPressed: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context)=>Chat(currentId: uid,peerId: snapshot.data['SellerUID'],postId: snapshot.data['PostID'],)));
                              },
                            )
                                :Container()
                                :snapshot.data['Process']==1 && snapshot.data['TradeType']==2?
                            RaisedButton(
                              child: Text('채팅',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                              onPressed: (){
                                Navigator.push(context,MaterialPageRoute(builder: (context)=>Chat(currentId: uid,peerId: snapshot.data['Buyer'],postId: snapshot.data['PostID'],)));
                              },
                            )
                                :Container()
                          ],
                        ),
                      ),
                    ]),
                  ],));
          }),);
  }}