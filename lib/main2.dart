import 'package:flutter/material.dart';

void main() => runApp(const MyApp());





class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Stock Data',
      theme: ThemeData(
        canvasColor: const Color.fromARGB(255, 10, 10, 10), // ベースカラーを変更する
      ),
      home: const _MyHomePage(),
    );
  }
}


class _MyHomePage extends StatefulWidget {
  const _MyHomePage({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyHomePage> {
  int selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Radio Button Sample'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildRadioTile(1, 'Option 1'),
              buildRadioTile(2, 'Option 2'),
              buildRadioTile(3, 'Option 3'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRadioTile(int value, String title) {
    return RadioListTile(
      value: value,
      groupValue: selectedValue,
      onChanged: (val) {
        setState(() {
          selectedValue = val as int;
        });
      },
      title: Text(title),
    );
  }
}
