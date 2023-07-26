import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Number Input Example')),
        body: NumberInputWidget(),
      ),
    );
  }
}

class NumberInputWidget extends StatefulWidget {
  @override
  _NumberInputWidgetState createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  int _selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onLongPress: () {
          _showNumberInputDialog(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Long Press to Open Number Input',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Selected Number: $_selectedValue',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Number Input Dialog'),
          content: Container(
            width: 200.0, // ここで幅を指定
            child: CupertinoPicker(
              itemExtent: 32.0, // 各アイテムの高さ
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedValue = index;
                });
              },
              children: List.generate(
                301,
                (index) => Center(
                  child: Text(
                    '$index',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
