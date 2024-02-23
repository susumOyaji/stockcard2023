import 'package:flutter/material.dart';

void main() {
  runApp(MyApp10());
}

class MyApp10 extends StatelessWidget {
  const MyApp10({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertical Scroll Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vertical Scroll Example'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: List.generate(
            10,
            (index) => Container(
              margin: const EdgeInsets.all(8.0),
              width: (MediaQuery.of(context).size.width),
              height: 120.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container $index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
