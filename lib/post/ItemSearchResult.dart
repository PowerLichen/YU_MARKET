/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.16
* 변경일 : 2020.11.21
* 기능 설명 : 물품을 검색하기 위해 입력한 내용들을 바탕으로 검색 결과를 출력해주는 기능
* */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_market/post/print.dart';
import 'package:yu_market/mypage/setting.dart';

String uid = FirebaseAuth.instance.currentUser.uid;

class ItemSearchResult extends StatefulWidget {
  final String search; // 검색 내용
  final int category_one; //검색 범위 (0 = 제+내, 1 = 제, 2 = 내)
  final int category_two; //판매 유형 (0 = 판, 1 = 대, 2 = 경, 3 = 전)
  final int category_three; //물품 유형 (0 = 의류, 1 = 뷰티, 2 = 도서, 3 = 기타)
  const ItemSearchResult(
      this.search, this.category_one, this.category_two, this.category_three);
  @override
  _ItemSearchResultState createState() => _ItemSearchResultState();
}

class _ItemSearchResultState extends State<ItemSearchResult> {
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
      body: widget.category_two != 3
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Post')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.docs;
                return Expanded(
                  child: ListView(
                    children: documents
                        .map((doc) => _buildListWidget(doc))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Post')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.docs;
                return Expanded(
                  child: ListView(
                    children: documents
                        .map((doc) => _buildListWidgetall(doc))
                        .toList(),
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
    Future<Widget> _getImage(BuildContext context, String imageName) async {
      Image image;
        image = Image.network(
          imageName,
          fit: BoxFit.scaleDown,
        );
      return image;
    }

    if (widget.category_one == 0) {
      // 검색 범위
      if (widget.category_two == ds['TradeType']) {
        // 판매 유형
        if (widget.category_three == ds['CategoryTwo']) {
          // 물품 유형
          if (ds['Title'].toString().contains(widget.search) ||
              ds['Contents'].toString().contains(widget.search)) {

            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrintPage(DocumentID : ds.id)),
                );
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
                                  fontWeight: FontWeight.bold
                                    ,fontFamily: mySetting.font
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
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(uid)
                      .collection('Wish')
                      .add({
                    'PostID': ds.id,
                  });
                },
              ),
            );
          } else {
            return ListTile();
          }
        }
      }
    }

    if (widget.category_one == 1) {
      // 검색 범위
      if (widget.category_two == ds['TradeType']) {
        // 판매 유형
        if (widget.category_three == ds['CategoryTwo']) {
          // 물품 유형
          if (ds['Title'].toString().contains(widget.search)) {
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrintPage(DocumentID : ds.id)),
                );
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
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(uid)
                      .collection('Wish')
                      .add({
                    'PostID': ds.id,
                  });
                },
              ),
            );
          } else {
            return ListTile();
          }
        }
      }
    }
    if (widget.category_one == 2) {
      // 검색 범위
      if (widget.category_two == ds['TradeType']) {
        // 판매 유형
        if (widget.category_three == ds['CategoryTwo']) {
          // 물품 유형
          if (ds['Contents'].toString().contains(widget.search)) {
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrintPage(DocumentID : ds.id)),
                );
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
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(uid)
                      .collection('Wish')
                      .add({
                    'PostID': ds.id,
                  });
                },
              ),
            );
          } else {
            return ListTile();
          }
        }
      }
    }
    return SizedBox(height: 1.0,);
  }

  Widget _buildListWidgetall(DocumentSnapshot ds) {
    Future<Widget> _getImage(BuildContext context, String imageName) async {
      Image image;
      image = Image.network(
        imageName,
        fit: BoxFit.scaleDown,
      );
      return image;
    }



    if (widget.category_one == 0) {
      // 검색 범위
      if (widget.category_three == ds['CategoryTwo']) {
        // 물품 유형
        if (ds['Title'].toString().contains(widget.search) ||
            ds['Contents'].toString().contains(widget.search)) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrintPage(DocumentID : ds.id)),
              );
            },
            title: Column(
              children: [
                Row(
                  children: [
                    FutureBuilder(
                      future: _getImage(context, ds['ImgPath']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
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
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('User')
                    .doc(uid)
                    .collection('Wish')
                    .add({
                  'PostID': ds.id,
                });
              },
            ),
          );
        } else {
          return ListTile();
        }
      }
    }

    if (widget.category_one == 1) {
      // 검색 범위
      // 판매 유형
      if (widget.category_three == ds['CategoryTwo']) {
        // 물품 유형
        if (ds['Title'].toString().contains(widget.search)) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrintPage(DocumentID : ds.id)),
              );
            },
            title: Column(
              children: [
                Row(
                  children: [
                    FutureBuilder(
                      future: _getImage(context, ds['ImgPath']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
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
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('User')
                    .doc(uid)
                    .collection('Wish')
                    .add({
                  'PostID': ds.id,
                });
              },
            ),
          );
        } else {
          return ListTile();
        }
      }
    }

    if (widget.category_one == 2) {
      // 검색 범위
      // 판매 유형
      if (widget.category_three == ds['CategoryTwo']) {
        // 물품 유형
        if (ds['Contents'].toString().contains(widget.search)) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrintPage(DocumentID : ds.id)),
              );
            },
            title: Column(
              children: [
                Row(
                  children: [
                    FutureBuilder(
                      future: _getImage(context, ds['ImgPath']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
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
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('User')
                    .doc(uid)
                    .collection('Wish')
                    .add({
                  'PostID': ds.id,
                });
              },
            ),
          );
        } else {
          return ListTile();
        }
      }
    }
    return SizedBox(height: 1.0,);
  }
}

