import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Dropdown List Example')),
        body: DropdownListWidget(),
      ),
    );
  }
}

class DropdownListWidget extends StatefulWidget {
  @override
  _DropdownListWidgetState createState() => _DropdownListWidgetState();
}

class _DropdownListWidgetState extends State<DropdownListWidget> {
  String _selectedItem = 'Option 1';
  List<String> _items = ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _showDropdownList(context);
            },
            child: Text('Open Dropdown'),
          ),
          SizedBox(height: 16.0),
          Text('Selected Item: $_selectedItem'),
        ],
      ),
    );
  }

  void _showDropdownList(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option'),
          content: DropdownButton<String>(
            value: _selectedItem,
            onChanged: (String? newValue) {
              setState(() {
                _selectedItem = newValue!;
              });
              Navigator.of(context).pop(); // ドロップダウンリストを閉じる
            },
            items: _items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ドロップダウンリストを閉じる
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
