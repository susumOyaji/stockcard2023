import 'package:flutter/material.dart';
import 'dart:developer';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexible Sizing',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flexible Sizing Example'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width*0.99),
                      height: MediaQuery.of(context).size.width * 0.3,
                      color: Colors.black,
                      child: Center(
                          child: Text('Flexible Width',
                              style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width * 0.05,))),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width*0.99),
                      height: MediaQuery.of(context).size.width * 0.3,
                      color: Colors.black,
                      child: Center(
                          child: Text('Flexible Width',
                              style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width * 0.05,))),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.01,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.green,
                  child: Center(child: Text('Flexible Size')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
