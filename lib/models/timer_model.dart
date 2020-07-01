import 'package:flutter/material.dart';

abstract class TimerViewModel {
  Stream<bool> get timerIsActive;
  Stream<String> get timeTillEndReadable;
  Stream<bool> get timeIsOver;
  Stream<bool> get timerStartStop;
  void changeTimerState(Duration duration);
  void setTimeState(Duration duration);
  void stop(BuildContext context);
}
