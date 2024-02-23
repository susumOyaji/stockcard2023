import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp10());
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
        title: const Text('Vertical Scroll Example'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width, //150.0,
              height: 120.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey.shade800],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)
                    //topRight: Radius.circular(10),
                    //bottomRight: Radius.circular(10),
                    ),
              ),

              //color: Colors.purple,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
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
                          style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'NotoSansJP',
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "moreHours",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'NotoSansJP',
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "moreHours",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'NotoSansJP',
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width, //150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width, //150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
              margin: const EdgeInsets.all(8.0),
              width: 150.0,
              height: 150.0,
              color: Colors.purple,
              child: const Center(
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
