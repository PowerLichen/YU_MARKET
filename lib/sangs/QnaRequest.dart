/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 문의하기에 대해 답변을 확인하기 위해 사용하는 페이지
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/mypage/setting.dart';

class QNARequest extends StatelessWidget {
  DocumentSnapshot doc;

  QNARequest({@required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(doc['Title'],style: TextStyle(fontFamily: mySetting.font),),
        ),
        body: ListTile(
          title: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '문의 분류 : ',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,fontFamily: mySetting.font
                      ),
                    ),
                    Text(
                      doc['Type'],
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,fontFamily: mySetting.font
                      ),
                    ),
                  ],
                ),
                Text(
                  '문의 내용',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,fontFamily: mySetting.font
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 10.0,
                  child: Container(
                    alignment: Alignment.center,
                    width: 380,
                    height: 200,
                    child: Text(
                      doc['Contents'],
                      style: TextStyle(
                        fontSize: 18,fontFamily: mySetting.font
                      ),
                    ),
                  ),
                ),
                Text(
                  '답변',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,fontFamily: mySetting.font
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 10.0,
                  child: Container(
                    alignment: Alignment.center,
                    width: 380,
                    height: 250,
                    child: Text(
                      doc['AnswerCheck']
                          ? doc['Request']
                          : '아직 답변이 등록되지 않았습니다.',
                      style: TextStyle(
                        fontSize: 15,fontFamily: mySetting.font
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
