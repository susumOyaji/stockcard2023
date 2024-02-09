import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockcard2023/clipper.dart';
//import 'clipper.dart';

import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:developer';

void main() async {
  //setupWindow(); // サイズを設定
  runApp(const MyApp());
}

// サイズを固定
const double windowWidth = 750;
const double windowHeight = 1000;

// サイズを設定するメソッド
void setupWindow() {
  // webとプラットフォームをチェック
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    //setWindowTitle('sample');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));

    /*
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });*/
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // "DEBUG"を非表示にする
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  final formatter = NumberFormat('#,###');
  EdgeInsets stdmargin =
      const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0);

  Future<List<Map<String, dynamic>>>? returnMap;
  List<Map<String, dynamic>> stockdataList = [];
  int autoid = 0;

  String formattedDate = "";
  String moreHours = "";

  final TextEditingController _textEditingControllerId =
      TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();

  bool _isMenuOpen = false;

  String _refreshTimeString = ""; //_refreshTime.toString();

  late int _refreshTime;
  late Timer? _refreshTimer;
  late bool _refreshTimerCancelled;
  late int _backupTime;
  //late Timer? _backupTimer;
  /*
  static List<Map<String, dynamic>> stockdata = [
    {"Code": "6758", "Shares": 200, "Unitprice": 1665},
    {"Code": "6758", "Shares": 41, "Unitprice": 12944},
    {"Code": "6976", "Shares": 100, "Unitprice": 1801},
    {"Code": "3436", "Shares": 0, "Unitprice": 0},
  ];
  */

  String getFormattedOpentime() {
    String result = "";
    initializeDateFormatting();

    // 現在の時刻を取得（GMT）
    DateTime now = DateTime.now().toUtc();

    // タイムゾーンをJSTに変更
    DateTime jstNow = now.add(const Duration(hours: 9));

    // 日本標準時のフォーマットを設定
    var formatter = DateFormat('yyyy-MM-dd', 'ja_JP');

    // JSTの時刻をフォーマットして表示
    formattedDate = formatter.format(jstNow);

    // 9:00までの時間差を計算
    DateTime openTime =
        DateTime(jstNow.year, jstNow.month, jstNow.day, 9, 0, 0);
    // 15:00までの時間差を計算
    DateTime closeTime =
        DateTime(jstNow.year, jstNow.month, jstNow.day, 15, 0, 0);

    DateTime jstNowTime = DateTime(jstNow.year, jstNow.month, jstNow.day,
        jstNow.hour, jstNow.minute, jstNow.second);

    Duration remainingOpenTime = openTime.difference(jstNowTime);
    Duration remainingTime = closeTime.difference(jstNowTime);

    DateTime tomorrow = jstNow.add(const Duration(days: 1));
    DateTime tomorrowTargetTime =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0, 0);

    Duration remainingTimeTomorrow = tomorrowTargetTime.difference(jstNowTime);

    if (jstNow.hour < openTime.hour) {
      result =
          'The todayMarket Starts in ${remainingOpenTime.inHours % 24}hour and ${remainingOpenTime.inMinutes % 60}minutes more';

      if (_refreshTimer != null && _refreshTimerCancelled == false) {
        setState(() {
          // タイマーをキャンセルしてリフレッシュを停止
          _refreshTimer?.cancel();
          _refreshTimerCancelled = true;
          _refreshTimeString =
              "The timer is currently stopped as the market for today has not started yet.";
        });
      }
    } else if (jstNow.hour >= openTime.hour && jstNow.hour < closeTime.hour) {
      result =
          'The Market Closes in ${remainingTime.inHours}hour ${remainingTime.inMinutes % 60}minutes';

      if (_refreshTimerCancelled == true) {
        _refreshSetup(_refreshTime);
        _refreshTimerCancelled = false;
      }
    } else if (jstNow.hour >= closeTime.hour) {
      result =
          'The tomorrowMarket Starts in ${remainingTimeTomorrow.inHours % 24}hour and ${remainingTimeTomorrow.inMinutes % 60}minutes';

      if (_refreshTimer != null && _refreshTimerCancelled == false) {
        setState(() {
          // タイマーをキャンセルしてリフレッシュを停止
          _refreshTimer?.cancel();
          _refreshTimerCancelled = true;
          _refreshTimeString =
              "The timer is currently stopped as the market for today is closed.";
        });
      }
    }

    return result;
  }

  double _getContainerWidth(BuildContext context) {
    // スマートフォンの場合は画面幅の70%、タブレットの場合は画面幅の50%を返す
    if (MediaQuery.of(context).size.shortestSide < 600) {
      return MediaQuery.of(context).size.width * 0.7;
    } else {
      return MediaQuery.of(context).size.width * 0.99;
    }
  }

  double _getContainerHeight(BuildContext context) {
    // スマートフォンの場合は画面高さの30%、タブレットの場合は画面高さの20%を返す
    if (MediaQuery.of(context).size.shortestSide < 600) {
      return MediaQuery.of(context).size.height * 0.3;
    } else {
      return MediaQuery.of(context).size.height * 0.99;
    }
  }

  double _getFontSize(BuildContext context) {
    // スマートフォンの場合は画面幅の5%、タブレットの場合は画面幅の3%をフォントサイズとして返す
    if (MediaQuery.of(context).size.shortestSide < 600) {
      return MediaQuery.of(context).size.width * 0.05;
    } else {
      return MediaQuery.of(context).size.width * 0.04;
    }
  }

  Future<void> loadData() async {
    setState(() {
      stockdataList = []; //Load Data to init
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('stockdataList');
    if (encodedData != null) {
      List<dynamic> decodedData = jsonDecode(encodedData);

      setState(() {
        stockdataList = decodedData.cast<Map<String, dynamic>>();
        // デコードされたリストの要素数を取得
        autoid = decodedData.length;
        //print(stockdataList);
        log('$stockdataList');
        log("All data has been loaded.");
      });
    } else {
      setState(() {
        log("Non LoadData");
      });
    }
  }

  Future<List<Map<String, dynamic>>> webfetch() async {
    List<Map<String, dynamic>> dataList = [];
    List<String> elementsList = [];
    List<String> nkelementsList = [];
    List<String> fxelementsList = [];
    String spanementsCode = "";
    const djiurl = 'https://finance.yahoo.co.jp/quote/%5EDJI';
    //final djiresponse = await _fetchStd(djiurl);
    //ネットワークの許可:
    //macOSアプリがインターネットにアクセスできるように、macos/Runner/DebugProfile.entitlements ファイルに以下の設定を追加します：
    //<key>com.apple.security.network.client</key>
    //<true/>
    //このファイルが存在しない場合は、プロジェクトの macos/Runner ディレクトリに作成してください。

    final uri = Uri.parse(djiurl); // バックエンドのURLをURIオブジェクトに変換
    final djiresponse = await http.get(uri);
    final djibody = parser.parse(djiresponse.body);

    //final djispanElements = djibody.querySelectorAll('span');
    djibody.querySelectorAll("span._3BGK5SVf").forEach((element) {
      //print(element.text);
      elementsList.add(element.text);
    });

    double number = double.parse(elementsList[1]);
    String djipolarity = number < 0 ? '-' : '+';

    Map<String, dynamic> djimapString = {
      "Code": "^DJI",
      "Name": "^DJI",
      "Price": elementsList[0],
      "Reshio": elementsList[1],
      "Percent": "${elementsList[2]}%",
      "Polarity": djipolarity,
      "Banefits": "Unused",
      "Evaluation": "Unused"
    };
    // オブジェクトをリストに追加
    dataList.add(djimapString);

    const nkurl = 'https://finance.yahoo.co.jp/quote/998407.O';

    //final nkresponse = await _fetchStd(nkurl);
    final nkuri = Uri.parse(nkurl); // バックエンドのURLをURIオブジェクトに変換
    final nkresponse = await http.get(nkuri);
    final nkbody = parser.parse(nkresponse.body);

    //final nkspanElements = nkbody.querySelectorAll('span');
    nkbody.querySelectorAll("span._3wVTceYe").forEach((element) {
      //print(element.text);
      nkelementsList.add(element.text);
    });

    number = double.parse(nkelementsList[1]);
    String nkpolarity = number < 0 ? '-' : '+';

    Map<String, dynamic> nkmapString = {
      "Code": "NIKKEI",
      "Name": "NIKKEI",
      "Price": nkelementsList[0],
      "Reshio": nkelementsList[1],
      "Percent": "${nkelementsList[2]}%",
      "Polarity": nkpolarity,
      "Banefits": "Unused",
      "Evaluation": "Unused"
    };
    // オブジェクトをリストに追加
    dataList.add(nkmapString);

    //Exchange Dollar Yen
    const exchangeurl = 'https://finance.yahoo.co.jp/quote/USDJPY=FX';
    //const exchangeurl = 'https://fx.minkabu.jp/pair';
    final exchangeuri = Uri.parse(exchangeurl); // バックエンドのURLをURIオブジェクトに変換
    final exchageresponse = await http.get(exchangeuri);

    final body = parser.parse(exchageresponse.body);

    //<span class="_FxPriceBoardMain__price_1hfca_33">147<!-- -->.<span class="_FxPriceBoardMain__highlight_1hfca_41">80</span>7</span>
    //<span class="_FxPriceBoardMain__price_1w4it_33">149<!-- -->.<span class="_FxPriceBoardMain__highlight_1w4it_41">03</span>4</span>
    //<dt class="_FxPriceBoardMain__term_1w4it_26">Bid(売値)</dt>

    body.querySelectorAll("dd").forEach((element) {
      //log(element.text);
      fxelementsList.add(element.text);
    });
    //body
    //     .querySelectorAll("span._FxPriceBoardMain__price_1hfca_33")
    //     .forEach((element) {
    //log(element.text);
    //fxelementsList.add(element.text);
    // });

    //final spanTexts =
    //    spanElements.map((spanElement) => spanElement.text).toList();
    Map<String, dynamic> exchangemapString = {
      "Code": "Exchange",
      "Name": "Exchange",
      "Price": "Unused",
      "Reshio": "Unused",
      "Percent": "Unused",
      "Polarity": "Unused",
      "Banefits": "Unused",
      "Evaluation": "Unused",
      "Bid": fxelementsList.isEmpty ? "Rewriting" : fxelementsList[0],
      "Ask": fxelementsList.isEmpty ? "Rewriting" : fxelementsList[1],
      "Change": fxelementsList.isEmpty ? "Rewriting" : fxelementsList[2]
    };
    // オブジェクトをリストに追加
    dataList.add(exchangemapString);

    for (int i = 0; i < stockdataList.length; i++) {
      log((stockdataList[i]["Id"]).toString());
      log((stockdataList[i]["Code"]).toString());
      final anyurl =
          'https://finance.yahoo.co.jp/quote/${stockdataList[i]["Code"]}.T';
      //final bodyresponse = await _fetchStd(url);

      final anyuri = Uri.parse(anyurl); // バックエンドのURLをURIオブジェクトに変換
      final anyresponse = await http.get(anyuri);

      final body = parser.parse(anyresponse.body);
      final h1Elements = body.querySelectorAll('h2');
      final h1Texts =
          h1Elements.map((h1Element) => h1Element.text).toList(); //企業名

      //final spanElements = body.querySelectorAll('span');
      body.querySelectorAll("span._2wsoPtI7").forEach((element) {
        //Code
        spanementsCode = (element.text);
      });

      List<String> spanementsList = [];

      body.querySelectorAll("span._3rXWJKZF").forEach((element) {
        //log("p: ${element.text}");
        spanementsList.add(element.text);
      });

      String anyfirstChar = spanementsList[2].substring(0, 1);
      String anypolarity = anyfirstChar == '-' ? '-' : '+';

      int intHolding = stockdataList[i]["Shares"];
      String price = spanementsList[0].replaceAll('.', '');

      int intPrice =
          (price) == '---' ? 0 : int.parse(price.replaceAll(',', ''));

      num banefits = intPrice - stockdataList[i]["Unitprice"];
      String bBanefits = formatter.format(banefits); //banefits.toString();

      int evaluation = intHolding * intPrice;
      String eEvaluation =
          formatter.format(evaluation); //evaluation.toString();

      Map<String, dynamic> mapString = {
        "Code": spanementsCode,
        "Name": h1Texts[1],
        "Price": spanementsList[0], //spanTexts[21],
        "Reshio": spanementsList[1], //ddElement, // spanTexts[29],
        "Percent": spanementsList[2], //spanTexts[31],
        "Polarity": anypolarity,
        "Banefits": bBanefits,
        "Evaluation": eEvaluation
      };

      // オブジェクトをリストに追加
      dataList.add(mapString);
    }
    return dataList;
  }

  Map<String, String> getAsset(List<Map<String, dynamic>> anystock) {
    num intinvestment = 0; //投資額
    int intEvaluation = 0;
    final formatter = NumberFormat('#,###');

    for (var i = 0; i < anystock.length; i++) {
      intinvestment = intinvestment +
          (stockdataList[i]["Shares"] * stockdataList[i]["Unitprice"]);
    }

    String investment = formatter.format(intinvestment);

    for (int i = 0; i < anystock.length; i++) {
      intEvaluation = intEvaluation +
          int.parse(anystock[i]['Evaluation']!.replaceAll(',', ''));
    }
    String evaluation = formatter.format(intEvaluation);
    String profit = formatter.format(intEvaluation - intinvestment);
    String polarity = (intEvaluation - intinvestment) >= 0 ? "+" : "-";

    Map<String, String> mapString = {
      "Market": evaluation,
      "Invest": investment,
      "Profit": profit,
      "Polarity": polarity,
    };

    return mapString;
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(stockdataList);
    await prefs.setString('stockdataList', encodedData);
    setState(() {
      //Comment = "On saveData";
    });
  }

  handleButtonLongPress() {
    Map<String, dynamic> stocknewData = {};

    // ここにボタンが押されたときの処理を追加する
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Button was Longpressed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingControllerId,
                decoration: const InputDecoration(hintText: 'Id'),
              ),
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(hintText: 'Code'),
              ),
              TextField(
                controller: _textEditingController2,
                decoration: const InputDecoration(hintText: 'Shares'),
              ),
              TextField(
                controller: _textEditingController3,
                decoration: const InputDecoration(hintText: 'Unitprice'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                String enteredText = _textEditingController.text;
                String enteredText2 = _textEditingController2.text;
                String enteredText3 = _textEditingController3.text;
                //ＴＯＤＯ：入力されたテキストの処理
                log('ButtonName: $enteredText');
                log('Entered Text 2: $enteredText2');

                setState(() {
                  stocknewData = {
                    'Id': autoid,
                    'Code': int.parse(enteredText),
                    'Shares': int.parse(enteredText2),
                    'Unitprice': int.parse(enteredText3)
                  };
                });
                addData(stocknewData);
                //loadData();

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Anser'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addData(Map<String, dynamic> stocknewData) async {
    // IDの重複チェック
    bool isDuplicateId = false;
    int newId = stocknewData["Code"];

    //stockdataList.add(stocknewData);

    // IDで昇順ソート
    //stockdataList.sort((a, b) => (a["Code"]).compareTo(b["Code"]));

    //await saveData();

    //log('Data added and sorted successfully.');

    for (Map<String, dynamic> existingData in stockdataList) {
      int existingId = existingData["Code"];
      if (existingId == newId) {
        isDuplicateId = true;
        break;
      }
    }

    //if (!isDuplicateId) {
    // 新しいデータを追加
    stockdataList.add(stocknewData);

    // IDで昇順ソート
    stockdataList.sort((a, b) => (a["Code"]).compareTo(b["Code"]));

    await saveData();

    log('Data added and sorted successfully.');
    //} else {
    // データが重複している場合のアラート表示
    //  log('Data with the same ID already exists. Duplicate registration prevented.');

    // }
  }

  Future<bool> showDuplicateDataAlert() async {
    bool userConfirmed = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('重複データ'),
          content: const Text('同じIDを持つデータが既に存在します。重複登録はできません。続行しますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                userConfirmed = true;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );

    return userConfirmed;
  }

  void showFirstAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('First Alert'),
          content: const Text('This is the first alert.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the first alert
                showSecondAlert(context); // Show the second alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSecondAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Second Alert'),
          content: const Text('This is the second alert.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the second alert
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void updateStockData(Map<String, dynamic> newData) async {
    for (int i = 0; i < stockdataList.length; i++) {
      if (stockdataList[i]['Id'] == newData['Id']) {
        stockdataList[i] = newData;
        saveData();
        break;
      }
    }
  }

  void editDialog(index) async {
    Map<String, dynamic> stocknewData = {};

    // ここにボタンが押されたときの処理を追加する
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _textEditingControllerId.text = stockdataList[index]['Id'].toString();
        _textEditingController.text = stockdataList[index]['Code'].toString();
        _textEditingController2.text =
            stockdataList[index]['Shares'].toString();
        _textEditingController3.text =
            stockdataList[index]['Unitprice'].toString();

        return AlertDialog(
          title: const Text('Button was Longpressed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingControllerId,
                decoration: const InputDecoration(hintText: 'Id'),
              ),
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(hintText: 'Code'),
              ),
              TextField(
                controller: _textEditingController2,
                decoration: const InputDecoration(hintText: 'Shares'),
              ),
              TextField(
                controller: _textEditingController3,
                decoration: const InputDecoration(hintText: 'Unitprice'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                String enteredTextId = _textEditingControllerId.text;
                String enteredText = _textEditingController.text;
                String enteredText2 = _textEditingController2.text;
                String enteredText3 = _textEditingController3.text;

                setState(() {
                  stocknewData = {
                    'Id': int.parse(enteredTextId),
                    'Code': int.parse(enteredText),
                    'Shares': int.parse(enteredText2),
                    'Unitprice': int.parse(enteredText3)
                  };
                });
                updateStockData(stocknewData);
                //addData(stocknewData);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeData(int index) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('AlertDialog Title'),
            content: const Text('This is the content of the AlertDialog.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    stockdataList.removeAt(index);
                    log(stockdataList[index].toString());
                    //saveData();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> deleteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Remove data for the 'data' key.
    await prefs.remove('stockdataList');
  }

  @override
  void initState() {
    super.initState();

    //deleteData();
    _refreshTime = 60;
    _refreshTimerCancelled = false;
    _backupTime = 60;

    loadData();
    _refreshData();
    _refreshSetup(_refreshTime);
    _refreshMoreHours();
  }

  void _refreshSetup(int time) {
    setState(() {
      _refreshTime = time;
      _refreshTimeString = _refreshTime.toString();
      log("_refreshSetup$time");
    });
    _refreshTimer =
        Timer.periodic(Duration(seconds: _refreshTime), (Timer timer) {
      //time秒ごとに呼び出されるメソッド
      _refreshData();
    });

    Timer.periodic(Duration(seconds: _backupTime), (Timer timer) {
      //time秒ごとに呼び出されるメソッド
      _refreshMoreHours();
    });
  }

  void _refreshData() {
    setState(() {
      log("_refreshData");
      returnMap = webfetch();
    });
  }

  void _refreshMoreHours() {
    setState(() {
      log("_refreshMoreHours");
      moreHours = getFormattedOpentime();
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
    log("isMenuOpen:  $_isMenuOpen");
  }

  Stack stacktitle() => Stack(children: [
        ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            //margin: EdgeInsets.only(top: 0.0, right: 0.0),
            padding: const EdgeInsets.only(
                top: 0.0, left: 20.0, right: 0.0, bottom: 10.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey,
                  Colors.grey.shade800,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Stocks",
                    style: TextStyle(
                      fontSize: _getFontSize(context),
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                      "  $formattedDate" /*+ '  ' + now.month.toString()*/,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 1.0,
          right: 5.5,
          child: Row(
            children: [
              _buildFloatingActionButton(),
            ],
          ),
        ),
      ]);

  Widget _buildFloatingActionButton() {
    return Row(
      //verticalDirection: VerticalDirection.down,
      //mainAxisSize: MainAxisSize.min,
      children: [
        if (_isMenuOpen) ...[
          InkWell(
            onTap: () {
              log('ClipOval tapped!');
              _toggleMenu();
              _refreshSetup(1);
            },
            child: ClipOval(
              child: Container(
                width: 44,
                height: 44,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '1s',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15, fontWeight: FontWeight.w700, // 太字に設定
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_isMenuOpen) ...[
          ClipOval(
            child: Material(
              color: Colors.grey, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: const SizedBox(
                    width: 45, height: 45, child: Icon(Icons.timer_10_sharp)),
                onTap: () {
                  _toggleMenu();
                  _refreshSetup(10);
                },
              ),
            ),
          ),
          InkWell(
            onTap: () {
              log('ClipOval tapped!');
              _toggleMenu();
              _refreshSetup(60);
            },
            child: ClipOval(
              child: Container(
                width: 45,
                height: 45,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '60s',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15, fontWeight: FontWeight.w700, // 太字に設定
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              log('ClipOval tapped!');
              _toggleMenu();
              _refreshSetup(300);
            },
            child: ClipOval(
              child: Container(
                width: 45,
                height: 45,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '5m',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15, fontWeight: FontWeight.w700, // 太字に設定
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              log('ClipOval tapped!');
              _toggleMenu();
              _refreshSetup(3600);
            },
            child: ClipOval(
              child: Container(
                width: 45,
                height: 45,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    '10m',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15, fontWeight: FontWeight.w700, // 太字に設定
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        Tooltip(
          message: _refreshTimeString,
          //height: 150, // ツールチップの高さを調整
          //padding: const EdgeInsets.symmetric(horizontal: 50), // ツールチップ内の余白を調整
          child: ClipOval(
            child: Material(
              color: Colors.orange, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: const SizedBox(
                    width: 35, height: 35, child: Icon(Icons.autorenew)),
                onTap: () {
                  _refreshData();
                },
                onLongPress: () {
                  _toggleMenu();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container stackmarketView(stdstock) => Container(
      padding: const EdgeInsets.only(top: 10.0, right: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.grey.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 56, 50, 50),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // 垂直方向の配置方法
          children: [
            const Icon(
              Icons.trending_up,
              size: 42,
              color: Colors.grey,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 5.0,
                    backgroundColor: stdstock[0]['Polarity'] == '+'
                        ? Colors.red
                        : Colors.green,
                  ),
                  const Text(
                    "Dow Price: \$ ",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${stdstock[0]['Price']}',
                          style: const TextStyle(
                            fontSize: 12.0, //fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w900,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  const SizedBox(width: 10),
                  const Text(
                    "          The day before ratio: \$ ",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${stdstock[0]['Reshio'] + "   " + stdstock[0]["Percent"]}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: stdstock[0]["Polarity"] == '+'
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 10),

              Row(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 5.0,
                    backgroundColor: stdstock[1]["Polarity"] == '+'
                        ? Colors.red
                        : Colors.green,
                  ),
                  const Text(
                    "Nikkey Price: ￥ ",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${stdstock[1]["Price"]}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w900,
                            color: Colors
                                .blueAccent, //fontWeight: FontWeight.bold,
                          ),
                          //style: TextStyle(fontSize: 12.0,//fontWeight: FontWeight.bold,
                          //),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(children: <Widget>[
                const SizedBox(width: 10),
                const Text(
                  "          The day before ratio: ￥ ",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${stdstock[1]["Reshio"] + "  " + stdstock[1]["Percent"]}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: stdstock[1]["Polarity"] == '+'
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          ]));

  Container stackAssetView(asset) => Container(
        padding: const EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.grey.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 56, 50, 50),
        ),
        child: Stack(
          // Stackを追加
          alignment: Alignment.centerLeft, // 子要素の配置を左揃えに設定
          children: [
            Row(
              children: [
                const Icon(
                  Icons.currency_yen,
                  size: 42,
                  color: Colors.grey,
                ),
                Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text.rich(
                      TextSpan(
                        text: 'Market capitalization',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          maxRadius: 5.0,
                          backgroundColor: asset["Polarity"] == "+"
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const Text(
                          "Market price: ",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${asset["Market"]}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: asset["Polarity"] == "+"
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 10),
                        const Text(
                          "Profit(Gains)",
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "￥",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                              ),
                              TextSpan(
                                text: '${asset["Profit"]}',
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Investment",
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "￥",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                              ),
                              TextSpan(
                                text: '${asset["Invest"]}',
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: IconButton(
                icon: const Icon(Icons.grain),
                color: Colors.blueGrey,
                iconSize: 40,
                onPressed: () {
                  handleButtonLongPress();
                },
              ),
            ),
          ],
        ),
      );

  Container stackAssetView1(asset) => Container(
        padding: const EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.grey.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 56, 50, 50),
        ),
        child: Row(children: [
          const Icon(
            Icons.currency_yen,
            size: 42,
            color: Colors.grey,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text.rich(
                TextSpan(
                  text: 'Market capitalization',
                  style: TextStyle(
                    fontSize: 35.0,
                    color: Colors.grey,
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 5.0,
                    backgroundColor: asset["Polarity"] == "+"
                        ? Colors.orange
                        : Colors.green, //Colors.green,
                  ),
                  const Text(
                    "Market price: ", //"Gain or loss",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${asset["Market"]}',
                          style: TextStyle(
                            fontSize: 24.0,
                            color: asset["Polarity"] == "+"
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  const SizedBox(width: 10),
                  const Text(
                    "Profit(Gains)", //"Gain or loss", //"Market price",
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "￥",
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        TextSpan(
                          text: '${asset["Profit"]}',
                          style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Investment",
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "￥",
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        TextSpan(
                          text: '${asset["Invest"]}',
                          style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      );

  ListView listView(dynamic anystock) => ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: anystock.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
              width: (MediaQuery.of(context).size.width),
              margin: const EdgeInsets.only(top: 10.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.grey.shade800,
                  ],
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(children: <Widget>[
                //Expanded(
                //  flex: 2,
                //child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    fixedSize: const Size(30, 30),
                    backgroundColor: Colors.purple, //ボタンの背景色
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    editDialog(index);
                    //loadData();
                    _refreshData();
                  },
                  onLongPress: () {
                    removeData(index);
                    //loadData();
                    _refreshData();
                  },
                  child: Text("${anystock[index]['Code']}",
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontFamily: 'NotoSansJP',
                      )),
                ),
                //),

                //  ]
                // ),

                //SizedBox(width: 15.0,),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${anystock[index]["Name"]}",
                        style: const TextStyle(
                          fontSize: 15.0,
                          color: Colors.grey,
                          //fontFamily: 'NoteSansJP',
                          //fontWeight: FontWeight.bold,
                        ),
                        strutStyle: const StrutStyle(
                          fontSize: 10.0,
                          height: 1.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Market: ${anystock[index]["Price"]}",
                              style: const TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: 12.0,
                                  color: Colors.blue),
                              textAlign: TextAlign.left),
                          Text(
                            "Benefits: ${anystock[index]["Banefits"]}",
                            style: const TextStyle(
                                fontFamily: 'NoteSansJP',
                                //fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                color: Colors.yellow),
                          ),
                        ],
                      ),
                      Text(
                        "Evaluation: ${anystock[index]["Evaluation"]}",
                        style: const TextStyle(
                            fontFamily: 'NoteSansJP',
                            //fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                //SizedBox(width: 50.0,),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 0.0, right: 0.0, bottom: 0.0, left: 0.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(50, 20),
                        backgroundColor: anystock[index]["Polarity"] == '+'
                            ? Colors.red
                            : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        anystock[index]["Reshio"],
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      onPressed: () => _refreshData(), //_opneUrl(),
                    ), // 右端のアイコン
                  ),
                ),
              ])),
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: returnMap,
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else {
              List<Map<String, dynamic>> stockDataList = snapshot.data ?? [];
              var stdstock = stockDataList.sublist(0, 3);
              var anystock = stockDataList.sublist(3);
              var asset = getAsset(anystock);

              return Container(
                  
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      stacktitle(),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        height: MediaQuery.of(context).size.height * 0.10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                        child: stackmarketView(stdstock),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        height: MediaQuery.of(context).size.height * 0.10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                        child: stackAssetView(asset),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        //padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.grey.shade800],
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Please Watch to Comments: ",
                              style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'NotoSansJP',
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                moreHours,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'NotoSansJP',
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black,
                          ),
                          child: listView(anystock),
                        ),
                      ),
                    ],
                  ),
                
              );
            }
          },
        ),
      ),
    );
  }
}
