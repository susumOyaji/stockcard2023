import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}





class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hoge"),
        ),
        body: Center(
          child: Text("Hoge"),
        ),
        floatingActionButton: _MyFloatingActionButton(),
      ),
    );
  }
}

class _MyFloatingActionButton extends StatefulWidget {
  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}






class _MyFloatingActionButtonState extends State<_MyFloatingActionButton> {
  bool _isMenuOpen = false;

  

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }


  

  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isMenuOpen) ...[
         
          //floatingActionButtonLocation: CustomFloatingActionButtonLocation(), // カスタム位置を指定
          //floatingActionButtonLocation: CustomizeFloatingLocation(FloatingActionButtonLocation.centerDocked, -90, -30),

          FloatingActionButton(
            onPressed: () {
              print("Pressed 1");
            },
            mini: true,
            child: Icon(Icons.add),
          ),
        ],
        if (_isMenuOpen) ...[
          FloatingActionButton(
            onPressed: () {
              print("Pressed 2");
            },
            mini: true,
            child: Icon(Icons.edit),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: () {
              print("Pressed 3");
            },
            mini: true,
            child: Icon(Icons.delete),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: () {
              print("Pressed 4");
            },
            mini: true,
            child: Icon(Icons.share),
          ),
        ],
        FloatingActionButton(
          onPressed: _toggleMenu,
          child: Icon(_isMenuOpen ? Icons.close : Icons.menu),
        ),
      ],
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // カスタム位置を指定するオフセットを返す
    return Offset(16.0, scaffoldGeometry.scaffoldSize.height - 16.0);
  }
}

class CustomizeFloatingLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX;
  double offsetY;
  CustomizeFloatingLocation(this.location, this.offsetX, this.offsetY);
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}