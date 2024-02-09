import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Center Widget Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Center Widget Example'),
        ),
        body: const SafeArea(
          child: Center(
            // Centerウィジェットが親ウィジェットの中央に配置される
            child: Column(
              //Columnの場合は垂直方向は中央に配置されるわけではありません。
              //全てのウィジットが中央に重なってしまうので配置位置を明示的に指定する必要があります。
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(
                '1st.Hello, World!',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '2nd.Hello, World!',
                style: TextStyle(fontSize: 24),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
