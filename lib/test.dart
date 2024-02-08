import 'package:flutter/material.dart';

class ExampleWidget extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Example'),
    ),
    body: SafeArea(
      // SafeAreaはデバイスの安全な領域にウィジェットを配置します
      child: Center(
        child: Container(
          // Containerはレイアウトの状態を管理し、ウィジェットをデコレーションするための便利なウィジェットです
          color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
              //Expandedは親のウィジェット内のスペースを最大限に使用します
              child:
              Container(
                //height: 100,
                color: Colors.red,
                child: const Center(
                  child: Text(
                    'Expanded Widget',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ),
              Container(
                height: 100,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Container Widget',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
  
 
void main() {
  runApp(MaterialApp(
    home: ExampleWidget(),
  ));
}
