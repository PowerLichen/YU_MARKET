/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : Toppage
* */
import 'package:flutter/material.dart';
import 'package:yu_market/screen/sell_near_by_screen.dart';
import 'package:yu_market/screen/rental_near_by_screen.dart';
import 'package:yu_market/screen/auction_near_by_screen.dart';
import 'package:yu_market/mypage/setting.dart';

class FindPlace extends StatefulWidget {

  final place;
  FindPlace({key, @required this.place}):super(key: key);

  _FindPlaceState createState() => _FindPlaceState(places: place);

}

class _FindPlaceState extends State<FindPlace> {
  
  final choices = ['판매', '대여', '경매'];

  final places;
  _FindPlaceState({Key key, @required this.places});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
          length: choices.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(places + '물품정보',style: TextStyle(fontFamily: mySetting.font),),
              backgroundColor: Colors.blue,
              bottom: TabBar(
                tabs: choices.map((String choice) {
                  return Tab(text: choice);
                }).toList(),
            ),
          ),
          body: TabBarView(
              children: <Widget>[
                SellPage(place: places,),    //판매 물품 출력 페이지로 변경
                RentalPage(place: places,), //대여 물품 출력 페이지로 변경
                AuctionPage(place: places,),  //경매 물품 출력 페이지로 변경
              ],
            ),
        ),
      ),
    );
  }
}