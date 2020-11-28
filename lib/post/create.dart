//하단 탭바(홈, 내 주변, 글쓰기, 채팅, 회원정보) 중 글쓰기를 클릭시 출력되는 화면


import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yu_market/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:yu_market/mypage/setting.dart';
import 'package:yu_market/data/place_data.dart';


String uid = FirebaseAuth.instance.currentUser.uid; // 현재 접속 중인 User의 uid 불러오기

class CreatePage extends StatefulWidget {
  CreatePageState createState() => CreatePageState();
}

class CreatePageState extends State<CreatePage> {
  BuildContext _context;
  String title = '';
  int price = 0; // 가격
  int Auctionprice = 0; //입찰가
  int BidUnit = 1000; //경매단위
  String text = '';
  bool checkBoxValue1 = false; // 판매 체크박스
  bool checkBoxValue2 = false; // 대여 체크박스
  bool checkBoxValue3 = false; // 경매 체크박스
  bool checkBoxValue4 = false; // 무료 나눔 or 대여 체크박스
  int checkBoxValue = 0; //TradeType. CategoryOne과 동일
  int categoryOne = 0; // 판매
  int categoryTwo = 0; // 카테고리
  String categoryThree = '학과';
  String Place = '사범대학';  //거래장소.
  String Tradetext = '무료나눔     ';
  bool isTouch1 = false; //true이면 무료 나눔 or 대여 텍스트필드 출력
  bool isTouch2 = false; //true이면 입찰가 입찰단위 즉시구매가 텍스트필드 출력
  var newPost = FirebaseFirestore.instance.collection('Post').doc();
  var seller;
  PlaceData placeData = new PlaceData();


  //사진 업로드 안 하면 기본사진으로 업로도 되도록
  String imageUrl='https://firebasestorage.googleapis.com/v0/b/yumarket-db.appspot.com/o/images%2F1605622465982?alt=media&token=f8bf49d4-2737-4dfa-b3dc-b79407df5009';

  void initState(){
    super.initState();
    loadPost();
  }

  Future loadPost() async {
    seller= await FirebaseFirestore.instance.collection('User').doc(uid).get();
  }



  Future uploadFile() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    File imageFile = File(pickedFile.path);

