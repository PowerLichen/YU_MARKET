/*
* 최초 작성자 : 이상수
* 작성일 : 2020.11.14
* 변경일 : 2020.11.21
* 기능 설명 : 약관 동의를 위한 기능 페이지
* */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yu_market/mypage/setting.dart';
import 'package:yu_market/screen/register_screen.dart';

enum AGREE { OK, NO }

class PageNew extends StatefulWidget {
  @override
  _PageNewState createState() => _PageNewState();
}

class _PageNewState extends State<PageNew> {
  AGREE _agree = AGREE.OK;
  AGREE _agree1 = AGREE.OK;
  bool first_ag = true;
  bool second_ag = true;

  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      first_ag = (_prefs.getBool('first') ?? true);
      second_ag = (_prefs.getBool('second') ?? true);

      if (first_ag)
        _agree = AGREE.OK;
      else
        _agree = AGREE.NO;

      if (second_ag)
        _agree1 = AGREE.OK;
      else
        _agree1 = AGREE.NO;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이용약관',style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 10.0,
              child: Container(
                alignment: Alignment.center,
                width: 350,
                height: 200,
                child: Text('가입 하는것을 동의 하십니까? \n 동의 한다면 동의 \n 거절이라면 거절',style: TextStyle(fontFamily: mySetting.font),),
              ),
            ),
            RadioListTile(
              title: Text('동의',style: TextStyle(fontFamily: mySetting.font),),
              value: AGREE.OK,
              groupValue: _agree,
              onChanged: (value) {
                setState(() {
                  _agree = value;
                  first_ag = true;
                });
              },
            ),
            RadioListTile(
              title: Text('거절',style: TextStyle(fontFamily: mySetting.font),),
              value: AGREE.NO,
              groupValue: _agree,
              onChanged: (value) {
                setState(() {
                  _agree = value;
                  first_ag = false;
                });
              },
            ),
            Container(
              width: 500.0,
              height: 1.0,
              color: Colors.black,
            ),
            SizedBox(
              height: 30.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 10.0,
              child: Container(
                alignment: Alignment.center,
                width: 350,
                height: 200,
                child: Text('개인정보는 서버에 저장됩니다. \n 동의 한다면 동의 \n 거절이라면 거절',style: TextStyle(fontFamily: mySetting.font)),
              ),
            ),
            RadioListTile(
              title: Text('동의',style: TextStyle(fontFamily: mySetting.font),),
              value: AGREE.OK,
              groupValue: _agree1,
              onChanged: (value) {
                setState(() {
                  _agree1 = value;
                  second_ag = true;
                });
              },
            ),
            RadioListTile(
              title: Text('거절',style: TextStyle(fontFamily: mySetting.font),),
              value: AGREE.NO,
              groupValue: _agree1,
              onChanged: (value) {
                setState(() {
                  _agree1 = value;
                  second_ag = false;
                });
              },
            ),
            Container(
              width: 500.0,
              height: 1.0,
              color: Colors.black,
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text('제출',style: TextStyle(fontFamily: mySetting.font),),
              color: Colors.black12,
              onPressed: () {
                if(first_ag && second_ag){
                  _prefs.setBool('first', first_ag);
                  _prefs.setBool('second', second_ag);
                  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) {
                    return RegisterPage();
                  }));
                }
                else{
                  showDialog( // 이 부분 바뀌었습니다.
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('실패',style: TextStyle(fontFamily: mySetting.font),),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text('약관에 모두 동의해야 합니다.',style: TextStyle(fontFamily: mySetting.font),),
                              ],
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
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
