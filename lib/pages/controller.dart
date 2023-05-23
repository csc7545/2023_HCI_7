
import 'dart:async';
import 'dart:io';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class faceController extends GetxController {


  bool _isstopwatchRunning = false;
  // RxBool isstopwatchRunning == false.obs;


  bool isflag(){
    print("isflag  ${_isstopwatchRunning}");
    return _isstopwatchRunning ;


  }


  void clear(){
    // _timeCount = 0;
    _isstopwatchRunning = false;
    dispose();
  }

  void stoping(){
    _isstopwatchRunning = false;
    update();
    print("stoping  ${_isstopwatchRunning}");
  }


  void starting(){
    _isstopwatchRunning =true;
    update();
    print("starting  ${_isstopwatchRunning}");
  }


}

