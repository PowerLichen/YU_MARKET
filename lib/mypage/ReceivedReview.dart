/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.24
* 기능 설명 : 받은 후기 출력 기능
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yu_market/mypage/setting.dart';
// 받은 후기를 보기 위한 dart 파일
// 사용자 id를 받아온다.
class ReceivedReview extends StatefulWidget {
  final ruid; // 해당 user UID
  final myid;
  ReceivedReview({Key key,@required this.myid ,@required this.ruid}):super(key: key);
  @override
  _ReceivedReviewState createState() => _ReceivedReviewState(ruids: ruid,myID: myid);

}

class _ReceivedReviewState extends State<ReceivedReview> {
  BuildContext ctx;
  final ruids;
  final myID;
  _ReceivedReviewState({Key key,@required this.ruids,@required this.myID});
  @override
  Widget build(BuildContext context) {
    ctx=context;
    return Scaffold(
        appBar: AppBar(   // AppBar는 내가 받은 리뷰 표시
          title: Text('받은 리뷰',style: TextStyle(fontFamily: mySetting.font),),
        ),
        body: StreamBuilder<QuerySnapshot>( // Review를 가져온다.
          stream: FirebaseFirestore.instance.collection('Review').snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return CircularProgressIndicator();
            }
            final docs=snapshot.data.docs;
            List<DocumentSnapshot> dlist = List<DocumentSnapshot>();
            for(var ds in docs){
              if((ds['SellerUID']==ruids)){
                dlist.add(ds);
                print('1');
              }
            }
            return ListView(
              children: dlist.map((dc) => _RebuildBody(dc)).toList(),
            );
          },
        )
    );
  }


  Widget _RebuildBody(DocumentSnapshot dc) {   //Body부분(출력할 부분) doc = 각 후기 하나하나에 대한 정보
    TextEditingController _textController = TextEditingController();
    var format = 'yyyy-MM-dd';
    @override
    void dispose(){
      _textController.dispose();
      super.dispose();
    }

    Future<Widget> _getImage(BuildContext context,String imageName) async{
      Image image;
      image=Image.network(imageName.toString(),
          fit:BoxFit.scaleDown,);
      return image;
    }
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Post').doc(dc['PostID']).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          final datas = snapshot.data.data(); // Post 정보
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
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
                      Container(
                        child:Column(
                          children: <Widget>[
                            FutureBuilder(
                              future: _getImage(context, datas['ImgPath']),
                              builder: (context,snapshot){
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            datas['Title']==null?Text('삭제된 거래 품입니다.',style: TextStyle(fontSize: 18,fontFamily: mySetting.font),):
                            Text(datas['Title'],style: TextStyle(fontSize: 18,fontFamily: mySetting.font),),
                            Text(DateFormat(format).format(dc['WriteDate'].toDate()),style: TextStyle(color: Colors.grey,fontSize: 12,fontFamily: mySetting.font),),
                            Text(dc['Contents'],style: TextStyle(color: Colors.black,fontSize: 15,fontFamily: mySetting.font),softWrap: true,),
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text('★'+dc['Score'].toString(),style: TextStyle(color:Colors.black,fontSize: 15,fontFamily: mySetting.font),),
                          (datas['SellerUID']==myID)?
                          !dc['Deleted']?
                          RaisedButton(
                            child:
                            Text('삭제요청',
                              style: TextStyle(fontSize: 15,fontFamily: mySetting.font),),
                            onPressed:(){
                              Navigator.push(ctx, MaterialPageRoute(builder: (ctx)=>
                                  Scaffold(
                                    appBar: AppBar(
                                      title: Text('삭제요청',style: TextStyle(fontFamily: mySetting.font)),
                                    ),
                                    body: Column(
                                      children:<Widget>[ Container(
                                        margin: EdgeInsets.all(6.0),
                                        padding: EdgeInsets.only(bottom:20),
                                        child: TextField(
                                          controller: _textController,
                                          style: TextStyle(fontFamily: mySetting.font),
                                          maxLines: 1,
                                          decoration: InputDecoration(
                                            hintText: "삭제요청사유",
                                            border:OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            RaisedButton(onPressed:(){
                                              FirebaseFirestore.instance
                                                  .collection('ReviewDelete')
                                                  .doc(dc['PostID'])
                                                  .set({'ReviewID':dc.id,'Contents':_textController.text}); //// 삭제 요청 전송하는 기능 추가구현할 것

                                              FirebaseFirestore.instance
                                                  .collection('Review')
                                                  .doc(dc.id)
                                                  .update({'Deleted':true});
                                              Navigator.of(context).pop();
                                            },
                                                child:Text('삭제요청',style: TextStyle(fontFamily: mySetting.font))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ));
                            },
                          ):
                          RaisedButton(
                            child: Text('삭제요청',style: TextStyle(fontFamily: mySetting.font)),onPressed: null,
                          ):Container(),

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
