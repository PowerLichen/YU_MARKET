import 'package:flutter/material.dart';
import 'package:yu_market/mypage/setting.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Container(
        height: 50,
        child: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.home,
                size: 18
              ),
              child: Text('홈',style: TextStyle(fontSize: 9,fontFamily: mySetting.font),
              ),
            ),

            Tab(
              icon: Icon(
                Icons.location_on,
                size: 18
              ),
              child: Text('내 주변',style: TextStyle(fontSize: 9,fontFamily: mySetting.font),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.create,
                size: 18
              ),
              child: Text('글쓰기',style: TextStyle(fontSize: 9,fontFamily: mySetting.font),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.chat_bubble,
                size: 18
              ),
              child: Text('채팅',style: TextStyle(fontSize: 9,fontFamily: mySetting.font),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person,
                size: 18
              ),
              child: Text('회원정보',style: TextStyle(fontSize: 9,fontFamily: mySetting.font),
              ),
            ),
          ],
        ),
      ),
    );
  }
}