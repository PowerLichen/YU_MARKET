/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : 회원가입기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:yu_market/main.dart';
import 'package:yu_market/data/place_data.dart';
import 'package:yu_market/mypage/setting.dart';


/// Entrypoint example for registering via Email/Password.
class RegisterPage extends StatefulWidget {
  /// The page title.
  final String title = '회원가입';

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stdnum = TextEditingController();
  int _stdnumInt; //학과 int형 변환할것
  bool _radioValue;

  //대학,학과,건물 선택
  PlaceData placeData = new PlaceData();
  //대학선택
  var _selectColleage;

  //학과선택
  List<String> _selectDepartmentList = new List();
  var _selectDepartment;

  //건물선택
  var _selectPlace;

  bool _success;
  String _userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '이메일이 비어 있습니다 입력하시오.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '비밀번호가 비어 있습니다 입력하시오.';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _stdnum,
                    decoration: const InputDecoration(labelText: '학번'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '학번이 비어 있습니다 입력하시오.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '이름'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return '닉네임이 비어 있습니다 입력하시오.';
                      }
                      return null;
                    },
                  ),
                  //성별 선택
                  Row(
                    children : <Widget>[
                      Text('성별   ',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                      SizedBox(width: 30,),
                      Text('남성',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                      Radio(
                        value: true,
                        groupValue: _radioValue,
                        onChanged: _handleRadioValueChanged,
                      ),
                      SizedBox(width: 30,),
                      Text('여성',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                      Radio(
                        value: false,
                        groupValue: _radioValue,
                        onChanged: _handleRadioValueChanged,
                      ),
                    ],
                  ),
                  //단과 대학 선택
                  Row(
                    children: <Widget>[
                      Text('대학   ',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                      SizedBox(width: 30,),
                      DropdownButton(

                        value: _selectColleage,
                        items: placeData.colleageList.map(
                              (value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value,style: TextStyle(fontFamily: mySetting.font),),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectDepartment = null; //학부선택 초기화

                            _selectColleage = value;
                            //_selectColleagenum = _colleageList.
                            //_num = _colleageList.indexOf(_selectColleage);
                            _select();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  //학과 선택
                  Row(
                    children: <Widget>[
                      Text('학과   ',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                      SizedBox(width: 30,),
                      DropdownButton(
                        value: _selectDepartment,
                        items: _selectDepartmentList.map(
                              (value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value,style: TextStyle(fontFamily: mySetting.font),),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectDepartment = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  //자주 가는 건물
                  Row(
                    children: <Widget>[
                      Text('자주가는 건물',style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                      SizedBox(width: 30,),
                      DropdownButton(
                        value: _selectPlace,
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
                            _selectPlace = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: SignInButtonBuilder(
                      icon: Icons.person_add,
                      backgroundColor: Colors.blue,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _register(context);
                        }

                      },
                      text: 'Register',
                    ),
                  ),

                  Container(
                    alignment: Alignment.center,
                    child: Text(_success == null
                        ? ''
                        : (_success
                        ? 'Successfully registered ' + _userEmail
                        : 'Registration failed'),style: TextStyle(fontFamily: mySetting.font),),
                  ),

                ],
              ),
            ),
          )
      ),
    );
  }

  // 회원가입 함수
  void _register(BuildContext context) async {

    int casenum;
    setState(() {
      casenum = 4;
    });

    if (_radioValue == null ) {
      setState(() {
        casenum = 0;
      });
    }
    else if( _selectColleage == null) {
      setState(() {
        casenum = 1;
      });
    }
    else if( _selectDepartment == null ) {
      setState(() {
        casenum = 2;
      });
    }
    else if( _selectPlace == null ) {
      setState(() {
        casenum = 3;
      });
    }
    
    switch(casenum) {
      case 0:
        _showDialog(context, '성별을 선택 하세요');
        break;
      case 1:
        _showDialog(context, '대학을 선택 하세요');
        break;
      case 2:
        _showDialog(context, '학과를 선택 하세요');
        break;
      case 3:
        _showDialog(context, '자주가는 건물을 선택 하세요');
        break;
      case 4:
        final User user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        )).user;

        if (user != null ) {
          setState(() {
            _success = true;
            _userEmail = user.email;
          });

          _stdnumInt = int.parse(_stdnum.text);
          FirebaseFirestore.instance.collection('User')
              .doc(user.uid)
              .set({'College' : _selectColleage, 'Department' : _selectDepartment, 'Email' : _emailController.text, 'FavoritePlace' : _selectPlace, 'Gen' : _radioValue, 'ReviewCount' : 0, 'Score' : 0, 'StudentNo' : _stdnumInt, 'TradeCount' : 0, 'UID' : user.uid, 'UserName' : _nameController.text});
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) {
            return MyApp();
          }));
        }
        else {
          _success = false;
        }
    }
  }
  //라디오 버튼 함수
  void _handleRadioValueChanged(bool value) {
    setState(() {
      _radioValue = value;
      print(_radioValue);
    });
  }
  //대학 선택후 학과 나타내는
  void _select() {
    switch(_selectColleage) {
      case '문과대학':
        _selectDepartmentList = placeData.departmentList1;
        break;
      case '자연과학대학':
        _selectDepartmentList = placeData.departmentList2;
        break;
      case '공과대학':
        _selectDepartmentList = placeData.departmentList3;
        break;
      case '기계IT대학':
        _selectDepartmentList = placeData.departmentList4;
        break;
      case '정치행정대학':
        _selectDepartmentList = placeData.departmentList5;
        break;
      case '상경대학':
        _selectDepartmentList = placeData.departmentList6;
        break;
      case '경영대학':
        _selectDepartmentList = placeData.departmentList7;
        break;
      case '의과대학':
        _selectDepartmentList = placeData.departmentList8;
        break;
      case '약학대학':
        _selectDepartmentList = placeData.departmentList9;
        break;
      case '생명응용과학대학':
        _selectDepartmentList = placeData.departmentList10;
        break;
      case '생활과학대학':
        _selectDepartmentList = placeData.departmentList11;
        break;
      case '사범대학':
        _selectDepartmentList = placeData.departmentList12;
        break;
      case '디자인미술대학':
        _selectDepartmentList = placeData.departmentList13;
        break;
      case '음악대학':
        _selectDepartmentList = placeData.departmentList14;
        break;
      case '기초교육대학':
        _selectDepartmentList = placeData.departmentList15;
        break;
      case '건축학부':
        _selectDepartmentList = placeData.departmentList16;
        break;
      case '국제학부':
        _selectDepartmentList = placeData.departmentList17;
        break;
      default:
        _selectDepartmentList = _selectDepartmentList;

    }
  }
  void _showDialog(BuildContext context, String text) { //회원가입 실패 메시지
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('$text'),
          actions: <Widget>[
            FlatButton(child: Text('확인'), onPressed : () { Navigator.of(context).pop();},),
          ],
        );
      }
    );
  }
}

