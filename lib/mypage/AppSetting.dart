/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.21
* 기능 설명 : 앱 글꼴 등 설정하는 기능
* */
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yu_market/mypage/setting.dart';

class AppSetting extends StatefulWidget {    //환경설정 Stful
  @override
  _AppSettingState createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {    //상태
  SharedPreferences _prefs;
  String _font = 'NanumGothic';
  bool _inform = true;
  @override
  void initState(){
    super.initState();
    _loadSetting();
  }
  _loadSetting() async{ // setting load 하기
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _font= _prefs.getString('font')??'NanumGothic';
      _inform=_prefs.getBool('inform')??true;
    });
  }

  _updateSetting() {  //setting update
    _prefs.setString('font', _font);
    _prefs.setBool('inform',_inform);
    mySetting = Setting(_font,_inform,);
  }

  _notupdateSetting(){ //setting update 안하기(취소)
    _prefs.setString('font', mySetting.font);
    _prefs.setBool('inform',mySetting.inform);
     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('환경설정',style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){    //body()


    toggleButton(){   //toggle button tap 시 상태 toggle 되도록
      setState((){
        _inform=!_inform;
      });
    }

    return Column(    //알림설정~설정완료 까지 출력
      children: <Widget>[
        //알림
        Row(  //여백
          children: <Widget>[
            SizedBox(height: 30,),
          ],
        ),
        Row(  //알림설정 부분
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('알림 설정',style: TextStyle(fontSize: 30,fontFamily: mySetting.font),),
            SizedBox(width: 100,),
            AnimatedContainer(  // 토글 애니메이션 버튼 부분
              duration: Duration(milliseconds: 300),
              height: 40.0,
              width:80.0,
              decoration: BoxDecoration(
                borderRadius:BorderRadius.circular(20.0),
                color: _inform? Colors.greenAccent[100]:Colors.redAccent[100].withOpacity(0.5)
              ),
              child: Stack(
                children: <Widget>[
                  AnimatedPositioned(
                    duration:Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    top: 3.0,
                    left:_inform?40.0:0.0,
                    right: _inform?0.0:40.0,
                    child: InkWell(
                      onTap: toggleButton,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation){
                          return ScaleTransition(child: child, scale:animation);
                        },
                        child: _inform ? Icon(Icons.check_circle,color:Colors.green,size:35.0,key:UniqueKey())
                            : Icon(Icons.remove_circle_outline,color:Colors.red,size:35.0,key:UniqueKey())
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        //글꼴
        Row(
          children: <Widget>[
            SizedBox(height: 30,),
          ],
        ),
        Row(  // 글꼴 설정 부분인데, 글꼴을 pubspec.yaml에 추가해야 하는 듯
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('글꼴설정',style: TextStyle(fontSize: 30,fontFamily: mySetting.font),), // 글꼴 선택, 현재 글꼴 3개
            SizedBox(width: 100,),
            DropdownButton<String>(
              value: _font,
              icon: Icon(Icons.arrow_drop_down_circle_outlined),
              iconSize: 23,
              elevation: 16,
              style: TextStyle(color:Colors.black,fontFamily: _font),
              underline: Container(
                height:2,
                color: Colors.blueAccent,
              ),
              onChanged: (value){
                setState((){
                  _font=value;
                });
              },
              items: <String>['NanumGothic','NotoSansKR','Dokdo']
                  .map<DropdownMenuItem<String>>((String value){
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,style: TextStyle(fontFamily: value,fontSize: 20),),
                );
              }).toList(),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            SizedBox(height: 300,),
          ],
        ),
        //저장
        Row(  // 설정 완료 부분
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('설정완료',style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                AlertDialog(
                  title: Text('설정 완료',style: TextStyle(fontFamily: mySetting.font),),
                  content: Text('설정을 완료하시겠습니까?',style: TextStyle(fontFamily: mySetting.font),),
                  actions: <Widget>[
                    FlatButton(onPressed:(){
                      _updateSetting();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                     }, child: Text('네',style: TextStyle(fontFamily: mySetting.font),)),
                    FlatButton(onPressed:(){
                      _notupdateSetting();
                      Navigator.of(context).pop();  // 설정화면으로 다시 전환
                    }, child: Text('아니요',style: TextStyle(fontFamily: mySetting.font),)),
                  ],
                ),
                ));
              },
            ),

          ],
        ),
      ],
    );
  }



}
