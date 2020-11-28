/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 자주 묻는 질문을 확인 가능한 페이지
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/sangs/FAQ_searchPage.dart';
import 'package:yu_market/mypage/setting.dart';
import 'FaqSearchInfo.dart';

class FAQP extends StatefulWidget {
  @override
  _FAQPState createState() => _FAQPState();
}

class _FAQPState extends State<FAQP> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            child: Row(
              children: [
                Text('자주묻는 질문',style: TextStyle(fontFamily: mySetting.font),),
                SizedBox(
                  width: 150,
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.black,
                  iconSize: 40.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FaqSearch()),
                    );
                  },
                )
              ],
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: '구매',
              ),
              Tab(
                text: '판매',
              ),
              Tab(
                text: '서비스',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('FAQ')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                      }
                      final documents = snapshot.data.docs;
                      return Expanded(
                        child: ListView(
                          children: documents
                              .map((doc) => _buildListOne(doc))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('FAQ')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                      }
                      final documents = snapshot.data.docs;
                      return Expanded(
                        child: ListView(
                          children: documents
                              .map((doc) => _buildListTwo(doc))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('FAQ')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                      }
                      final documents = snapshot.data.docs;
                      return Expanded(
                        child: ListView(
                          children: documents
                              .map((doc) => _buildListThree(doc))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListOne(DocumentSnapshot ds) {
    if(ds['Type'] == 0){
      return ListTile(
        leading: Icon(Icons.add_shopping_cart),
        title: Text(ds['Title'],style: TextStyle(fontFamily: mySetting.font),),
        trailing: Icon(Icons.navigate_next),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FaqInfo(doc: ds)),
          );
        },
      );
    }
    else{
      return SizedBox(height: 1.0,);
    }
  }

  Widget _buildListTwo(DocumentSnapshot ds) {
    if(ds['Type'] == 1){
      return ListTile(
        leading: Icon(Icons.add_shopping_cart),
        title: Text(ds['Title'],style: TextStyle(fontFamily: mySetting.font),),
        trailing: Icon(Icons.navigate_next),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FaqInfo(doc: ds)),
          );
        },
      );
    }
    else{
      return SizedBox(height: 1.0,);
    }
  }

  Widget _buildListThree(DocumentSnapshot ds) {
    if(ds['Type'] == 2){
      return ListTile(
        leading: Icon(Icons.add_shopping_cart),
        title: Text(ds['Title'],style: TextStyle(fontFamily: mySetting.font),),
        trailing: Icon(Icons.navigate_next),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FaqInfo(doc: ds)),
          );
        },
      );
    }
    else{
      return SizedBox(height: 1.0,);
    }
  }
}
