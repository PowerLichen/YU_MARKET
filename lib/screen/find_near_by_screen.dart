/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : 내 주변 기능
* */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yu_market/screen/find_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_market/data/place_data.dart';
import 'package:yu_market/mypage/setting.dart';

class FindNearByPage extends StatefulWidget {
  @override
  _FindNearByPageState createState() => _FindNearByPageState();
}

class _FindNearByPageState extends State<FindNearByPage> {
  
  //건물 선택
  PlaceData placeData = new PlaceData();

  //컨트롤러
  Completer<GoogleMapController> _controller = Completer();
  
  //등록한 건물 초기 위치
  CameraPosition _initialCameraPosition;

  int initplaceIndex;
  Future<DocumentSnapshot> myDoc;

  void _myplace() async {
    myDoc = FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    print(initplaceIndex);
    print(placeData.latitude[initplaceIndex]);
    print('아아아aaaa');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _myplace();
  }

  @override
  void dispose() {
    //_disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 근처',style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: myDoc,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                String temp = snapshot.data['FavoritePlace'];
                initplaceIndex = placeData.favoritePlace.indexOf(temp);
                //초기 설정 위치
                _initialCameraPosition = CameraPosition(
                  target: LatLng(
                      placeData.latitude[initplaceIndex], placeData.longitude[initplaceIndex]),
                  zoom: 17,
                );
                return _buildGoogleMap(context);  //지도 생성
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    //마커 생성
    Set<Marker> _markers = Set();
    for (int i = 0; i < placeData.favoritePlace.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId(placeData.favoritePlace[i]),
          position: LatLng(placeData.latitude[i], placeData.longitude[i]),
          infoWindow: InfoWindow(
              title: placeData.favoritePlace[i],
              snippet: '물품 보러 가기',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return FindPlace(place: placeData.favoritePlace[i]);  //key 값 받는 판매 대여 물품 목록
                }));
              }),
        ),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        markers: _markers,
      ),
    );
  }
}
