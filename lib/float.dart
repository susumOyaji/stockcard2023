import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          floatingActionButton: Column(
            verticalDirection: VerticalDirection.up, // childrenの先頭を下に配置
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor: Colors.redAccent,
                onPressed: () {
                  print("pressed");
                },
                mini: true, // 小さいサイズのFloatingActionButtonを表示
                chil:icon(add)''
              ),
              Container(
                // 余白のためContainerでラップ
                margin: EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.amberAccent,
                  onPressed: () {
                    print("pressed");
                  },
                  mini: true, // 小さいサイズのFloatingActionButtonを表示
                ),
              ),
              Container(
                // 余白のためContainerでラップ
                margin: EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.amberAccent,
                  onPressed: () {
                    print("pressed");
                  },
                  mini: true, // 小さいサイズのFloatingActionButtonを表示
                ),
              ),
              Container(
                // 余白のためContainerでラップ
                margin: EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.amberAccent,
                  onPressed: () {
                    print("pressed");
                  },
                  mini: true, // 小さいサイズのFloatingActionButtonを表示
                ),
              ),
            ],
          ),
          appBar: AppBar(
            title: Text("Hoge"),
          ),
          body: Text("Hoge")),
    );
  }
}
