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
        title: Text('Vertical Scroll Example'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width, //150.0,
              height: 120.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey.shade800],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),

              //color: Colors.purple,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Please Watch to Comments: ",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'NotoSansJP',
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "moreHours",
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontFamily: 'NotoSansJP',
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width, //150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width, //150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 6',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 8',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 9',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: Center(
                child: Text(
                  'Container 10',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
