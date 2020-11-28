/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 사용자가 추가한 찜목록에 대해 관리를 할 수 있는 페이지
* */

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_market/mypage/setting.dart';

String uid = FirebaseAuth.instance.currentUser.uid;

class WishList extends StatefulWidget {
  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.star),
            SizedBox(
              width: 10,
            ),
            Text('찜 목록 보기',style: TextStyle(fontFamily: mySetting.font),),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(uid)
                  .collection('Wish')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('등록하신 찜목록이 없습니다..',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.docs;
                return Expanded(
                  child: ListView(
                    children:
                        documents.map((doc) => _buildWishWidget(doc)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishWidget(DocumentSnapshot doc) {
    Future<Widget> _getImage(BuildContext context, String imageName) async {
      Image image;
      image = Image.network(imageName, fit: BoxFit.scaleDown);
      return image;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Post').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final datas = snapshot.data.docs;

        for (var ds in datas) {
          if (ds.id == doc['PostID']) {
            return ListTile(
              onTap: () {
                // 물품 페이지로 이동
              },
              title: Column(
                children: [
                  Row(
                    children: [
                      FutureBuilder(
                        future: _getImage(context, ds['ImgPath']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                              width: 90,
                              height: 100,
                              child: snapshot.data,
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: 70,
                              height: 100,
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Container(
                            width: 70,
                            height: 100,
                            color: Colors.red,
                          );
                        },
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: [
                              Text(
                                ds['Title'].length > 7
                                    ? ds['Title'].substring(0, 7)
                                    : ds['Title'],
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,fontFamily: mySetting.font
                                ),
                              ),
                              Text(
                                ds['Title'].length > 7 ? '...' : '',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,fontFamily: mySetting.font
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            children: [
                              Text(
                                ds['Place'],
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey,fontFamily: mySetting.font
                                ),
                              ),
                              Text(
                                '  ',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey,fontFamily: mySetting.font
                                ),
                              ),
                              Text(
                                ds['WriteDate']
                                    .toDate()
                                    .toString()
                                    .substring(0, 10),
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey,fontFamily: mySetting.font
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                ds['Price'].toString(),
                                style: TextStyle(
                                  fontSize: 15,fontFamily: mySetting.font
                                ),
                              ),
                              Text(
                                '원',
                                style: TextStyle(
                                  fontSize: 15,fontFamily: mySetting.font
                                ),
                              ),
                              FlatButton(
                                child: Text(
                                  ds['Process'] == 1 ? '거래 가능' : '거래 완료',
                                  style: TextStyle(fontFamily: mySetting.font,
                                    color: ds['Process'] == 1
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 500.0,
                    height: 1.0,
                    color: Colors.blue,
                  )
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.blue,
                  size: 35,
                ),
                onPressed: () => _deleteWish(doc),
              ),
            );
          }
        }
        return ListTile();
      },
    );
  }

  void _deleteWish(DocumentSnapshot doc) {
    setState(() {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('정말 찜 목록에서 삭제하시겠습니까?',style: TextStyle(fontFamily: mySetting.font),),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                  child: Text('예',style: TextStyle(fontFamily: mySetting.font),),
                  onPressed: () {
                    Firestore.instance
                        .collection('User')
                        .document(uid)
                        .collection('Wish')
                        .document(doc.documentID)
                        .delete();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('아니요',style: TextStyle(fontFamily: mySetting.font),),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    });
  }
}
