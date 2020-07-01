import 'dart:async';
import 'package:clockapp/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clockapp/models/timer_model.dart';

class TimerViewModelImpl implements TimerViewModel {
  static const oneSec = const Duration(seconds: 1);
  final Duration duration;
  Stream<DateTime> _timer;
  StreamController<String> _timeFormatted =
      StreamController<String>.broadcast();
  StreamController<bool> _timerStartStop;
  StreamController<bool> _timerStateActive;
  StreamController<bool> _timerIsEnded;
  StreamSubscription _timeSubscription;

  TimerViewModelImpl({this.duration}) {
    _timerStartStop = StreamController();
    _timerStartStop.add(false);
    _timerStateActive = StreamController();
    _timerStateActive.add(false);
    _timerIsEnded = new StreamController();
    _timeFormatted = new StreamController();
    _timeFormatted.add(duration.toString().split('.').first.padLeft(8, "0"));

  }

  DateTime get time =>
      new DateTime.fromMicrosecondsSinceEpoch(duration.inMicroseconds);

  static Stream<DateTime> timedCounter(Duration interval, Duration maxCount) {
    StreamController<DateTime> controller;
    Timer timer;
    DateTime counter =
        new DateTime.fromMicrosecondsSinceEpoch(maxCount.inMicroseconds);

    void tick(_) {
      counter = counter.subtract(oneSec);
      controller.add(counter); // Ask stream to send counter values as event.
      if (counter.millisecondsSinceEpoch == 0) {
        timer.cancel();
        controller.close(); // Ask stream to shut down and tell listeners.
      }
    }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
      }
    }

    controller = StreamController<DateTime>(
        onListen: startTimer,
        onPause: stopTimer,
        onResume: startTimer,
        onCancel: stopTimer);

    return controller.stream;
  }

  void _onTimeChange(DateTime newTime) {
    var _duration = Duration(microseconds: newTime.microsecondsSinceEpoch);
    _timeFormatted.add(_duration.toString().split('.').first.padLeft(8, "0"));
  }

  void _handleTimerEnd() {
    _timerStartStop.add(false);
    _timerIsEnded.add(true);
    _timerStateActive.add(false);
    _timeSubscription = null;
  }

  @override
  Stream<bool> get timeIsOver => _timerIsEnded.stream;

  @override
  void changeTimerState(Duration duration) {
    if (duration.inMicroseconds != 0) {
      if (_timeSubscription == null) {
        _timer = timedCounter(oneSec, duration);
        _timerStartStop.add(true);
        _timerIsEnded.add(false);
        _timerStateActive.add(true);
        _timeSubscription = _timer.listen(_onTimeChange);
        _timeSubscription.onDone(_handleTimerEnd);
      } else {
        if (_timeSubscription.isPaused) {
          _timeSubscription.resume();
          _timerStateActive.add(true);
        } else {
          _timeSubscription.pause();
          _timerStateActive.add(false);
        }
      }
    }
  }

  @override
  Stream<bool> get timerIsActive {
    return _timerStateActive.stream;
  }

  @override
  Stream<String> get timeTillEndReadable => _timeFormatted.stream;

  @override
  void setTimeState(Duration duration) {
    _timeFormatted.add(duration.toString().split('.').first.padLeft(8, "0"));
  }

  @override
  Stream<bool> get timerStartStop {
    return _timerStartStop.stream;
  }

  @override
  void stop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage(title: 'Timer app')),
    );
  }
}
