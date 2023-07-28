// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      // hide the debug banner
      debugShowCheckedModeBanner: false,
      title: "Kindacode.com",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _chosenDateTime;
  DateTime selectedTime = DateTime.now();

  // Show the modal that contains the CupertinoDatePicker
  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true, // 12時間表記を設定
                        initialDateTime: DateTime.now(),
                        minimumDate: DateTime(DateTime.now().year, 1, 1, 8, 0), // 最小時刻を8:00に設定
                        maximumDate:
                            DateTime(2023, 1, 1, 8, 10), // 表示する最大の時間を設定
                        onDateTimeChanged: (val) {
                          setState(() {
                            _chosenDateTime = val;
                          });
                        }),
                  ),

                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kindacode.com'),
        // This button triggers the _showDatePicker function
        trailing: CupertinoButton(
          padding: EdgeInsetsDirectional.zero,
          child: const Text('Show Picker'),
          onPressed: () => _showDatePicker(context),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Text(_chosenDateTime != null
              ? _chosenDateTime.toString()
              : 'No date time picked!'),
        ),
      ),
    );
  }
}
