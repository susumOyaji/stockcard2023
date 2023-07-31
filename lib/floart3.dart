import 'package:flutter/material.dart';
import 'Clipper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      top: 13.0, // 下からの距離を調整
      right: 6.0, // 右からの距離を調整
      child: Column(
        verticalDirection: VerticalDirection.down,
        //mainAxisSize: MainAxisSize.min,
        children: [
          if (_isMenuOpen) ...[
            FloatingActionButton(
              onPressed: () {
                print("Pressed 1");
                _toggleMenu();
              },
              mini: true,
              child: const Text("1S"),//Icon(Icons.add),
            ),
          ],
          if (_isMenuOpen) ...[
            FloatingActionButton(
              onPressed: () {
                print("Pressed 2");
                _toggleMenu();
              },
              mini: true,
              child: Icon(Icons.edit),
            ),
            //SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: () {
                print("Pressed 3");
                _toggleMenu();
              },
              mini: true,
              child: Icon(Icons.delete),
            ),
            //SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: () {
                print("Pressed 4");
                _toggleMenu();
              },
              mini: true,
              child: Icon(Icons.share),
            ),
            FloatingActionButton(
              onPressed: () {
                print("Pressed 4");
                _toggleMenu();
              },
              mini: true,
              child: Icon(Icons.close),
            ),
          ],

          ClipOval(
            child: Material(
              color: Colors.orange, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: const SizedBox(
                    width: 45, height: 45, child: Icon(Icons.autorenew)),
                onTap: () {
                  //_refreshData();
                },
                onLongPress: () {
                  _toggleMenu();
                },
              ),
            ),
          ),

          //FloatingActionButton(
          //  onPressed: _toggleMenu,
          //  child: Icon(_isMenuOpen ? Icons.close : Icons.menu),
          //),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //floatingActionButton: _buildFloatingActionButton(),
        //floatingActionButtonLocation:
        //    FloatingActionButtonLocation.endTop, // カスタム位置を指定
        body: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //GestureDetector(
                ClipPath(
                  clipper: MyCustomClipper(),
                  child: Container(
                      //margin: EdgeInsets.only(top: 0.0, right: 0.0),
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 20.0, right: 0.0, bottom: 10.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.grey.shade800,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Stocks",
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
        _buildFloatingActionButton(),
      ],
    ));
  }
}
