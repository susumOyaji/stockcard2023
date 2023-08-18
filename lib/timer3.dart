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
  final Duration _interval = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _startTime = const TimeOfDay(hour: 16, minute: 47); // 開始時間を設定
    _endTime = const TimeOfDay(hour: 17, minute: 00); // 終了時間を設定
    _startTimer();
  }

  void _startTimer() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 9)); // JSTに変換
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
      _timer = Timer.periodic(_interval, (timer) {
        final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9)); // JSTに変換
        if (currentTime.isBefore(endDateTime)) {
          print("Timer is running at ${currentTime.toLocal()}");
        } else {
          timer.cancel();
          print("Timer stopped at ${currentTime.toLocal()}");
        }
      });
    } else if (now.isBefore(startDateTime)) {
      var waitForStart = startDateTime.difference(now);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentDateTime = DateTime.now().toUtc().add(const Duration(hours: 9)); // JSTに変換
        if (currentDateTime.isAfter(startDateTime)) {
          _timer.cancel();
          print("Timer started at ${currentDateTime.toLocal()}");
          _startTimer(); // タイマーを開始
        } else {
          print("Waiting for start time... ${waitForStart.inSeconds} seconds remaining");
          waitForStart -= Duration(seconds: 1);
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
        title: const Text('Timer Example'),
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
