import 'package:clockapp/constants.dart';
import 'package:clockapp/view_models/timer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  Icon iconTimerStart = new Icon(iconStart);
  Icon iconTimerPause = new Icon(iconCancel);
  Icon iconTimer;
  String timeInWidget;
  bool _startStop = false;
  TimerViewModelImpl viewModel;

  int _hours = 0, _minutes = 0, _seconds = 0;

  _MainPageState() {
    viewModel = TimerViewModelImpl(
        duration:
            Duration(hours: _hours, minutes: _minutes, seconds: _seconds));
  }

  @override
  initState() {
    iconTimer = iconTimerStart;
    super.initState();
    viewModel.timerStartStop.listen(_startStopTimer);
    viewModel.timerIsActive.listen(_setIconForButton);
    viewModel.timeIsOver.listen(informTimerFinished);
    viewModel.timeTillEndReadable.listen(secondChanger);
    WidgetsBinding.instance.addObserver(this);
  }



  void informTimerFinished(bool finished) {
    if (finished != null) {
      if (finished) {
        if (_notification == null) {
          makeNoise();
        } else {
          switch (_notification.index) {
            case 0: // resumed
              makeNoise();
              break;
            default:
              _showNotification();
              break;
          }
        }
      }
    }
  }

  void secondChanger(String timeString) {
    if (timeString != null) {
      setState(() {
        timeInWidget = timeString;
      });
    }
  }

  Future _showNotification() async {
    print('_showNotification');
  }

  void _setIconForButton(bool started) {
    if (started != null) {
      setState(() {
        if (started) {
          iconTimer = iconTimerPause;
        } else {
          iconTimer = iconTimerStart;
        }
      });
    }
  }

  void _startStopTimer(bool event) {
    if (event != null) {
      setState(() {
        if (event) {
          _startStop = true;
        } else {
          _startStop = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 30, top: 40),
            child: Text(
              widget.title,
              style: TextStyle(color: textColor, fontSize: 25),
            ),
          ),
          new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 250.0),
                child: Center(
                  child: new Text(
                    '$timeInWidget',
                    style: TextStyle(color: textColor,fontSize: 40),
                  ),
                ),
              ),
              SizedBox(
                height: 70,
              ),
              _startStop
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        NumberPicker.integer(
                            infiniteLoop: true,
                            initialValue: _hours,
                            minValue: 0,
                            maxValue: 99,
                            onChanged: (newValue) => setState(() {
                                  _hours = newValue;
                                  _setTime();
                                })),
                        NumberPicker.integer(
                            infiniteLoop: true,
                            initialValue: _minutes,
                            minValue: 0,
                            maxValue: 59,
                            onChanged: (newValue) => setState(() {
                                  _minutes = newValue;
                                  _setTime();
                                })),
                        NumberPicker.integer(
                            infiniteLoop: true,
                            initialValue: _seconds,
                            minValue: 0,
                            maxValue: 59,
                            onChanged: (newValue) => setState(() {
                                  _seconds = newValue;
                                  _setTime();
                                })),
                      ],
                    ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _startStop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: _stop,
                  icon: Icon(
                    iconStop,
                    color: iconStopColor,
                  ),
                ),
                FloatingActionButton(
                  child: iconTimer,
                  onPressed: _actionTimer,
                  tooltip: 'Start/Stop timer',
                ),
                IconButton(
                  onPressed: _stop,
                  icon: Icon(
                    iconStop,
                    color: iconStopColor,
                  ),
                ),
              ],
            )
          : FloatingActionButton(
              child: iconTimer,
              onPressed: _actionTimer,
              tooltip: 'Start/Stop timer',
            ),
    );
  }

  void _setTime() {
    var duration =
        Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
    viewModel.setTimeState(duration);
  }

  void _actionTimer() {
    var duration =
        Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
    viewModel.changeTimerState(duration);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      print("state changed to " + state.index.toString());
      _notification = state;
    });
  }

  void makeNoise() {
    //player.play(alarmAudioPath);
    print('zzzzzz');
  }

  void _stop() {
    viewModel.stop(context);
  }
}
