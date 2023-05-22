
import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class faceController extends GetxController {


  // bool _isstopwatchRunning =false;
  RxBool isstopwatchRunning == false.obs;

  late Timer _stopwatch;
  int _timeCount = 0;
  // bool _isstopwatchRunning = false;
  List<String> _lapTimeList = [];
  SharedPreferences? _prefs;

  void stoping(){
    _isstopwatchRunning = false;
    if( _isstopwatchRunning == false)
      _stopwatch?.cancel();
  }
  void starting(){
    _isstopwatchRunning =true;
    if(_isstopwatchRunning == true)
      _stopwatch = Timer.periodic(Duration(milliseconds: 10), (timer) {
        setState(() {
          _timeCount++;
        });
      });
  }


  //
  void _stopwatchstart() {
    if(_isstopwatchRunning == true)
      _stopwatch = Timer.periodic(Duration(milliseconds: 10), (timer) {
        setState(() {
          _timeCount++;
        });
      });
  }

  void _stopwatchpause() {
    if(_isstopwatchRunning == false)
      _stopwatch?.cancel();
  }

}