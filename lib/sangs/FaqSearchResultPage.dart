/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 자주 묻는 질문에 대한 검색 결과 리스트 출력 페이지
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/sangs/FaqSearchInfo.dart';
import 'package:yu_market/mypage/setting.dart';

class FaqSearchResult extends StatefulWidget {
  final String search;
  const FaqSearchResult(this.search);
  @override
  _FaqSearchResultState createState() => _FaqSearchResultState();
}

class _FaqSearchResultState extends State<FaqSearchResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.attach_money),
            SizedBox(
              width: 10,
            ),
            Text('검색 결과',style: TextStyle(fontFamily: mySetting.font),),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('FAQ').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.docs;
                return Expanded(
                  child: ListView(
                    children:
                    documents.map((doc) => _buildListWidget(doc)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget(DocumentSnapshot ds) {
    if (ds['Title'].toString().contains(widget.search)) {
      return ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FaqInfo(doc: ds)),
          );
        },
        title: Text(ds['Title'],style: TextStyle(fontFamily: mySetting.font),),
      );
    } else {
      return ListTile();
    }
  }
}
