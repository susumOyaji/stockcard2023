import 'package:flutter/material.dart';
import 'dart:developer';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('LayoutBuilder Example')),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400.0,
                maxHeight: 400.0,
              ),
              child: Container(
                color: Colors.blue,
                width: 300.0, // ConstrainedBoxによって幅が200に制限されます
                height: 300.0, // ConstrainedBoxによって高さが200に制限されます
              ),
            ),
          )),
    );
  }
}
