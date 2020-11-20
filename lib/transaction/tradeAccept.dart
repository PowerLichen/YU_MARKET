/*
* 최초 작성자 : 최민수
* 작성일 : 2020.11.16
* 변경일 : 2020.11.20
* 기능 설명 : 요청된 거래를 수락하는 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TradeAcceptScreen extends StatefulWidget {
  final String postId;
  final DocumentSnapshot postDoc;
  final DocumentSnapshot reqDoc;
  final int type;

  const TradeAcceptScreen(
      {Key key, this.postId, this.postDoc, this.type, this.reqDoc})
      : super(key: key);
  @override
  _TradeAcceptScreenState createState() =>
      _TradeAcceptScreenState(postId, postDoc, reqDoc, type);
}

class _TradeAcceptScreenState extends State<TradeAcceptScreen> {
  final String postId;
  final DocumentSnapshot postDoc;
  final DocumentSnapshot reqDoc;
  final int _type;
  // 거래 유형 정의. 0, 1, 2 => 판매, 대여, 경매
  String tradeDate, tradeTime;
  String returnDate, returnTime;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController returnTimeController = TextEditingController();

  _TradeAcceptScreenState(this.postId, this.postDoc, this.reqDoc, this._type);

  @override
  void initState() {
    super.initState();
    loadReqData();
  }

  loadReqData() {
    //reqDoc은 요청된 거래 doc
    Timestamp tempTS;
    DateTime tempDT;

    tempTS = reqDoc['TradeDate'];
    tempDT = tempTS.toDate();
    dateController.text =
        DateFormat('yyyy-MM-dd').format(tempDT); //[DB에서 가져온 tradedate]
    timeController.text =
        DateFormat('kk:mm').format(tempDT); //[DB에서 가져온 tradeTime]

    //대여 물품의 경우
    if (_type == 1) {
      tempTS = reqDoc['ReturnDate'];
      tempDT = tempTS.toDate();
      returnDateController.text =
          DateFormat('yyyy-MM-dd').format(tempDT); //[DB에서 가져온 tradedate]
      returnTimeController.text =
          DateFormat('kk:mm').format(tempDT); //[DB에서 가져온 tradeTime]
    }
  }

  tradeAccept() {
    if (_type == 0) {
      //판매물품 DB처리
      FirebaseFirestore.instance.collection('Post').doc(postId).update({
        'Buyer': reqDoc.id,
        'Process': 1,
        'Place': reqDoc['Place'],
        'StartDate': reqDoc['TradeDate'],
        'EndDate': reqDoc['ReturnDate'],
      });
    } else if (_type == 1) {
      //대여물품 DB처리
      FirebaseFirestore.instance.collection('Post').doc(postId).update({
        'Buyer': reqDoc.id,
        'Process': 1,
        'Place': reqDoc['Place'],
        'EndDate': reqDoc['TradeDate'],
      });
    }
    //거래 승인 시 Process를 1(거래 중)로 변경
    //TODO: 푸시알림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: _type == 0 ? Text('거래요청 확인') : Text('대여요청 확인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Image.network(
                      postDoc.data()['ImgPath'],
                      fit: BoxFit.scaleDown,
                    ),
                    width: 100.0,
                    height: 100.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(postDoc.data()['Title']),
                        Text('${postDoc.data()['Price'].toString()} 원'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // SizedBox(height: 20.0),
            // Text('요청자> 컴공생A'),     //TODO: 학번이 나타나야 함
            SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('희망거래 장소 : '),
                    Text(reqDoc['Place']),
                  ],
                ),
                SizedBox(height: 8.0),
                AbsorbPointer(
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: '요청된 거래일자',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),

                SizedBox(height: 8.0),
                AbsorbPointer(
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: '요청된 거래시간',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),

                //대여 선택
                _type == 0
                    ? Container()
                    : Column(
                        children: [
                          SizedBox(height: 8.0),
                          AbsorbPointer(
                            child: TextFormField(
                              controller: returnDateController,
                              decoration: InputDecoration(
                                labelText: '요청된 반납일자',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          AbsorbPointer(
                            child: TextFormField(
                              controller: returnTimeController,
                              decoration: InputDecoration(
                                labelText: '요청된 반납시간',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                //요청된 거래 장소
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonTheme(
                  height: 50,
                  minWidth: MediaQuery.of(context).size.width / 4,
                  child: RaisedButton(
                    child: Text(
                      '거래 승인',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    onPressed: () {
                      tradeAccept();
                      Navigator.pop(context, true);
                    },
                  ),
                ),
                SizedBox(width: 40.0),
                ButtonTheme(
                  height: 50,
                  minWidth: MediaQuery.of(context).size.width / 4,
                  child: RaisedButton(
                    child: Text(
                      '취소',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//참조: https://github.com/lightlitebug/datetime-functions-widgets/blob/master/lib/year_month_picker.dart
