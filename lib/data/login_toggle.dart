import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LoginToggle extends ChangeNotifier{
  bool _isJoin = false;
  bool get isJoin => _isJoin;
  
  void toggle() {
    _isJoin = !_isJoin;
    notifyListeners();

  }
}