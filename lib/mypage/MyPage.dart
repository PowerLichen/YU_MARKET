/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.21
* 기능 설명 : 마이페이지를 출력하는 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/main.dart';
import 'package:yu_market/screen/account_settings_screen.dart';
import 'package:yu_market/mypage/PrintTransactionList_sell.dart';
import 'package:yu_market/mypage/PrintTransactionList_buy.dart';
import 'package:yu_market/mypage/ReceivedReview.dart';
import 'package:yu_market/mypage/ServiceCenter.dart';
import 'package:yu_market/mypage/AppSetting.dart';
import 'package:yu_market/mypage/setting.dart';
import 'package:yu_market/sangs/WishList.dart';
import 'package:yu_market/sangs/BanList.dart';
import 'package:yu_market/screen/review_screen.dart';
// 마이페이지 dart class
class MyPage extends StatefulWidget{
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {    //마이페이지 UI
  String curruentUser = FirebaseAuth.instance.currentUser.uid; // 로그인한 유저의 uid
  BuildContext ctx;
  //Logout 기능
  Future<void> LogOut() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    var user=auth.signOut();
  }
  @override
  Widget build(BuildContext context) {  //build
    ctx = context;
    return Scaffold(    //Scaffold
      appBar: AppBar(   //AppBar 구성(마이페이지)
        title: Text(
          '마이페이지',
          style: TextStyle(color: Colors.white,fontFamily: mySetting.font),
        ),
      ),
      //MyPage 출력을 위해 DB에서 내 정보를 받아옴
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('User').doc(curruentUser).snapshots(),
        builder: (context, snapshot) {
          //data가 없으면 CircularProgressIndicator() 실행
          if(!snapshot.hasData)
            return CircularProgressIndicator();
          //doc = 해당 collection document의 snapshot
          final doc=snapshot.data.data();
          return Column(        // Column으로 구성되어 있으며, _MPTop(), _MPMiddle(), _MPBottom()으로 각각 이름부분, 판매~찜목록 부분, 차단~로그아웃 부분 구성
            children: <Widget>[
              _MPTop(doc), // 이름, 학번, 평점 부분
              _MPMiddle(doc), // 판매 대여 내역 등
              _MPBottom(doc), // 환경 설정 등
            ],
          );
        }
      ),
    );
  }
  Widget _MPTop(doc){    // 이름 부분
    return Row( //Row
      mainAxisAlignment: MainAxisAlignment.start,  // 정렬 방식
      children:<Widget>[Column(   //Column
        children: <Widget>[
          InkWell( // 클릭시 동작을 위한 InkWell
            //동작 없음
            onTap:(){null;},
            // Circle Avator Icon
            child: Icon(
              Icons.account_circle,
              size:80,
            ),
          ),
        ],
      ),
        Column(
          children: <Widget>[
            SizedBox(width: 30,),
          ],
        ),
        Column(   //이름(닉네임), 아이디(학번) 출력
          children: <Widget>[
            Text(doc['UserName'],style: TextStyle(fontSize: 20,fontFamily: mySetting.font),), //학번 이름 호출 받은걸로 출력할 것
            Text(doc['StudentNo'].toString(),style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),

          ],

        ),
        Column(
          children: <Widget>[
            SizedBox(width: 30,),
          ],
        ),
        Column(
          children: <Widget>[
            Text('평점',style: TextStyle(fontFamily: mySetting.font,fontSize: 20)),
            doc['ReviewCount']==0?Text('0',style: TextStyle(fontFamily: mySetting.font,fontSize: 20),):
                Text((doc['Score']/doc['ReviewCount']).toStringAsFixed(2),style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ],
        ),
        Column(
          children: <Widget>[
            SizedBox(width:30),
          ],
        ),
        Column(
          children: <Widget>[
            Text('거래횟수',style: TextStyle(fontFamily: mySetting.font,fontSize:20)),
            Text(doc['TradeCount'].toString(),style: TextStyle(fontFamily: mySetting.font,fontSize: 20),),
          ],
        ),
      ],
    );

  }
  Widget _MPMiddle(doc){   // 판매~찜목록 까지를 나타내는 부분
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textBaseline: TextBaseline.ideographic,
      children: <Widget>[
        Divider(
          color: Colors.black,
        ),
        Padding(    //Padding으로 여백 줬음
          padding: const EdgeInsets.only(left: 40, top: 5, bottom: 5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx,
                  MaterialPageRoute(builder: (ctx)=>PrintTransactionList_sell(suid: doc['UID'],myid: doc['UID'])));
            },
            child:
            Text('판매/대여내역',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx,
                  MaterialPageRoute(builder: (ctx)=>PrintTransactionList_Buy(buid: doc['UID'])));
            },
            child:
            Text('구매/대여내역',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx, MaterialPageRoute(builder: (ctx)=>ReviewPage()));
            },
            child:
            Text('작성한 후기 보기',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx,
                  MaterialPageRoute(builder: (ctx)=>ReceivedReview(ruid: doc['UID'],myid: doc['UID'],)));
            },
            child:
            Text('받은 후기 보기',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx,
              MaterialPageRoute(builder: (ctx)=>WishList()));
            },  //찜목록 보기 기능을 이부분에 이동시켜주면 될 듯
            child:
            Text('찜목록 보기',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Divider(
          color: Colors.black,
        )
      ],
    );
  }
  Widget _MPBottom(doc){   // 하단부 출력 (사용자 차단 설정~ 로그아웃 까지)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textBaseline: TextBaseline.ideographic,
      children: <Widget>[
        Padding(
          padding:const EdgeInsets.only(left : 40, top : 5, bottom : 5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx,MaterialPageRoute(builder:(ctx)=>AccountSetting() ));

            },
            child: Text('계정정보설정',style: TextStyle(fontSize: 20,fontFamily: mySetting.font)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx,MaterialPageRoute(builder: (ctx)=>BanList()));
            },
            child:
            Text('사용자 차단 설정',style:TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx, MaterialPageRoute(builder: (ctx)=>AppSetting())).then((value){setState(() {});});
            },
            child:
            Text('앱 환경 설정',style:TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              Navigator.push(ctx, MaterialPageRoute(builder: (ctx)=>Notice()));
            },    // 고객센터 부분은 여기 추가 할 것
            child:
            Text('고객센터',style:TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left : 40, top:5,bottom:5),
          child: InkWell(
            onTap:(){
              LogOut();
              Navigator.of(ctx).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Splash()),(Route<dynamic> route)=>false);
              },    // 로그아웃 기능은 여기에!
            child:
            Text('로그아웃',style:TextStyle(fontSize: 20,fontFamily: mySetting.font),),
          ),
        ),
      ],
    );
  }

}
