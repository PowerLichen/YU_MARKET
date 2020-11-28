/*
* 최초 작성자 : 김현수
* 작성일 : 2020.11.15
* 변경일 : 2020.11.25
* 기능 설명 : 자신이 작성한 후기 리스트 출력 기능 
* */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:yu_market/mypage/setting.dart';


class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  
  //Stream<QuerySnapshot> currentStream;
  String currentUID = FirebaseAuth.instance.currentUser.uid;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        title: Text('내가 쓴 후기',style: TextStyle(fontFamily: mySetting.font),),
      ),  
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection("Review")
          .where("BuyerUID", isEqualTo: currentUID)
          .snapshots(),
        builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var dc = snapshot.data.docs;
          return ListView(
            children: dc.map((dc) => _buildListItem(dc)).toList(),
          );
        },
      ),
    );
  }

 Widget _buildListItem(dc) {
   var format = 'yyyy-MM-dd';
   Future<Widget> _getImage(BuildContext context,String imageName) async{
     Image image;
     image=Image.network(imageName.toString(),
       fit:BoxFit.scaleDown,);
     return image;
   }

   return StreamBuilder<DocumentSnapshot>(
     stream: FirebaseFirestore.instance.collection('Post').doc(dc['PostID']).snapshots(),
     builder: (context, snapshot) {
       if(!snapshot.hasData) return CircularProgressIndicator();
       final datas=snapshot.data.data();
       return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
         child: Container(
           decoration: BoxDecoration(
             border: Border.all(color: Colors.grey),
             borderRadius: BorderRadius.circular(5.0),
           ),
           child:
              Container(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder(
                          future:_getImage(context, datas['ImgPath']),
                          builder:(context,snapshot){
                            if(snapshot.connectionState==ConnectionState.done){
                              return Container(
                                width: 50,
                                height: 50,
                                child: snapshot.data,
                              );
                            }
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return Container(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Container();
                          }
                        ),//포스트 사진 파일
                        SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              datas['Title']==null?
                                  Text('삭제된 거래품입니다.',style: TextStyle(fontSize:18,fontFamily: mySetting.font),):
                              Text(datas['Title'], style: TextStyle(fontSize: 18,fontFamily: mySetting.font),),
                              Text(DateFormat(format).format(dc['WriteDate'].toDate()), style: TextStyle(color: Colors.grey, fontSize: 12,fontFamily: mySetting.font )),
                              Text(dc['Contents'], style: TextStyle(color: Colors.black, fontSize: 15,fontFamily: mySetting.font ), softWrap: true,),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [ Text('★' + dc['Score'].toString(), style: TextStyle(color: Colors.blueAccent, fontSize: 18,fontFamily: mySetting.font ),),
                          ],
                        ),
                      ],
                    ),
                  ),
               ),
         ),
       );
     }
   );
 }
}



