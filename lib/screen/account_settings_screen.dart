/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : 계정정보 변경
* */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yu_market/data/place_data.dart';
import 'package:yu_market/mypage/setting.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  
  String currentEmail = FirebaseAuth.instance.currentUser.email;
  String currentuid = FirebaseAuth.instance.currentUser.uid;
  
  //건물 선택
  PlaceData placeData = new PlaceData();
  var _selectPlace = '사범대학';

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        title: Text('계정정보설정',style: TextStyle(fontFamily: mySetting.font),),
      ),  
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection("User")
          .where("Email", isEqualTo: currentEmail)
          .snapshots(),
        builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

          return _buildList(context, snapshot.data.docs);
        },
      ),
    );
  }

 Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
   return ListView(
     padding: const EdgeInsets.only(top: 20.0),
     children: snapshot.map((data) => _buildListItem(context, data)).toList(),
   );
 }

 Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
  
  StateSetter _setState;
   
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      children: <Widget> [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('계정정보', style: TextStyle(fontSize: 25 ,fontFamily: mySetting.font),),
              SizedBox(width: 1000,),
            ],
          ),
          SizedBox(height: 20,),
        //이메일
        Row(
          children: <Widget> [
            Text('이메일 : ', style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                SizedBox(width: 10,),
                Text(currentEmail, style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              ]
          ),
          SizedBox(height: 20,),
          //이름
          Row(
          children: <Widget> [
            Text('이름 : ', style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
                SizedBox(width: 10,),
                Text(data['UserName'], style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              ]
          ),
          SizedBox(height: 20,),
          //대학
          Row(
            children: <Widget> [
              Text('대학 : ', style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
              SizedBox(width: 10,),
              Text(data['College'], style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              SizedBox(width: 10,),
            ]
          ),
          SizedBox(height: 20,),
          //학과
          Row(
            children: <Widget> [
              Text('학과 : ', style: TextStyle(fontSize: 20,fontFamily: mySetting.font),),
              SizedBox(width: 10,),
              Text(data['Department'], style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              SizedBox(width: 10,),
            ]
          ),
          SizedBox(height: 20,),
          //자주가는 건물
          Container(color: Colors.grey, width: 1000, height: 1,),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('자주 가는 건물 설정', style: TextStyle(fontSize: 25 ,fontFamily: mySetting.font),),
              SizedBox(width: 1000,),
            ],
          ),
          SizedBox(height: 20,),
          Row(
            children: <Widget> [  
              SizedBox(width: 10,),
              Text(data['FavoritePlace'], style: TextStyle(fontSize: 25,fontFamily: mySetting.font),),
              SizedBox(width: 10,),
              RaisedButton(
                
                color: Colors.orange,
                child: Text('변경',style: TextStyle(fontFamily: mySetting.font),),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('제목',style: TextStyle(fontFamily: mySetting.font),),
                        content: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            _setState = setState;
                            return DropdownButton(
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
                            );
                          }
                        ),
                        actions: <Widget>[
                        FlatButton(
                          child: Text('OK',style: TextStyle(fontFamily: mySetting.font),),
                          onPressed: () {
                            FirebaseFirestore.instance
                              .collection('User')
                              .doc(currentuid)
                              .update({'FavoritePlace' :  _selectPlace });
                            Navigator.pop(context, "OK");
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel',style: TextStyle(fontFamily: mySetting.font),),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                      ],
                    );
                  },
                );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
