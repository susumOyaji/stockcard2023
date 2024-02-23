import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp8());
}

class MyApp8 extends StatelessWidget {
  const MyApp8({Key? key}) : super(key: key);
  //const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive App'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Welcome to Responsive Flutter App!',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: constraints.maxWidth * 0.8,
                    height: 200,
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        'Responsive Container',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 100,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 100,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 100,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
