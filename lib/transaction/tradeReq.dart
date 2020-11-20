import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TradeRequestScreen extends StatefulWidget {
  final String postId;
  final DocumentSnapshot postDoc;

  const TradeRequestScreen({Key key, this.postId, this.postDoc})
      : super(key: key);
  @override
  _TradeRequestScreenState createState() =>
      _TradeRequestScreenState(postId, postDoc);
}

class _TradeRequestScreenState extends State<TradeRequestScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String postId;
  final DocumentSnapshot postDoc;

  int _type = 0;
  // 거래 유형 정의. 0, 1, 2 => 판매, 대여, 경매

  DateTime tradeDT, returnDT;
  TimeOfDay tradeToD, returnToD;

  String tradeDate, tradeTime;
  String returnDate, returnTime;

  TextEditingController dateController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController returnTimeController = TextEditingController();

  final _favoritePlace = [
    'A08사범대학',
    'B01노천강당',
    'B02상경관',
    'B03인문관',
    'C04인문계식당',
    'B03인문관B03인문관',
    'E02천마아트센터',
    'E21IT관',
    'E29기계관',
    'F01약대본관',
    'F24과학도서관',
    'G01생활과학대학본관'
  ];
  String selectedPlace;
  _TradeRequestScreenState(this.postId, this.postDoc);

  @override
  void initState() {
    super.initState();
    // 0, 1, 2 => 판매, 대여, 경매
    _type = postDoc.data()['TradeType'];

    selectedPlace = postDoc.data()['Place'];

    // tradeDT = DateTime(0);
    // returnDT = DateTime(0);
  }

  bool tradeReq() {
    if (postDoc.data()['Process'] == 1) {
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("해당 물품은 거래 중인 물품입니다.")));
      return false;
    }

    if (tradeDT == null || tradeToD == null) {
      // 거래일정 미입력 에러
      // Text("거래 일정을 입력해주세요."),
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("거래 일정을 입력해주세요.")));
      return false;
    } else {
      if (_type == 1) {
        //대여 물품일때
        if (returnDT == null || returnToD == null) {
          // 반납일정 미입력 에러
          // Text("반납 일정을 입력해주세요."),
          scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("반납 일정을 입력해주세요.")));
          return false;
        } else {
          //대여물품 DB처리
          FirebaseFirestore.instance
              .collection('Post')
              .doc(postId)
              .collection('TradeReq')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .set({
            'Buyer': FirebaseAuth.instance.currentUser.uid,
            'Place': selectedPlace,
            'TradeDate': Timestamp.fromDate(DateTime(tradeDT.year,
                tradeDT.month, tradeDT.day, tradeToD.hour, tradeToD.minute)),
            'ReturnDate': Timestamp.fromDate(DateTime(returnDT.year,
                returnDT.month, returnDT.day, returnToD.hour, returnToD.minute))
          });
          return true;
        }
      }
      //일반물품 DB처리
      FirebaseFirestore.instance
          .collection('Post')
          .doc(postId)
          .collection('TradeReq')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'Buyer': FirebaseAuth.instance.currentUser.uid,
        'Place': selectedPlace,
        'TradeDate': Timestamp.fromDate(DateTime(tradeDT.year, tradeDT.month,
            tradeDT.day, tradeToD.hour, tradeToD.minute)),
      });
      return true;
    }
    //거래 신청 완료 시 해당 Post의 TradeReq에 자신 uid로 문서 생성
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: _type == 0 ? Text('거래 신청') : Text('대여 신청'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                //// 썸네일 이미지 출력
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
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('희망거래 장소 : '),
                  DropdownButton(
                      value: selectedPlace,
                      items: _favoritePlace.map(
                        (value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value));
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPlace = value;
                        });
                      }),
                ],
              ),

              SizedBox(height: 20.0),
              GestureDetector(
                onTap: datePicker,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: '거래일자 선택',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: timePicker,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: '거래시간 선택',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),
              ),
              //대여 선택
              _type == 0
                  ? Container()
                  : Column(
                      children: [
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: returnDatePicker,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: returnDateController,
                              decoration: InputDecoration(
                                labelText: '반납일자 선택',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: returnTimePicker,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: returnTimeController,
                              decoration: InputDecoration(
                                labelText: '반납시간 선택',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              //거래 장소 추천
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
                    '거래 신청',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  onPressed: () {
                    bool result = tradeReq();
                    if (result) {
                      Navigator.pop(context, true);
                    }
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

  void datePicker() async {
    final year = DateTime.now().year;

    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(year),
      lastDate: DateTime(year + 1),
    );

    if (dateTime != null) {
      tradeDT = dateTime;
      dateController.text = dateTime.toString().split(' ')[0];
    }
  }

  void returnDatePicker() async {
    final year = DateTime.now().year;

    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(year),
      lastDate: DateTime(year + 1),
    );

    if (dateTime != null) {
      returnDT = dateTime;
      returnDate =
          returnDateController.text = dateTime.toString().split(' ')[0];
    }
  }

  void timePicker() async {
    String hour, min;
    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null) {
      tradeToD = pickedTime;
      if (pickedTime.hour < 10) {
        hour = '0' + pickedTime.hour.toString();
      } else {
        hour = pickedTime.hour.toString();
      }
      if (pickedTime.minute < 10) {
        min = '0' + pickedTime.minute.toString();
      } else {
        min = pickedTime.minute.toString();
      }
      timeController.text = '$hour:$min';
    }
  }

  void returnTimePicker() async {
    String hour, min;
    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null) {
      returnToD = pickedTime;
      if (pickedTime.hour < 10) {
        hour = '0' + pickedTime.hour.toString();
      } else {
        hour = pickedTime.hour.toString();
      }
      if (pickedTime.minute < 10) {
        min = '0' + pickedTime.minute.toString();
      } else {
        min = pickedTime.minute.toString();
      }
      returnTimeController.text = '$hour:$min';
    }
  }
}

//참조: https://github.com/lightlitebug/datetime-functions-widgets/blob/master/lib/year_month_picker.dart
