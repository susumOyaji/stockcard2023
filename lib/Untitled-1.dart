import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp9());
}

class MyApp9 extends StatelessWidget {
  const MyApp9({Key? key}) : super(key: key);
  //const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // デザインの基になるデバイスサイズを設定（単位：dp）
      designSize: const Size(392, 829),
      builder: (context , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: child,
        );
      },
      child: const MyHomePage(title: 'flutter_screenutil'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 300.w,
                      height: 100.h,
                      color: Colors.purple,
                    ),
                    Container(
                      width: 300.w,
                      height: 100.h,
                      color: Colors.purple,
                    ),
                    Container(
                      width: 300.w,
                      height: 100.h,
                      color: Colors.purple,
                    ),
                    Text(
                      'flutter_screenutilパッケージ表示テスト！同じように表示されます。',
                      style: TextStyle(
                        fontSize: 20.sp,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                          300.w,
                          50.h,
                        ),
                      ),
                      child: Text(
                        'Button',
                        style: TextStyle(
                          fontSize: 30.sp,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