    if (imageFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference =
      FirebaseStorage.instance.ref().child("images/$fileName");
      UploadTask uploadTask = reference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        try {
          imageUrl = await reference.getDownloadURL();
          print(imageUrl);
        } on FirebaseException catch (err) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("This file is not an image",style: TextStyle(fontFamily: mySetting.font),),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    _context = context;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('글쓰기',style: TextStyle(fontFamily: mySetting.font),),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                newPost.set({
                  'AuctionPrice': Auctionprice,
                  'BidUnit': BidUnit,
                  'Buyer': '',
                  'BuyerCheck': false,
                  'CategoryOne': categoryOne,
                  'CategoryTwo': categoryTwo,
                  'CategoryThree': categoryThree,
                  'Contents': this.text,
                  'EndDate': DateTime.now(),
                  'ImgPath': imageUrl,
                  'Place': Place,
                  'PostID': newPost.id,
                  'Price': price,
                  'Process': 0,
                  'Reviewed': false,
                  'Seller': seller['UserName'],
                  'SellerCheck': false,
                  'SellerUID':uid,
                  'StartDate': DateTime.now(),
                  'Title': this.title,
                  'TradeEndDate': DateTime.now().add(Duration(days: 7)),
                  'TradeType': checkBoxValue,
                  'WriteDate': DateTime.now(),
                });
                Navigator.of(_context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MyApp()),
                        (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              TextField(
                maxLines: 2,
                onChanged: (String title) {
                  this.title = title;
                },
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                //obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '제목',
                ),
              ),
              Row(children: <Widget>[
                Checkbox(
                    value: checkBoxValue1,
                    onChanged: (bool value) {
                      //print(value);
                      setState(() { //판매 체크박스에 체킹이 되면?
                        checkBoxValue1 = value;
                        checkBoxValue2 = false; //대여 체크박스 체킹해제
                        checkBoxValue3 = false; //경매 체크박스 체킹해제
                        checkBoxValue = 0; //TradeType =0
                        categoryOne = 0; //Post에서 CategoryOne=0으로 설정
                        if (checkBoxValue1 == value) {
                          Tradetext = '무료나눔     ';
                        }
                        ;
                        isTouch2 = false;
                        isTouch1 = true;
                      });
                    }),
                Text(
                  "판매       ",
                  style: TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                ),
                Checkbox(
                    value: checkBoxValue2,
                    onChanged: (bool value) {
                      print(value);
                      setState(() {
                        checkBoxValue2 = value;
                        checkBoxValue1 = false;
                        checkBoxValue3 = false;
                        checkBoxValue = 1;
                        categoryOne = 1;
                        if (checkBoxValue2 == value) {
                          Tradetext = '무료대여     ';
                        }
                        ;
                        isTouch2 = false;
                        isTouch1 = true;
                      });
                    }),
                Text(
                  "대여       ",
                  style: TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                ),
                Checkbox(
                    value: checkBoxValue3,
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        checkBoxValue3 = value;
                        checkBoxValue1 = false;
                        checkBoxValue2 = false;
                        checkBoxValue = 2;
                        categoryOne = 2;
                        // Navigator.of(_context).pushAndRemoveUntil(
                        //     MaterialPageRoute(builder: (context) => WritePage()), (
                        //     Route<dynamic> route) => false);
                        isTouch2 = true;
                        isTouch1 = false;
                      });
                    }),
                Text(
                  "경매",
                  style: TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                ),
              ]),

              isTouch1 == true  //만약 판매 대여 둘 중 한 곳을 선택했다?
                  ? Expanded(
                child: Container(
                  height: 100,
                  child: Row(children: <Widget>[ // 무료나눔 or 대여 체크박스 출력
                    Checkbox(
                        value: checkBoxValue4,
                        onChanged: (value) {
                          print(value);

                          setState(() {
                            checkBoxValue4 = value;
                          });
                        }),
                    Text(
                      Tradetext, //TradeText는 무료 나눔으로 출력할지, 무료대여로 출력할지
                      style:
                      TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                    ),
                    Container(
                      width: 200,
                      child: TextField(
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        onChanged: (String text) {
                          price = int.parse(text);
                          if (checkBoxValue4 != false) {
                            price = 0;
                          }
                          ;
                        },
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
                        textAlign: TextAlign.right,
                        //obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '가격(원)',
                        ),
                      ),
                    ),
                  ]),
                ),
              )
                  : Text('',style: TextStyle(fontFamily: mySetting.font),),
              isTouch2 == true //경매를 선택했다?
                  ? Expanded(
                child: Container(
                  //margin: EdgeInsets.only(left:0.0, bottom:40.0),
                  width: 400,
                  //height: 10000,
                  child: Column(children: <Widget>[
                    TextField(
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      onChanged: (String text) {
                        Auctionprice = int.parse(text);
                      },
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.right,
                      //obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '입찰가(원)',
                      ),
                    ),
                    TextField(
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      onChanged: (String text) {
                        BidUnit = int.parse(text);
                      },
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.right,
                      //obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '입찰 단위(원)',
                      ),
                    ),
                    Row(children: <Widget>[
                      Checkbox(
                          value: checkBoxValue4,
                          onChanged: (value) {
                            print(value);

                            setState(() {
                              checkBoxValue4 = value;
                            });
                          }),
                      Text(
                        "즉시구매가    ",
                        style:
                        TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          onChanged: (String text) {
                            price = int.parse(text);
                            if (checkBoxValue4 == false) {
                              price = 0;
                            }
                            ;
                          },
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                          textAlign: TextAlign.right,
                          //obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '가격(원)',
                          ),
                        ),
                      ),
                    ]),
                  ]),
                ),
              )
                  : Text('',style: TextStyle(fontFamily: mySetting.font),),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                  Widget>[
                Text(
                  "거래장소 : ",
                  style: TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                ),
                DropdownButton(
                    value: Place,
                    items: placeData.favoritePlace.map(
                          (value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value,style: TextStyle(fontFamily: mySetting.font),),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        Place = value;
                      });
                    }),

                //print(value);
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "카테고리 : ",
                    style: TextStyle(fontSize: 16.0, letterSpacing: 1.0,fontFamily: mySetting.font),
                  ),
                  DropdownButton(
                      value: categoryTwo,
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
                          value: 2,
                        ),
                        DropdownMenuItem(child: Text("기타",style: TextStyle(fontFamily: mySetting.font),), value: 3),
                      ],
                      onChanged: (value) {
                        setState(() {
                          categoryTwo = value;
                        });
                      }),
                ],
              ),
              //Padding(padding: EdgeInsets.all(10)),
              //Padding(padding: EdgeInsets.all(5)),
              TextField(
                maxLines: 4,
                onChanged: (String text) {
                  this.text = text;
                },
                //obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '내용',
                ),
              ),
              RaisedButton(child: Text('사진 업로드', style: TextStyle(fontSize: 24,fontFamily: mySetting.font)),
                onPressed: () {uploadFile();},
              ),
            ],
          ),
        ));
  }
}
