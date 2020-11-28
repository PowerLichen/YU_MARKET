/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.21
* 기능 설명 : 사용자 정보 출력 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:yu_market/mypage/PrintTransactionList_sell.dart';
import 'package:yu_market/mypage/ReceivedReview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_market/mypage/setting.dart';

class UserData extends StatefulWidget {
  final uuid; // 물품 판매자(해당 유저)의 ID를 담을 final
  UserData({Key key,@required this.uuid}):super(key:key);
  @override
  _UserDataState createState() => _UserDataState(uuids: uuid);
}

class _UserDataState extends State<UserData>{
  final uuids;  //받아 온 ID를 저장할 final
  _UserDataState({Key key,@required this.uuids});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 정보 보기',style: TextStyle(fontFamily: mySetting.font)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('User').doc(uuids).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return CircularProgressIndicator();
          final doc = snapshot.data.data();

          return _UsbuildBody(doc);
        }
      ),
    );
  }

  Widget _UsbuildBody(doc){
    var currentUser = FirebaseAuth.instance.currentUser.uid;
    return Column(
      children: <Widget>[
        //아바타, 대상 이름, 평점
        Row(
          children: <Widget>[
            //아바타
            Column(
              children: <Widget>[
                SizedBox(width: 10,),
              ],
            ),
            Column(
              children: <Widget>[
                Icon(Icons.account_circle,size:80),
              ],
            ),
            Column(
              children: <Widget>[
                SizedBox(width: 10,),
              ],
            ),
            //이름
            Column(
              children: <Widget>[
                Text(doc['UserName'],style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              ],
            ),
            Column(
              children: <Widget>[
                SizedBox(width: 30,),
              ],
            ),
            //평점 
            Column(
              children: <Widget>[
                Text('평점',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                Text(doc['Score'].toString(),style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              ],
            ),
            Column(
              children: <Widget>[
                SizedBox(width: 30,),
              ],
            ),
            //거래횟수
            Column(
              children: <Widget>[
                Text('거래횟수',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                Text(doc['TradeCount'].toString(),style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              ],
            ),
          ],
        ),
        Divider(color: Colors.black,),
        InkWell(
          onTap:(){
            Navigator.push((context), MaterialPageRoute(builder: (context)=>ReceivedReview(ruid: uuids,myid: currentUser,))); // 해당 유저 아이디를 넘겨준다.
          } ,
          child: Padding(
            padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
            child: Row(
              children: <Widget>[
                //대상이 받은 후기 버튼
                Text('받은 후기 보기',style: TextStyle(fontSize: 25,fontFamily: mySetting.font)),
              ],
            ),
          ),
        ),
        Divider(color: Colors.black,),
        InkWell(
          onTap: (){
            Navigator.push((context), MaterialPageRoute(builder: (ctx)=>PrintTransactionList_sell(suid: uuids,myid: currentUser)));  //해당 유저 아이디를 넘겨준다.

          },
          child: Padding(
            padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
            child: Row(
              children: <Widget>[
                //대상이 받은 후기 버튼
                Text('판매 목록 보기',style: TextStyle(fontSize: 25,fontFamily: mySetting.font)),
              ],
            ),
          ),
        ),
        Divider(color: Colors.black,),
        Column(
          children: <Widget>[
            SizedBox(height: 100,),
          ],
        ),
        FirebaseAuth.instance.currentUser.uid==doc['UID']?
            Column():
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton( //차단하기 누르면 차단하기로 이동
              child:Text('차단하기',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
              onPressed: (){
                showDialog(context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context){
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        title: Column(
                          children: <Widget>[
                            Text('차단 안내',style: TextStyle(fontFamily: mySetting.font)),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('차단 하시겠습니까?',style: TextStyle(fontFamily: mySetting.font)),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('차단',style: TextStyle(fontFamily: mySetting.font)),
                            onPressed: (){
                              FirebaseFirestore.instance.collection('User').doc(currentUser).collection('Ban')
                                  .doc(doc['UserName'])
                                  .set({'UserName':doc['UserName']});
                              Navigator.of(context).pop();
                              Toast.show('차단성공', context);
                            },
                          ),
                          FlatButton(
                            child: Text('취소',style: TextStyle(fontFamily: mySetting.font)),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                );
              }
              // Navigator.push(ctx, MaterialPageRoute(builder: (ctx)=>UserBen(buser: uUser,)));},
            ),
          ],
        ),
      ],
    );
  }
}