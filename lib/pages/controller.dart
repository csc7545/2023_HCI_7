
import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class faceController extends GetxController {


  bool _isstopwatchRunning =false;
  // RxBool isstopwatchRunning == false.obs;

  late Timer _stopwatch;
  int _timeCount = 0;
  // bool _isstopwatchRunning = false;
  List<String> _lapTimeList = [];
  SharedPreferences? _prefs;

  void clear(){
    _timeCount = 0;
    _isstopwatchRunning = false;
    _stopwatchpause();
    dispose();
  }

  void stoping(){
    _isstopwatchRunning = false;
    _stopwatchpause();
    update();
  }

  void increase(){
    _timeCount++;
    update();
    print("update timecount ${_timeCount}");
  }

  void starting(){
    _isstopwatchRunning =true;
    _stopwatchstart();
  }



  void _stopwatchstart() {
    if(_isstopwatchRunning == true)
      _stopwatch = Timer.periodic(Duration(seconds: 100000), (timer) {
        // setState(() {
        increase();
        // });
      });
  }

  void _stopwatchpause() {
    if(_isstopwatchRunning == false)
      _stopwatch!.cancel();
    update();
  }

}

