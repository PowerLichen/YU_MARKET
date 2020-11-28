/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 경매 물품에 대한 입찰을 진행하는 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yu_market/mypage/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bid extends StatefulWidget {
  final String postid;
  //const Bid(@required this.postid);
  Bid({Key key, @required this.postid}):super(key: key);

  @override
  _BidState createState() => _BidState();
}

class _BidState extends State<Bid> {
  final _formKey = GlobalKey<FormState>();

  String uid = FirebaseAuth.instance.currentUser.uid;

  final _priceController = TextEditingController();

  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

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
            Text('입찰하기',style: TextStyle(fontFamily: mySetting.font),),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Post').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('데이터가 없습니다.',style: TextStyle(fontFamily: mySetting.font),);
                }
                final documents = snapshot.data.docs;
                return Expanded(
                  child: ListView(
                    children:
                    documents.map((doc) => _buildBidWidget(doc)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidWidget(DocumentSnapshot doc) {
    Future<Widget> _getImage(BuildContext context, String imageName) async {
      Image image;
      image = Image.network(imageName, fit: BoxFit.scaleDown);
      return image;
    }

    if (widget.postid == (doc.id).toString()) {
      return ListTile(
        onTap: () {},
        title: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                FutureBuilder(
                  future: _getImage(context, doc['ImgPath']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        width: 90,
                        height: 100,
                        child: snapshot.data,
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['Title'],
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '현재 입찰가 ',
                          style: TextStyle(
                              fontSize: 20,fontFamily: mySetting.font
                          ),
                        ),
                        Text(
                          doc['AuctionPrice'].toString(),
                          style: TextStyle(
                              fontSize: 20,fontFamily: mySetting.font
                          ),
                        ),
                        Text(
                          '원',
                          style: TextStyle(
                              fontSize: 20,fontFamily: mySetting.font
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            Container(
              width: 500.0,
              height: 1.0,
              color: Colors.black,
            ),
            SizedBox(
              height: 50.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  '입찰금',
                  style: TextStyle(
                      fontSize: 25,fontFamily: mySetting.font
                  ),
                ),
                SizedBox(
                  width: 180,
                ),
                RaisedButton(
                  color: Colors.lightGreen,
                  onPressed: () {
                    if(doc['Price'] == 0)
                      _priceController.text = (doc['AuctionPrice'] + doc['BidUnit']).toString();
                    else
                      _priceController.text = doc['Price'].toString();
                  },
                  child: doc['Price'] == 0 ?
                  Text('즉시 입찰',style: TextStyle(fontFamily: mySetting.font),)
                      :
                  Text('즉시 구매',style: TextStyle(fontFamily: mySetting.font),),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '금액을 입력하세요',
                    ),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '값을 입력하세요';
                      }
                      if (int.parse(value.trim()) <
                          doc['AuctionPrice'] + doc['BidUnit']) {
                        return '최소 입찰가보다 높은 가격을 입력해야 합니다.';
                      }
                      if (int.parse(value.trim()) > doc['Price'] && doc['Price'] != 0) {
                        return '즉시 구매가보다 낮은 가격을 입력해야 합니다.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('최소 입찰가 ',style: TextStyle(fontFamily: mySetting.font),),
                Text((doc['AuctionPrice'] + doc['BidUnit']).toString(),style: TextStyle(fontFamily: mySetting.font),),
                Text(' 원',style: TextStyle(fontFamily: mySetting.font),),
              ],
            ),
            doc['Price'] != 0 ?
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('즉시 구매가 ',style: TextStyle(fontFamily: mySetting.font),),
                Text(doc['Price'].toString(),style: TextStyle(fontFamily: mySetting.font),),
                Text(' 원',style: TextStyle(fontFamily: mySetting.font),),
              ],
            ) :
            Text('                                                           입찰만 가능합니다.',style: TextStyle(fontFamily: mySetting.font),),
            SizedBox(
              height: 120.0,
            ),
            ButtonTheme(
              minWidth: 300.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.blue,
                child: Text('즉시 구매하기',style: TextStyle(fontFamily: mySetting.font),),
                onPressed: () {
                  if (_formKey.currentState.validate() &&
                      int.parse(_priceController.text.trim()) == doc['Price'] && doc['Price'] != 0) {
                    FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postid)
                        .update({'AuctionPrice': doc['Price']});
                    FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postid)
                        .update({'TradeEndDate': Timestamp.now()});
                    FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postid)
                        .update({'Process': 1});
                    FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postid)
                        .update({'Buyer': uid});
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('완료',style: TextStyle(fontFamily: mySetting.font),),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [Text('즉시 구매를 완료했습니다.',style: TextStyle(fontFamily: mySetting.font),)],
                              ),
                            ),
                            actions: [
                              FlatButton(
                                child: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            ButtonTheme(
              minWidth: 300.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.blue,
                child: Text('입찰하기',style: TextStyle(fontFamily: mySetting.font),),
                onPressed: () {
                  if (_formKey.currentState.validate() &&
                      int.parse(_priceController.text.trim()) != doc['Price']) {
                    FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postid)
                        .update({
                      'AuctionPrice': int.parse(_priceController.text.trim())
                    });
                    FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postid)
                        .update({
                      'Buyer' : uid
                    });
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('완료',style: TextStyle(fontFamily: mySetting.font),),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [Text('입찰을 완료했습니다.',style: TextStyle(fontFamily: mySetting.font),)],
                              ),
                            ),
                            actions: [
                              FlatButton(
                                child: Text('확인',style: TextStyle(fontFamily: mySetting.font),),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 1.0,
      );
    }
  }
}
