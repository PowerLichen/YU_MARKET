/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.21
* 기능 설명 : 고객센터
* */

import 'package:flutter/material.dart';
import 'package:yu_market/sangs/FAQ_page.dart';
import 'package:yu_market/sangs/QnA.dart';
import 'package:yu_market/mypage/Notify.dart';
import 'package:yu_market/mypage/setting.dart';

class Notice extends StatefulWidget {
  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('고객센터',style: TextStyle(fontFamily: mySetting.font),),
        actions: [
          RaisedButton(
              color: Colors.blueAccent,
              child: Text('자주묻는',style: TextStyle(fontFamily: mySetting.font),),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQP()),
                );
              }),
          RaisedButton(
              color: Colors.blueGrey,
              child: Text('1:1문의',style: TextStyle(fontFamily: mySetting.font),),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QNA()),
                );
              }),
        ],
      ),
      body: Notify(),
    );
  }
}
