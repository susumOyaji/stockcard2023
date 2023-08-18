import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimerExample(),
    );
  }
}

class TimerExample extends StatefulWidget {
  @override
  _TimerExampleState createState() => _TimerExampleState();
}

class _TimerExampleState extends State<TimerExample> {
  late Timer _timer;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final Duration _interval = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay(hour: 14, minute: 17); // 開始時間を設定
    _endTime = TimeOfDay(hour: 15, minute: 0); // 終了時間を設定
    _startTimer();
  }

  void _startTimer() {
    final now = DateTime.now().toUtc().add(Duration(hours: 9)); // 現在の日本時間を取得
    final startDateTime = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
    final endDateTime = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);

    if (now.isBefore(endDateTime) && now.isAfter(startDateTime)) {
      final remainingTime = endDateTime.difference(now);

      
      _timer = Timer.periodic(_interval, (timer) {
        final currentTime = DateTime.now().toUtc().add(Duration(hours: 9)); // 現在の日本時間を取得
        if (currentTime.isBefore(endDateTime)) {
          print("Timer is running at ${currentTime.toLocal()}");
        } else {
          timer.cancel();
          print("Timer stopped at ${currentTime.toLocal()}");
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Start Time: ${_startTime.format(context)}'),
            Text('End Time: ${_endTime.format(context)}'),
          ],
        ),
      ),
    );
  }
}
