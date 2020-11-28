/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : 로그인 기능
* */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_market/sangs/agree_page.dart';
import 'package:yu_market/mypage/setting.dart';

class LogInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            //앱 로고
            Center(child: Image.asset('images/logo.png',height: 250,),),
            //로그인 입력 폼
            _EmailPasswordForm(), 
            //회원 가입 버튼 
            FlatButton (
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) {
                  return PageNew();
                  }));},
              child: Text("회원가입 하기", style: TextStyle(color: Colors.blue,fontFamily: mySetting.font),),
            ),
          ],
        );
      }),
    );
  }
}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();   //아이디
  final TextEditingController _passwordController = TextEditingController();//비번

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String value) {
                    if (value.isEmpty) return 'Please enter some text';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (String value) {
                    if (value.isEmpty) return 'Please enter some text';
                    return null;
                  },
                  obscureText: true,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: RaisedButton(
                    color: Colors.blue,
                    child: Text('로그인',style: TextStyle(color: Colors.white,fontFamily: mySetting.font),),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _login();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 로그인 함수
  void _login() async {
    try {
      final User user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )).user;

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("${user.email} signed in",style: TextStyle(fontFamily: mySetting.font),),
      ));

    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Failed to login in with Email & Password",style: TextStyle(fontFamily: mySetting.font),),
      ));
    }
  }
}







