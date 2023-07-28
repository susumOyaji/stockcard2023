import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Time Picker Example')),
        body: TimePickerWidget(),
      ),
    );
  }
}

class TimePickerWidget extends StatefulWidget {
  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  int _selectedMinute = 0;
  int _selectedSecond = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _showTimePicker(context);
        },
        child: Text('Select Time'),
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index;
                        });
                      },
                      children: List.generate(60, (index) => Center(child: Text('$index'))),
                    ),
                  ),
                  Text('Minute'),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedSecond = index;
                        });
                      },
                      children: List.generate(60, (index) => Center(child: Text('$index'))),
                    ),
                  ),
                  Text('Second'),
                ],
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 選択された分と秒を表示
                  print('Selected Time: $_selectedMinute minutes $_selectedSecond seconds');
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
