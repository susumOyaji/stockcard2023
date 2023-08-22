import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TimerExample(),
    );
  }
}

class TimerExample extends StatefulWidget {
  const TimerExample({super.key});

  @override
  _TimerExampleState createState() => _TimerExampleState();
}

class _TimerExampleState extends State<TimerExample> {
  late Timer _timer;
  late DateTime _startTime;
  late DateTime _endTime;
  final Duration _interval = const Duration(seconds: 1);
  late DateTime jstNow;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    // 現在の時刻を取得（GMT）
    DateTime now = DateTime.now().toUtc();

    // タイムゾーンをJSTに変更
    jstNow = now.add(const Duration(hours: 9));

    // 日本標準時のフォーマットを設定
    //var formatter = DateFormat('yyyy-MM-dd', 'ja_JP');

    // JSTの時刻をフォーマットして表示
    //formattedDate = formatter.format(jstNow);

    _startTime = DateTime(jstNow.year, jstNow.month, jstNow.day, 14, 45,
        0); //DateTime.now().subtract(Duration(minutes: 15));
    _endTime = DateTime(jstNow.year, jstNow.month, jstNow.day, 15, 0,
        0); //DateTime.now().add(Duration(hours: 2));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(_interval, (timer) {
      final now = _convertToJst(DateTime.now());

      if (now.isBefore(_endTime)) {
        print("Timer is running at ${now.toLocal()}");
      } else {
        timer.cancel();
        print("Timer stopped at ${now.toLocal()}");
      }
    });
  }

 DateTime _convertToJst(DateTime localTime) {
    return localTime.add(const Duration(hours: 9)); // UTC+9 (JST)
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
      body: const Center(
        child: Text('Timer is running...'),
      ),
    );
  }
}
