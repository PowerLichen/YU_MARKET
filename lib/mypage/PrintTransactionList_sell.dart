/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.23
* 기능 설명 : 판매 내역 출력 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:yu_market/mypage/setting.dart';
import 'package:yu_market/post/print.dart';

var ctx;
class PrintTransactionList_sell extends StatefulWidget {
  final suid; //판매자 UID(만약 다른 유저의 프로필에서 판매 목록을 본다면, 해당 유저 id)
  final myid; // 구매자 UID
  PrintTransactionList_sell({Key key,@required this.suid,@required this.myid}):super(key: key);
  @override
  _PrintTransactionState createState() => _PrintTransactionState(suids: suid,myids: myid);
}

class _PrintTransactionState extends State<PrintTransactionList_sell> {
  final suids;
  final myids;
  _PrintTransactionState({Key key,@required this.suids,@required this.myids});
  var format = 'yyyy-MM-dd'; // 날짜 형식

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매/대여내역',style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('User').doc(suids).snapshots(),
        builder: (context,snapshot) {

          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Post').snapshots(),
              builder: (context, snapshotd) {
                ctx = context;
                if (!snapshotd.hasData) {
                  return CircularProgressIndicator();
                }
                final docs = snapshotd.data.docs;
                List<DocumentSnapshot> dlist = List<DocumentSnapshot>();
                for (var ds in docs) {
                  if ((ds.data()['SellerUID'] == suids)) {
                    dlist.add(ds);
                  }
                }

                return ListView(
                  children: dlist.map((doc) => _buildBody(doc)).toList(),
                );
              }
          );
        }),
    );
  }

  Widget _buildBody(DocumentSnapshot doc){
    var currentUser = FirebaseAuth.instance.currentUser.uid;

    Future<Widget> _getImage(BuildContext context,String imageName) async{
      Image image;
      image=Image.network(imageName.toString(),
        fit:BoxFit.scaleDown,);
      return image;
    }

    return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FutureBuilder(
                    future: _getImage(ctx, doc['ImgPath']),
                    builder:(context,snapshot){
                      if(snapshot.connectionState==ConnectionState.done){
                        return Container(
                          width: 100,
                          height: 100,
                          child: snapshot.data,
                        );
                      }
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return Container(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Container();
                    }
                  ),
                ],
              ), // 사진
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PrintPage(DocumentID: doc['PostID'],selleruid: doc['SellerUID'])));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(doc['Title'].length>7
                          ?doc['Title'].substring(0,7)
                          :doc['Title'],
                          style: TextStyle(fontSize:20,fontFamily: mySetting.font),),
                        Text(doc['Title'].length>7?'...':'',
                        style: TextStyle(fontFamily: mySetting.font),)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(doc['Place'].toString()+' , '), // 자주가는 장소로 해놨음, 변경 필요
                        Text(DateFormat(format).format(doc['WriteDate'].toDate().add(new Duration(hours:9))),style: TextStyle(fontFamily: mySetting.font),), //날짜

                      ],
                    ),  //장소
                  ],
                ),
              ),

                  doc['SellerUID']!=myids?Column():
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:<Widget>[
                      (doc['TradeType']==1?(  //대여인가?
                          doc['Process']==1? // 거래 중이면?
                          doc['BuyerCheck']==true?
                          RaisedButton(
                            child: Text('반납 확인',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                            onPressed:(){
                              showDialog(context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      shape:RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0)),
                                      title: Column(
                                        children: <Widget>[
                                          Text('반납 확인',style: TextStyle(fontFamily: mySetting.font)),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('반납을 확인하시겠습니까?',style: TextStyle(fontFamily: mySetting.font)),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('확인',style: TextStyle(fontFamily: mySetting.font)),
                                          onPressed: (){
                                            FirebaseFirestore.instance.collection('Post').doc(doc.id).update({'SellerCheck':true,'Process':2,'TradeEndDate':Timestamp.now()});
                                            FirebaseFirestore.instance.collection('User').doc(currentUser).update({'TradeCount':FieldValue.increment(1)});
                                            FirebaseFirestore.instance.collection('User').doc(doc['Buyer']).update({'TradeCount':FieldValue.increment(1)});
                                            Navigator.of(context).pop();
                                            Toast.show('반납완료',context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('재등록',style: TextStyle(fontFamily: mySetting.font)),
                                          onPressed:(){
                                            FirebaseFirestore.instance.collection('Post').doc(doc.id).update({'SellerCheck':true,'Process':2});
                                            FirebaseFirestore.instance.collection('User').doc(currentUser).update({'TradeCount':FieldValue.increment(1)});
                                            FirebaseFirestore.instance.collection('User').doc(doc['Buyer']).update({'TradeCount':FieldValue.increment(1)});
                                            var newPostRef = FirebaseFirestore.instance.collection('Post').doc();
                                            newPostRef.set({'AuctionPrice':doc['AuctionPrice'],'BidUnit':doc['BidUnit'],'Buyer':"",'BuyerCheck':false,'CategoryOne':doc['CategoryOne'],'CategoryTwo':doc['CategoryTwo'],'CategoryThree':doc['CategoryThree'],'Contents':doc['Contents'],'EndDate':Timestamp.now(),'ImgPath':doc['ImgPath'],'Place':doc['Place'],'PostID':newPostRef.id, 'Price':doc['Price'],'Process':0,'Reviewed':false,'Seller':doc['Seller'],'SellerUID':doc['SellerUID'],'SellerCheck':false,'StartDate':Timestamp.now(),'Title':doc['Title'],'TradeEndDate':Timestamp.now(),'TradeType':doc['TradeType'],'WriteDate':Timestamp.now()});
                                            Navigator.of(context).pop();
                                            Toast.show('재등록 완료', context);
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
                                  });

                            }, // 재등록 함수 작성할 것
                          ):
                              RaisedButton(
                                child: Text('반납 완료 대기중',style: TextStyle(fontFamily: mySetting.font)),onPressed: null,
                              )
                              :
                          (doc['Process']==2?    // 대여 -> 거래완료이면?
                          RaisedButton(
                              child: Text('거래완료',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                              onPressed: null):
                          RaisedButton(
                              child: Text('거래 대기중',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),  //대여 -> 거래전
                              onPressed: null)
                          )

                      )
                          : // 판매/경매
                      (doc['Process']==0?  //거래전
                      RaisedButton(
                          child: Text('거래 대기중',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                          onPressed: null):
                      (doc['Process']==1?    //거래중
                      doc['BuyerCheck']==true?
                      RaisedButton(
                        child: Text('거래 완료',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                        onPressed: (){
                          showDialog(context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  shape:RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  title: Column(
                                    children: <Widget>[
                                      Text('거래완료',style: TextStyle(fontFamily: mySetting.font),),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('거래를 완료하시겠습니까?',style: TextStyle(fontFamily: mySetting.font)),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('확인',style: TextStyle(fontFamily: mySetting.font)),
                                      onPressed: (){
                                        FirebaseFirestore.instance.collection('Post').doc(doc.id).update({'SellerCheck':true,'Process':2,'TradeEndDate':Timestamp.now()});
                                        FirebaseFirestore.instance.collection('User').doc(currentUser).update({'TradeCount':FieldValue.increment(1)});
                                        FirebaseFirestore.instance.collection('User').doc(doc['Buyer']).update({'TradeCount':FieldValue.increment(1)});
                                        Navigator.of(context).pop();
                                        Toast.show('거래완료',context);
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
                              });
                        },
                      ):
                          RaisedButton(
                            child: Text('거래 완료 대기중',style: TextStyle(fontFamily: mySetting.font)),onPressed: null,
                          )
                          :
                      RaisedButton(
                          child: Text('거래 완료',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                          onPressed: null))
                      )
                      ) //대여? 판매경매?
                    ]
                    ,
                  )
            ],
          ),
          Divider(color: Colors.grey,), //구분선
        ]
    );
  }
}
