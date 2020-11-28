/*
* 최초 작성자 : 김상호
* 작성일 : 2020.11.15
* 변경일 : 2020.11.21
* 기능 설명 : 내 세팅 저장을 위한 class
* */

class Setting{
  String font;
  bool inform;

  Setting(this.font,this.inform);
}

var mySetting= Setting('NanumGothic',true);