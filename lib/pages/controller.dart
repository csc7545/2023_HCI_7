
import 'dart:async';
import 'dart:io';
// import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class faceController extends GetxController {
  bool _isstopwatchRunning = false;

  late Timer _stopwatch = Timer.periodic(Duration(seconds: 1), (timer){});
  int _timeCount = 0;
  List<String> _lapTimeList = [];
  SharedPreferences? _prefs;

  bool getFlag() {
    return _isstopwatchRunning;
  }

  bool changeFlag() {
    return _isstopwatchRunning = !_isstopwatchRunning;
  }

  void clear(){
    _timeCount = 0;
    _isstopwatchRunning = false;
    _stopwatchpause();
    dispose();
  }

  void stoping(){
    _isstopwatchRunning = false;
    print('stoping works!');
    update();
  }

  void increase(){
    _timeCount++;
    update();
    print("update timecount ${_timeCount}");
  }

  void starting(){
    _isstopwatchRunning = true;
    print('starting works');
    update();
  }


  void _stopwatchstart() {
    if(_isstopwatchRunning == true)
      _stopwatch = Timer.periodic(Duration(seconds: 100000), (timer) {
        // setState(() {
        // increase();
        // });
      });
  }

  void _stopwatchpause() {
    if(_isstopwatchRunning == false)
      _stopwatch!.cancel();
    update();
  }

  void OnVibration() {
    Vibration.vibrate(duration: 1000); //1000 = 1초
  }
}