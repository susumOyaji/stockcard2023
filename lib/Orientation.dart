import 'package:flutter/material.dart';

class OrientationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orientation Demo'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.portrait,
            size: 100,
            color: Colors.blue,
          ),
          Text(
            'Portrait Mode',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape,
            size: 100,
            color: Colors.green,
          ),
          Text(
            'Landscape Mode',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrientationDemo(),
  ));
}
