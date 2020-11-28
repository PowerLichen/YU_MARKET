/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.23
* 기능 설명 : 구매 내역 출력 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:yu_market/mypage/setting.dart';
import 'package:yu_market/screen/review_write_screen.dart';
import 'package:yu_market/post/print.dart';

// UID을 받아옴

class PrintTransactionList_Buy extends StatefulWidget {
  final buid;
  PrintTransactionList_Buy({Key key,@required this.buid}):super(key: key);

  @override
  _PrintTransactionListState_Buy createState() => _PrintTransactionListState_Buy(buids: buid);

}
var ctx;
class _PrintTransactionListState_Buy extends State<PrintTransactionList_Buy>{
  final buids;
  _PrintTransactionListState_Buy({Key key,@required this.buids});
  var format = 'yyyy-MM-dd'; // 날짜 형식
  DateTime nowdate = DateTime.now();  //현재 시간


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('구매/대여내역',style: TextStyle(fontFamily: mySetting.font)),
      ),
      body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Post').snapshots(),
            builder: (context,snapshot){
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final docs=snapshot.data.docs;
              var dlist = List<DocumentSnapshot>();
              for(var ds in docs){
                if(ds.data()['Buyer']==buids){
                  dlist.add(ds);
                }
              }
              return ListView(
                children: dlist.map((doc)=>_buildBody(doc)).toList(),
              );
            },
          ),
      );
  }

  Widget _buildBody(DocumentSnapshot doc){

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
                          future: _getImage(context,doc['ImgPath']),
                          builder: (context,snapshot){
                            if(!snapshot.hasData)
                              return Text('No Img',style: TextStyle(fontFamily: mySetting.font),);
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
                          },
                        ),  // 변경 필요
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
                                  ? doc['Title'].substring(0,7)
                                  : doc['Title'],
                              style: TextStyle(fontFamily: mySetting.font,fontSize: 20),),

                                Text(doc['Title'].length>7?'...':'',
                                    style: TextStyle(fontFamily: mySetting.font)),


                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(doc['Place'].toString()+' , ',style: TextStyle(fontFamily: mySetting.font),), // 자주가는 장소로 해놨음, 변경 필요
                              Text(DateFormat(format).format(doc['WriteDate'].toDate().add(new Duration(hours: 9))),style: TextStyle(fontFamily: mySetting.font),), //날짜
                            ],
                          ),  //장소
                        ],
                      ),
                    ),
                          doc['Buyer']!=buids?null:
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children:<Widget>[
                            (doc['TradeType']==1?(  //대여인가?
                                doc['Process']==1? // 거래 중이면?
                                doc['BuyerCheck']==false?
                                RaisedButton(
                                  child: Text('반납하기',style: TextStyle(fontSize: 20, fontFamily:mySetting.font),),
                                  onPressed:(){
                                      showDialog(context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                          title: Column(
                                            children: <Widget>[
                                              Text('반납하기',style: TextStyle(fontFamily: mySetting.font)),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('반납을 완료 하시겠습니까?',style: TextStyle(fontFamily: mySetting.font))
                                            ],
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('완료',style: TextStyle(fontFamily: mySetting.font)),
                                              onPressed: (){
                                                FirebaseFirestore.instance.collection('Post').doc(doc.id).update({'BuyerCheck':true});
                                                Navigator.of(context).pop();
                                                Toast.show('반납 완료',context);
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
                                      },
                                    );
                                  },
                                ):
                                    RaisedButton(
                                      child: Text('반납확인 대기중',style: TextStyle(fontFamily: mySetting.font)),
                                      onPressed: null,
                                    )
                                    :
                                (doc['Process']==2?    // 대여 -> 거래완료이면?
                                ( nowdate.difference(doc['TradeEndDate'].toDate().add(new Duration(hours: 9))).inDays>7?
                                    RaisedButton(
                                    child: Text('거래완료',style: TextStyle(fontSize: 20,fontFamily:mySetting.font),),
                                    onPressed: null):
                                (doc['Reviewed']==false?
                                RaisedButton(
                                    child: Text('후기작성',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                                    onPressed:(){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>WriteReview(poid:doc['PostID'] ,suid: doc['SellerUID'])));
                                    }): //PostID, SellerID 넘길 것 후기작성 화면으로 이동할 것
                                     RaisedButton(child: Text('후기작성완료',style: TextStyle(fontFamily: mySetting.font)),
                                     onPressed: null,)
                                )):
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
                            doc['BuyerCheck']==false?
                            RaisedButton(
                                child: Text('거래 완료',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                                onPressed:(){
                                  showDialog(context: context,
                                  barrierDismissible: false,
                                  builder:(BuildContext context){
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      title: Column(
                                        children: <Widget>[
                                          Text('거래완료',style: TextStyle(fontFamily: mySetting.font)),
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
                                            FirebaseFirestore.instance.collection('Post').doc(doc.id).update({'BuyerCheck':true});
                                            Navigator.of(context).pop();
                                            Toast.show('거래완료',context);
                                          },
                                        ),
                                        FlatButton(
                                          child:  Text('취소',style:  TextStyle(fontFamily: mySetting.font)),
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  } );
                                }):
                                RaisedButton(child: Text('거래완료 대기중',style: TextStyle(fontFamily: mySetting.font)),onPressed: null,)
                                :(
                            nowdate.difference(doc['TradeEndDate'].toDate()).inDays>7?
                            RaisedButton(
                                child: Text('후기 작성',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                                onPressed: null):
                            (doc['Reviewed']==false?
                            RaisedButton(
                                child: Text('후기 작성',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                                onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context)=>WriteReview(poid:doc['PostID'] ,suid: doc['SellerUID'])));})
                                    :
                                    RaisedButton(
                                      child: Text('후기작성완료',style: TextStyle(fontFamily: mySetting.font)),onPressed: null,
                                    ))
                            )
                            )
                            )
                            ) //대여? 판매경매?
                          ]
                          ,
                        ),
                    // 후기작성 button

                  ],
                ),
                Divider(color: Colors.grey,), //구분선
              ]
          );
  }
}
