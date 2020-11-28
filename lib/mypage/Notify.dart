/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.21
* 기능 설명 : 공지사항을 출력하는 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/mypage/setting.dart';

//공지사항
class Notify extends StatefulWidget{
  @override
  _NotifyState createState()=>_NotifyState();
}

class _NotifyState extends State<Notify>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance.collection('Notice').snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData)
            return CircularProgressIndicator();
          final docs = snapshot.data.docs;
          return ListView(
            children:docs.map((doc) => _NotifyBody(doc)).toList(),
          );
        });
  }

  Widget _NotifyBody(DocumentSnapshot doc){
        return ListTile(
          leading: Icon(Icons.notification_important_outlined),
          title:Text(doc['Title'],style: TextStyle(fontFamily: mySetting.font)),
          onTap: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>Scaffold(
              appBar: AppBar(
                title: Text('공지사항',style: TextStyle(fontFamily: mySetting.font),),
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '제목',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: mySetting.font,
                        fontSize: 20,
                        color: Colors.black,
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
                        height: 100,
                        child: Text(
                          doc['Title'],
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: mySetting.font
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '내용',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: mySetting.font,
                        fontSize: 20,
                        color: Colors.black,
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
                        height: 100,
                        child: Text(
                          doc['Contents'],
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: mySetting.font
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

            )));
          },
        );
      }
  }
