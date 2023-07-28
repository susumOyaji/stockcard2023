// main.dart
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
                    child: CupertinoPicker(
                      itemExtent: 32.0, // 各アイテムの高さ
                      onSelectedItemChanged: (index) {
                        // 選択された分や秒が変更されたときの処理
                        // indexには選択されたアイテムのインデックスが格納されています
                      },
                      children: [
                        // 分の選択肢（0から59まで）
                        for (var minute = 0; minute < 10; minute++)
                          Center(
                            child: Text(
                              '$minute',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        // セパレータ（:）
                        const Center(
                          child: Text(
                            ':',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        // 秒の選択肢（0から59まで）
                        for (var second = 0; second < 60; second++)
                          Center(
                            child: Text(
                              '$second',
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                      ],
                    ),
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
