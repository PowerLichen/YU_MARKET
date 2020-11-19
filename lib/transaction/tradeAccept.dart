import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TradeAcceptScreen extends StatefulWidget {
  final String postId;
  final DocumentSnapshot postDoc;
  final int type;

  const TradeAcceptScreen({Key key, this.postId, this.postDoc, this.type})
      : super(key: key);
  @override
  _TradeAcceptScreenState createState() => _TradeAcceptScreenState(postId, postDoc, type);
}

class _TradeAcceptScreenState extends State<TradeAcceptScreen> {
  final String postId;
  final DocumentSnapshot postDoc;
  final int _type;
  // 거래 유형 정의. 0, 1, 2 => 판매, 대여, 경매
  String tradeDate, tradeTime;
  String returnDate, returnTime;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController returnTimeController = TextEditingController();

  _TradeAcceptScreenState(this.postId, this.postDoc, this._type);

  @override
  void initState() {
    super.initState();
    Timestamp tempTS;
    DateTime tempDT;

    //판매 물품의 경우
    if (_type == 0) {
      tempTS = postDoc['EndDate'];
      tempDT = tempTS.toDate();
      dateController.text =
          '${tempDT.year}-${tempDT.month}-${tempDT.day}'; //[DB에서 가져온 tradedate]
      timeController.text =
          '${tempDT.hour}:${tempDT.minute}'; //[DB에서 가져온 tradeTime]
    }

    //대여 물품의 경우
    if (_type == 1) {
      //거래 시간
      tempTS = postDoc['StartDate'];
      tempDT = tempTS.toDate();
      dateController.text =
          '${tempDT.year}-${tempDT.month}-${tempDT.day}'; //[DB에서 가져온 tradedate]
      timeController.text =
          '${tempDT.hour}:${tempDT.minute}'; //[DB에서 가져온 tradeTime]

      //반납시간
      tempTS = postDoc['EndDate'];
      tempDT = tempTS.toDate();
      returnDateController.text =
          '${tempDT.year}-${tempDT.month}-${tempDT.day}'; //[DB에서 가져온 tradedate]
      returnTimeController.text =
          '${tempDT.hour}:${tempDT.minute}'; //[DB에서 가져온 tradeTime]

    }
  }

  tradeAccept(){
    FirebaseFirestore.instance.collection('Post').doc(postId).update({
      'Process': 2,
      'TradeEndDate':Timestamp.fromDate(DateTime.now())
    });
    //거래 완료 시 Process를 2(거래완료)로 변경 
    //TODO: 푸시알림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _type == 0 ? Text('거래요청 확인') : Text('대여요청 확인'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16.0),
                  child: CircleAvatar(child: Text('A')),
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
              AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '요청된 희망거래 장소',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
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

              SizedBox(height: 20.0),
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
                        SizedBox(height: 20.0),
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
                        SizedBox(height: 20.0),
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
          SizedBox(height: 40.0),
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
                  onPressed: (){
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
    );
  }
}

//참조: https://github.com/lightlitebug/datetime-functions-widgets/blob/master/lib/year_month_picker.dart
