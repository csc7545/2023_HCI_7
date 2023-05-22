import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hp/pages/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hp/utils/mlkit_utils.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:rxdart/rxdart.dart';
import './camera.dart';
import 'controller.dart';


class MyTimer extends StatefulWidget {
  final String breakTime;
  final String workTime;
  final String workSessions;

  const MyTimer(
      {Key? key,
      required this.breakTime,
      required this.workTime,
      required this.workSessions})
      : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<MyTimer> {
  bool _isRunning = false;
  Duration _time = const Duration(minutes: 60);
  Duration _break = const Duration(minutes: 10);
  int _timeInt = 60;
  int _counter = 1;
  int _sessionCount = 4;
  int _timerCount = 0;
  int _currMax = 60;
  Timer? _timer;
  SharedPreferences? _prefs;

  final fController = Get.put(faceController());


  // late Timer _stopwatch;
  // int _timeCount = 0;
  // bool _isstopwatchRunning = false;
  // List<String> _lapTimeList = [];
  //

  @override
  void initState() {
    super.initState();
    try {
      if (widget.breakTime == '0') {
        throw Exception('Break time cannot be 0');
      }
      _timeInt = int.parse(widget.workTime);
      _time = Duration(minutes: _timeInt);
      _break = Duration(minutes: int.parse(widget.breakTime));
      _sessionCount = int.parse(widget.workSessions);
      _currMax = _timeInt;
    } catch (e) {
      _timeInt = 60;
      _time = Duration(minutes: _timeInt);
      _break = const Duration(minutes: 10);
      _sessionCount = 4;
      AnimatedSnackBar(
        builder: ((context) {
          return Container(
            padding: const EdgeInsets.all(8),
            color: Colors.redAccent,
            height: 65,
            child: Flex(
              direction: Axis.vertical,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.close,
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Invalid input!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    SizedBox(
                        width:
                            50), // Add some horizontal spacing to align the text with the first message
                    Text(
                      "Please enter valid numbers to start.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ).show(context);
      Navigator.pop(context);
    }
    _getPrefs();
  }

  void _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // void _stopwatchstart() {
  //   _stopwatch = Timer.periodic(Duration(milliseconds: 10), (timer) {
  //     setState(() {
  //       _timeCount++;
  //     });
  //   });
  // }
  //
  // void _stopwatchpause() {
  //   _stopwatch?.cancel();
  // }
  //
  // void _clickResetButton() {
  //   setState(() {
  //     _isRunning = false;
  //     _stopwatch?.cancel();
  //     _lapTimeList.clear();
  //     _timeCount = 0;
  //   });
  // }
  //
  // void _recordLapTime(String time) {
  //   _lapTimeList.insert(0, '${_lapTimeList.length + 1}등 $time');
  // }
  //
  // Future<void> _storestopwatchTime() async {
  //   String? curr = '';
  //   curr = _prefs?.getString('time');
  //   var now = new DateTime.now();
  //   DateTime date = DateTime(now.year, now.month, now.day);
  //   String formattedDate = "${date.day}-${date.month}-${date.year}";
  //   await _prefs!.setString(
  //       'time', '$curr / ${_sessionCount * _timeInt} $formattedDate');
  // }
  //
  // Future<void> _resetstopwatchTime() async {
  //   await _prefs!.setString('time', '');
  // }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time = _time - const Duration(seconds: 1);
        if (_time.inSeconds <= 0) {
          if (_timerCount % 2 == 1) {
            _time = Duration(minutes: _timeInt);
            _currMax = _timeInt;
            _timerCount++;
          } else {
            _time = _break;
            _currMax = _break.inMinutes;
            _counter++;
            _timerCount++;
          }
          if (_counter > _sessionCount) {
            AnimatedSnackBar(
              builder: ((context) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.orangeAccent,
                  height: 65,
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle_outline,
                            size: 30,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Session Completed!',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                              width:
                                  50), // Add some horizontal spacing to align the text with the first message
                          Text(
                            'You logged ${_sessionCount * _timeInt} minutes.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ).show(context);
            FocusManager.instance.primaryFocus?.unfocus();
            // _storeTime();
            Navigator.pop(context);
          }

          _stopTimer();
          _isRunning = false;
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      if (_isRunning) {
        _stopTimer();
      }
      _time = const Duration(minutes: 60);
      if (_timerCount % 2 == 1) {
        _time = Duration(minutes: _break.inMinutes);
      } else {
        _time = Duration(minutes: _timeInt);
      }
      _isRunning = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final int minutes = _time.inMinutes;
    final int seconds = _time.inSeconds % 60;
    String timerState = "Break";
    if (_timerCount % 2 == 0) {
      timerState = '$_counter / $_sessionCount';
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.black,
        title: Text.rich(
          TextSpan(
            text: fController._isstopwatchRunning  ? "학습중" : '조는중', // text for title
            style: TextStyle(
              fontSize: 24,
              color: Colors.orangeAccent,
              fontFamily: 'Arial',
            ),
          ),
        ),

        // Create a button to pause/resume the timer
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20.0),
            icon: const Icon(Icons.restart_alt,
                color: Colors.orangeAccent, size: 30),
            onPressed: () {
              setState(() {
                _resetTimer();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: CameraPage(),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                      backgroundColor: Colors.black,
                      value: _time.inSeconds /
                          (_currMax *
                              60), // calculates the progress as a value between 0 and 1
                      strokeWidth: 2,
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 70,
                    child: Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 60,
                        color: Colors.orangeAccent,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 130,
                    child: Text(
                      timerState,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.orangeAccent,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_isRunning) {
              _stopTimer();
            } else {
              _startTimer();
            }
            _isRunning = !_isRunning;
          });
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        mini: false,
        child: _isRunning
            ? const Icon(Icons.pause, color: Colors.orangeAccent)
            : const Icon(Icons.play_arrow, color: Colors.orangeAccent),
      ),
    );
  }
}
