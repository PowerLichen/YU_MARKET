/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : 후기 작성 기능
* */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:yu_market/mypage/setting.dart';

class WriteReview extends StatefulWidget {
  final poid;
  final suid;
  
  @override
  _WriteReviewState createState() => _WriteReviewState(poids : poid, suids: suid);
  WriteReview({key, @required this.poid,@required this.suid}):super(key: key);
}

class _WriteReviewState extends State<WriteReview> {
  final poids;
  final suids;
  _WriteReviewState({Key key, @required this.poids, @required this.suids});

  //리뷰 작성자 이메일
  String currentUID = FirebaseAuth.instance.currentUser.uid;
  var seller;
  //평점 저장 변수
  double _ratingStarLong = 0; 
  //작성한 후기string 저장 변수
  TextEditingController _reviewText = TextEditingController(); 

  
  @override
  void initState() {
    super.initState();
    getSeller();
  }
  Future getSeller() async {
    seller = await FirebaseFirestore.instance.collection('User').doc(suids).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('후기작성',style: TextStyle(fontFamily: mySetting.font),),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children : <Widget>[
                Container(
                  child: Text('평점', style: TextStyle(fontSize: 24),),
                  alignment: Alignment.centerLeft,
                ),
                 SizedBox(height: 20,),
                /* 평점 제목 란*/
                Container(
                  child: Text(
                  '평점 : $_ratingStarLong',
                  style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                /* 평점 체크*/
                Container(
                  child : RatingBar(
                    maxRating: 5,
                    onRatingChanged: (rating) => setState(() => _ratingStarLong = rating),
                    filledIcon: Icons.star,
                    emptyIcon: Icons.star_border,
                    halfFilledIcon: Icons.star_half,
                    isHalfAllowed: true,
                    filledColor: Colors.blue,
                    size: 50,
                  ),
                ),
                SizedBox(height: 50,),
                /* 후기 제목 란*/
                Container(
                  child: Text('후기', style: TextStyle(fontSize: 24,fontFamily: mySetting.font),),
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(height: 20,),
                 /*후기 작성 텍스트 란*/
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration (
                    border: OutlineInputBorder(),
                    hintText: '내용을 입력 하시오'
                  ),
                  controller: _reviewText,
                ),
                SizedBox(height: 20,),
                /* 후기 작성하기 버튼 */
                RaisedButton (
                  child: Text('후기 작성', style: TextStyle(color: Colors.white,fontFamily: mySetting.font),),
                  color: Colors.blue,
                  onPressed: () {

                    //DB 처리 부분
                    FirebaseFirestore.instance
                    .collection('Review')
                    .doc()
                    .set({'BuyerUID': currentUID, 'Contents' : _reviewText.text, 'Deleted' : false,
                     'PostID' : poids , 'Score' : _ratingStarLong,
                      'SellerUID': suids,'WriteDate' : DateTime.now()});

                    FirebaseFirestore.instance
                    .collection('Post')
                    .doc(poids) //포스트 아아다
                    .update({'Reviewed' : true});

                    print(seller['ReviewCount']);
                    FirebaseFirestore.instance
                    .collection('User')
                    .doc(suids)
                    .update({'ReviewCount':seller['ReviewCount']+1,'Score':seller['Score']+_ratingStarLong});
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

