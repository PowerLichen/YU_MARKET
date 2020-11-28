/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 자주 묻는 질문 페이지에서 자신이 찾고자 하는 자주 묻는 질문에 대한 검색을 하기 위한 양식 입력 페이지
* */

import 'package:flutter/material.dart';
import 'package:yu_market/sangs/FaqSearchResultPage.dart';
import 'package:yu_market/mypage/setting.dart';

class FaqSearch extends StatefulWidget {
  @override
  _FaqSearchState createState() => _FaqSearchState();
}

class _FaqSearchState extends State<FaqSearch> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색',style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: Container(
        child: Column(
          children: [
            Text(
              '키워드 입력',
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,fontFamily: mySetting.font
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '검색어를 입력해 주세요',
                    ),
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '키를 입력하세요';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FaqSearchResult(_searchController.text)),
                  );
                }
              },
              child: Text('입력',style: TextStyle(fontFamily: mySetting.font),),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
