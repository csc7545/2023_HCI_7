

import 'package:clean_dialog/clean_dialog.dart';
import 'package:emerge_alert_dialog/emerge_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hp/pages/camera.dart';
import 'package:hp/pages/rounded_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hp/utils/mlkit_utils.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'controller.dart';

class ReactiveController extends GetxController {
  RxInt counter = 0.obs;
  RxInt _timercnt = 0.obs;
  void increase(int time) {
    if(time % 10 == 0){
      counter++;
    }
  }
}

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
  bool _ischeck = false;
  Duration _time = const Duration(minutes: 60);
  Duration _break = const Duration(minutes: 10);
  Duration _checktime = const Duration(minutes: 10);
  int _timeInt = 60;
  int _counter = 1;
  int _sessionCount = 4;
  int _timerCount = 0;
  int _currMax = 60;
  Timer? _timer;
  SharedPreferences? _prefs;
  int _seconds = 0;
  bool _checktimer = false;
  late Timer _timecheck;
  final _isHours = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
    onStopped: () {
      print('onStop');
    },
    onEnded: () {
      print('onEnded');
    },
  );

  final _scrollController = ScrollController();

  final fController = Get.put(faceController());

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) =>
        print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    _stopWatchTimer.records.listen((value) => print('records $value'));
    _stopWatchTimer.fetchStopped
        .listen((value) => print('stopped from stream'));
    _stopWatchTimer.fetchEnded.listen((value) => print('ended from stream'));
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
                    SizedBox(width: 50),
                    // Add some horizontal spacing to align the text with the first message
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

  Future<void> _storeTime() async {
    String? curr = '';
    curr = _prefs?.getString('time');
    var now = new DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    String formattedDate = "${date.day}-${date.month}-${date.year}";
    await _prefs!.setString(
        'time', '$curr / ${_sessionCount * _timeInt} $formattedDate');
  }

  Future<void> _resetTime() async {
    await _prefs!.setString('time', '');
  }

  @override
  void dispose() async {
    _timer?.cancel();
    super.dispose();
    await _stopWatchTimer.dispose();
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
                          const SizedBox(width: 50),
                          // Add some horizontal spacing to align the text with the first message
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
            _storeTime();
            Navigator.pop(context);
          } else if (_sessionCount == _counter / 2) {
            showDialog(
              context: context,
              builder: (context) => CleanDialog(
                title: 'Error',
                content: 'We were not able to update your information.',
                backgroundColor: const Color(0XFFbe3a2c),
                titleTextStyle: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                contentTextStyle:
                const TextStyle(fontSize: 16, color: Colors.white),
                actions: [
                  CleanDialogActionButtons(
                    actionTitle: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                  CleanDialogActionButtons(
                    actionTitle: 'Try again',
                    textColor: const Color(0XFF27ae61),
                    onPressed: () {},
                  ),
                ],
              ),
            );
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

  void _startcheckTimer() {
    _checktimer = true;
    _timecheck = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  stopwatchtimer(){
    StreamBuilder<int>(
      stream: _stopWatchTimer.secondTime,
      initialData: _stopWatchTimer.secondTime.value,
      builder: (context, snap) {
        final value = snap.data;
        String strsec = value.toString();
        int sec = int.parse(strsec);
        if(sec % 10 ==0){
          _timerCount++;
          print("hhhhhh123121321321321321321313132132132132123:$_timerCount");
          print(sec);
          //_stopWatchTimer.onStopTimer();
        }
        if(sec == 20){
          print(_timerCount);
          _stopWatchTimer.onStopTimer();
        }
        print('Listen every second. $value');
        return Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'second',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontFamily: 'Helvetica',
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        value.toString(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 30,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ReactiveController());
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
              text: fController.isflag == true ? 'True' : 'False', // text for title
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
                        value: _time.inSeconds / (_currMax * 60),
                        // calculates the progress as a value between 0 and 1
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
                    Positioned(
                      bottom: 50,
                      left: 130,
                      child:
                      // fController.isflag == true ? Text('True') : Text('False'),
                      StreamBuilder<int>(
                        stream: _stopWatchTimer.secondTime,
                        initialData: _stopWatchTimer.secondTime.value,
                        builder: (context, snap) {
                          fController.isflag;
                          final value = snap.data;
                          String strsec = value.toString();
                          int sec = int.parse(strsec);

                          print(fController.isflag == true ? 'streamvuilder True' : 'streamvuilder False');

                          if(sec % 10 ==0){
                            _timerCount++;
                            print("hhhhhh123121321321321321321313132132132132123:$_timerCount");
                            print(sec);
                            //_stopWatchTimer.onStopTimer();
                          }
                          fController.isflag == false ? _stopWatchTimer.onStopTimer() : null;
                          print("end stop count ${_timerCount}");
                          // if(sec == 20){
                          //   print(_timerCount);
                          //   _stopWatchTimer.onStopTimer();
                          //
                          // }
                          print('Listen every second. $value');
                          return Container();
                           /* Column(
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          'second',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 17,
                                            fontFamily: 'Helvetica',
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          value.toString(),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 30,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          );*/

                        },
                      )
                           /* :Container() */
                ),
                    Positioned(
                      bottom: 150,
                      left: 130,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RoundedButton(
                          color: Colors.lightBlue,
                          onTap: _stopWatchTimer.onStartTimer,
                          child: const Text(
                            'Start',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          children: [
            TextButton(
              onPressed: () => _showMyDialog(context),
              child: const Text("Show PopUp"),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {

                  if (_isRunning) {
                    _stopTimer();
                  } else {
                    _startTimer();
                  }
                  _isRunning = !_isRunning;
                }
                  //if
                );
              },
              shape: const CircleBorder(),
              backgroundColor: Colors.black,
              mini: false,
              child: _isRunning
                  ? const Icon(Icons.pause, color: Colors.orangeAccent)
                  : const Icon(Icons.play_arrow, color: Colors.orangeAccent),
            ),
          ],
        ));
  }
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EmergeAlertDialog(
          alignment: Alignment.bottomRight,
          emergeAlertDialogOptions: EmergeAlertDialogOptions(
            title: const Text("Privacy Info"),
            content: _content(),
          ),
        );
      },
    );
  }

  Widget _content() {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset("assets/images/stretch.jpg"),
          const SizedBox(height: 22.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: size.height * 0.045,
                  width: size.width * 0.3,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                height: size.height * 0.045,
                width: size.width * 0.3,
                alignment: Alignment.center,
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

