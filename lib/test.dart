import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String id,peerId,groupChatId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    id='B6tlC6AdQPVMdrb1eab8uTSy6sI3';
    peerId='Gygrfkw6z2QjEPOCGBNnWvXrg9B3';
    if (id.hashCode <= peerId.hashCode) {
      setState(() {
        groupChatId = '$id-$peerId';
      });
    } else {
      setState(() {
        groupChatId = '$peerId-$id';
      });
    }
    print(groupChatId);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}


