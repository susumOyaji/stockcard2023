import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




void main() async {
 runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Stock Data',
      theme: ThemeData(
        canvasColor: const Color.fromARGB(255, 10, 10, 10), // ベースカラーを変更する
      ),
      home: const _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({Key? key}) : super(key: key);

  @override
  _SimpleScreen createState() => _SimpleScreen();
}


class _SimpleScreen extends State<SimpleScreen>{

  // （1） Stateで管理する変数
  bool _loading = true;
  List<DateItem> _week = [];

  @override
  void initState() {
    super.initState();
    // （2） 初期化時にデータをロード
    _loadData();
  }
  // （3） データをロードする処理
  void _loadData() async{
    var res = await http.get(Uri.parse("http://192.168.1.1/list.json"),headers: {
      'Accept' : 'application/json'
    });

    setState(() {
      var json = jsonDecode(utf8.decode(res.bodyBytes));
      _loading = false;
      _week = json['items'].map<DateItem>((e) => DateItem.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('サンプル(1)'),
          actions: [
            // （4） リロード処理
            IconButton(onPressed: _loading? null :(){
              setState(() {
                _loading = true;
              });
              _loadData();
            }, icon: const Icon(Icons.refresh))
          ],
      ),
      // （5） 画面の表示
      body: Stack(
        children: [
          Column(
            children : _createListChildren(context),
          ),
          if(_loading)
            loadingWidget(context)
        ]
      ),
    );
  }

  // （6） Loading 画面を表示
  Widget loadingWidget(BuildContext context){
    return Container(
      : （省略）
    );
  }
  // （7） 5日分のColumnを表示
  Widget listWidget(BuildContext context){
    return Center(
      child: Column(
        children : _createListChildren(context)
      ),
    );
  }

  List<Widget> _createListChildren(BuildContext context){
    var _list = <Widget>[];
    for(var i = 0; i < _week.length; i++){
      DateItem item = _week[i];
      // （8） 週（月〜金）の1日を表示するウィジェット
      _list.add(DateBlock(item: item));
    }
    return _list;
  }
}

class SimpleScreen extends StatefulWidget{
  // : （省略）
}