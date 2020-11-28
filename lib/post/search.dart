import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';
import 'package:yu_market/post/ItemSearchResult.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yu_market/mypage/setting.dart';


class SearchPage extends StatefulWidget  {
  SearchPageState createState()=>SearchPageState();
}
class SearchPageState extends State<SearchPage>{
  String title1 = '';
  String text1 = '';
  String text2 = '';
  int categoryOne = 0;
  int categoryTwo = 1;
  String categoryThree = '학과';

  BuildContext _context;
  bool checkBoxValue = false;
  int _value = 1;
  int value1=0;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('검색',style: TextStyle(fontFamily: mySetting.font),),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ItemSearchResult(text1, _value, categoryOne, categoryTwo))
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20),

          child: Column(
            children: <Widget>[
              Container(
                width: 500,
                child: Text('검색어', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,fontFamily: mySetting.font), textAlign: TextAlign.left,),

              ),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DropdownButton(value: _value,
                        items: [
                          DropdownMenuItem(
                            child: Text("제목",style: TextStyle(fontFamily: mySetting.font),),
                            value: 1,
                          ),
                          DropdownMenuItem(
                            child: Text("내용",style: TextStyle(fontFamily: mySetting.font),),
                            value: 2,
                          ),
                          DropdownMenuItem(
                              child: Text("제목+내용",style: TextStyle(fontFamily: mySetting.font),),
                              value: 0
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                          });
                        }),
                    //print(value);

                    Container(
                      width: 250,
                      child: TextField(
                        maxLines: 1,
                        onChanged: (String text) {
                          text1 = text;
                        },
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                        //obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '',
                        ),
                      ),
                    ),
                  ]
              ),

              Padding(padding: EdgeInsets.all(5)),
              Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text('속성', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,fontFamily: mySetting.font), textAlign: TextAlign.left,),

                    ),
                  ]),
              Padding(padding: EdgeInsets.all(10)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: <Widget>[

                    DropdownButton(value: categoryOne,
                        items: [
                          DropdownMenuItem(
                            child: Text("전체",style: TextStyle(fontFamily: mySetting.font),),
                            value: 3,
                          ),
                          DropdownMenuItem(
                            child: Text("판매",style: TextStyle(fontFamily: mySetting.font),),
                            value: 0,
                          ),
                          DropdownMenuItem(
                              child: Text("대여",style: TextStyle(fontFamily: mySetting.font),),
                              value: 1
                          ),
                          DropdownMenuItem(
                              child: Text("경매",style: TextStyle(fontFamily: mySetting.font),),
                              value: 2
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            categoryOne = value;
                          });
                        }),
                    //print(value);
                  ]),
              Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text('카테고리', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,fontFamily: mySetting.font), textAlign: TextAlign.left,),

                    ),
                  ]),
              Padding(padding: EdgeInsets.all(10)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: <Widget>[

                    DropdownButton(value: categoryTwo,
                        items: [
                          DropdownMenuItem(
                            child: Text("의류",style: TextStyle(fontFamily: mySetting.font),),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text("뷰티",style: TextStyle(fontFamily: mySetting.font),),
                            value: 1,
                          ),
                          DropdownMenuItem(
                              child: Text("도서",style: TextStyle(fontFamily: mySetting.font),),
                              value: 2
                          ),
                          DropdownMenuItem(
                              child: Text("기타",style: TextStyle(fontFamily: mySetting.font),),
                              value: 3

                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            categoryTwo = value;
                          });
                        }),
                    //print(value);
                  ]),
              Padding(padding: EdgeInsets.all(10)),

            ],
          ),
        ));
  }


}