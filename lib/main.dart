import 'package:flutter/material.dart';
import 'package:yumarket_chat/chat/chat_list.dart';
import 'package:yumarket_chat/login_screen.dart';
import 'package:yumarket_chat/test.dart';
import 'package:yumarket_chat/transaction/tradeAccept.dart';
import 'package:yumarket_chat/transaction/tradeReq.dart';
import 'package:yumarket_chat/login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat demo',
      home: LogInPage(),
    );
  }
}
