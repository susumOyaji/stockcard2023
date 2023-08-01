import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'Clipper.dart';
//import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() async {
  setupWindow(); // サイズを設定
  runApp(const MyApp());
}

// サイズを固定
const double windowWidth = 700;
const double windowHeight = 1000;

// サイズを設定するメソッド
void setupWindow() {
  // webとプラットフォームをチェック
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    //setWindowTitle('sample');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  final formatter = NumberFormat('#,###');
  EdgeInsets stdmargin =
      const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0);

  Future<List<Map<String, dynamic>>>? returnMap;
  List<Map<String, dynamic>> stockdataList = [];

  String formattedDate = "";
  String moreHours = "";

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();

  bool _isMenuOpen = false;

  /*
  static List<Map<String, dynamic>> stockdata = [
    {"Code": "6758", "Shares": 200, "Unitprice": 1665},
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

    //print('JST: $formattedJST');

    //DateTime now = DateTime.now();
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
    } else if (jstNow.hour >= openTime.hour && jstNow.hour < closeTime.hour) {
      result =
          'The Market Closes in ${remainingTime.inHours}hour ${remainingTime.inMinutes % 60}minutes';
    } else if (jstNow.hour >= closeTime.hour) {
      result =
          'The tomorrowMarket Starts in ${remainingTimeTomorrow.inHours % 24}hour and ${remainingTimeTomorrow.inMinutes % 60}minutes';
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
      return MediaQuery.of(context).size.height * 0.2;
    }
  }

  double _getFontSize(BuildContext context) {
    // スマートフォンの場合は画面幅の5%、タブレットの場合は画面幅の3%をフォントサイズとして返す
    if (MediaQuery.of(context).size.shortestSide < 600) {
      return MediaQuery.of(context).size.width * 0.05;
    } else {
      return MediaQuery.of(context).size.width * 0.03;
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
        print(stockdataList);
        print("All data has been loaded.");
      });
    } else {
      setState(() {
        print("Non LoadData");
      });
    }
  }

  Future<List<Map<String, dynamic>>> webfetch() async {
    List<Map<String, dynamic>> dataList = [];
    const djiurl = 'https://finance.yahoo.co.jp/quote/%5EDJI';
    //final djiresponse = await _fetchStd(djiurl);

    final uri = Uri.parse(djiurl); // バックエンドのURLをURIオブジェクトに変換
    final djiresponse = await http.get(uri);
    final djibody = parser.parse(djiresponse.body);

    final djispanElements = djibody.querySelectorAll('span');
    final djispanTexts =
        djispanElements.map((spanElement) => spanElement.text).toList();

    String djifirstChar = djispanTexts[23].substring(0, 1);
    String djipolarity = djifirstChar == '-' ? '-' : '+';

    Map<String, dynamic> djimapString = {
      "Code": "^DJI",
      "Name": "^DJI",
      "Price": djispanTexts[17],
      "Reshio": djispanTexts[22],
      "Percent": djispanTexts[27],
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

    final nkspanElements = nkbody.querySelectorAll('span');
    final nkspanTexts =
        nkspanElements.map((spanElement) => spanElement.text).toList();

    String nkfirstChar = nkspanTexts[23].substring(0, 1);
    String nkpolarity = nkfirstChar == '-' ? '-' : '+';

    Map<String, dynamic> nkmapString = {
      "Code": "NIKKEI",
      "Name": "NIKKEI",
      "Price": nkspanTexts[16],
      "Reshio": nkspanTexts[23],
      "Percent": nkspanTexts[26],
      "Polarity": nkpolarity,
      "Banefits": "Unused",
      "Evaluation": "Unused"
    };
    // オブジェクトをリストに追加
    dataList.add(nkmapString);

    for (int i = 0; i < stockdataList.length; i++) {
      print(stockdataList[i]["Code"]);
      final anyurl =
          'https://finance.yahoo.co.jp/quote/${stockdataList[i]["Code"]}.T';
      //final bodyresponse = await _fetchStd(url);

      final anyuri = Uri.parse(anyurl); // バックエンドのURLをURIオブジェクトに変換
      final anyresponse = await http.get(anyuri);

      final body = parser.parse(anyresponse.body);
      final h1Elements = body.querySelectorAll('h1');
      final h1Texts = h1Elements.map((h1Element) => h1Element.text).toList();

      final spanElements = body.querySelectorAll('span');
      final spanTexts =
          spanElements.map((spanElement) => spanElement.text).toList();

      // <dd>タグの3階層下にある<span>タグを検出 Reshio
      final ddTags = body.querySelectorAll('dd');
      final ddElements = ddTags.map((ddElement) => ddElement.text).toList();
      int delimiterIndex = ddElements[0].indexOf("(");
      final ddElement = ddElements[0].substring(0, delimiterIndex);

      String anyfirstChar = spanTexts[28].substring(0, 1);
      String anypolarity = anyfirstChar == '-' ? '-' : '+';

      int intHolding = stockdataList[i]["Shares"];
      String price = spanTexts[21].replaceAll('.', '');

      int intPrice =
          (price) == '---' ? 0 : int.parse(price.replaceAll(',', ''));

      num banefits = intPrice - stockdataList[i]["Unitprice"];
      String bBanefits = formatter.format(banefits); //banefits.toString();

      int evaluation = intHolding * intPrice;
      String eEvaluation =
          formatter.format(evaluation); //evaluation.toString();

      Map<String, dynamic> mapString = {
        "Code": spanTexts[22],
        "Name": h1Texts[1],
        "Price": spanTexts[21],
        "Reshio": ddElement, // spanTexts[29],
        "Percent": spanTexts[31],
        "Polarity": anypolarity,
        "Banefits": bBanefits,
        "Evaluation": eEvaluation
      };

      // オブジェクトをリストに追加
      dataList.add(mapString);
      //print(dataList);
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
                // TODO: 入力されたテキストの処理
                print('ButtonName: $enteredText');
                print('Entered Text 2: $enteredText2');

                setState(() {
                  stocknewData = {
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
          ],
        );
      },
    );
  }

  Future<void> addData(Map<String, dynamic> stocknewData) async {
    // IDの重複チェック
    bool isDuplicateId = false;
    int newId = stocknewData["Code"];
    for (Map<String, dynamic> existingData in stockdataList) {
      int existingId = existingData["Code"];
      if (existingId == newId) {
        isDuplicateId = true;
        break;
      }
    }

    if (!isDuplicateId) {
      // 新しいデータを追加
      stockdataList.add(stocknewData);

      // IDで昇順ソート
      stockdataList.sort((a, b) => (a["Code"]).compareTo(b["Code"]));

      await saveData();
      setState(() {
        print('Data added and sorted successfully.');
      });
    } else {
      setState(() {
        print(
            'Data with the same ID already exists. Duplicate registration prevented.');
      });
    }
  }

  void updateStockData(Map<String, dynamic> newData) async {
    for (int i = 0; i < stockdataList.length; i++) {
      if (stockdataList[i]['Code'] == newData['Code']) {
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

                setState(() {
                  stocknewData = {
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
                    saveData();
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

  int _refreshTime = 60;
  Timer? _refreshTimer;
  @override
  void initState() {
    super.initState();

    //moreHours = getFormattedOpentime();
    //deleteData();
    loadData();
    _refreshData();

    _refreshSetup(_refreshTime);
    //Timer.periodic(Duration(seconds: _refreshTime), (Timer timer) {
    //60秒ごとに呼び出されるメソッド
    //  _refreshData();
    //});
  }

  void _refreshSetup(int time) {
    // タイマーをキャンセルしてリフレッシュを停止
    _refreshTimer?.cancel();
    setState(() {
      _refreshTime = time;
      print("_refreshSetup$time");
    });
    _refreshTimer =
        Timer.periodic(Duration(seconds: _refreshTime), (Timer timer) {
      //time秒ごとに呼び出されるメソッド

      _refreshData();
    });
  }

  void _refreshData() {
    setState(() {
      print("_refreshData");
      returnMap = webfetch();
      moreHours = getFormattedOpentime();
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
    print("isMenuOpen:  $_isMenuOpen");
  }

  Container stackmarketView(stdstock) => Container(
      padding: const EdgeInsets.only(top: 10.0),
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
          Icons.trending_up,
          size: 42,
          color: Colors.grey,
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: <Widget>[
              CircleAvatar(
                maxRadius: 5.0,
                backgroundColor:
                    stdstock[0]['Polarity'] == '+' ? Colors.red : Colors.green,
              ),
              const Text(
                "Dow Price: \$ ",
                style: TextStyle(
                  fontSize: 15.0,
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
                        fontSize: 15.0, //fontWeight: FontWeight.bold,
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
                  fontSize: 15.0,
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
                        fontSize: 15.0,
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
                backgroundColor:
                    stdstock[1]["Polarity"] == '+' ? Colors.red : Colors.green,
              ),
              const Text(
                "Nikkey Price: ￥ ",
                style: TextStyle(
                  fontSize: 15.0,
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
                        fontSize: 15.0,
                        fontFamily: 'NotoSansJP',
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent, //fontWeight: FontWeight.bold,
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
                fontSize: 15.0,
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
                      fontSize: 15.0,
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
                              : Colors.green,
                        ),
                        const Text(
                          "Market price: ",
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
                          "Profit(Gains)",
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "￥",
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
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
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
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
              ],
            ),
            Positioned(
              right: 18.0,
              top: 10.0,
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
              margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
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
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      fixedSize: const Size(50, 50),
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
                          fontSize: 15.0,
                          color: Colors.black,
                          fontFamily: 'NotoSansJP',
                        )),
                  ),
                ),

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
                          fontSize: 18.0,
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
                                  fontSize: 17.0,
                                  color: Colors.blue),
                              textAlign: TextAlign.left),
                          Text(
                            "Benefits: ${anystock[index]["Banefits"]}",
                            style: const TextStyle(
                                fontFamily: 'NoteSansJP',
                                //fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                color: Colors.yellow),
                          ),
                        ],
                      ),
                      Text(
                        "Evaluation: ${anystock[index]["Evaluation"]}",
                        style: const TextStyle(
                            fontFamily: 'NoteSansJP',
                            //fontWeight: FontWeight.bold,
                            fontSize: 17.0,
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
                        fixedSize: const Size(100, 50),
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
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      onPressed: () => _refreshData(), //_opneUrl(),
                    ), // 右端のアイコン
                  ),
                ),
              ])),
        );
      });

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
                _toggleMenu();
                _refreshSetup(1);
              },
              mini: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // 角丸の半径を指定
              ),
              child: const Text("1Sec"), //Icon(Icons.add),
            ),
          ],
          if (_isMenuOpen) ...[
            FloatingActionButton(
              onPressed: () {
                _toggleMenu();
                _refreshSetup(10);
              },
              mini: true,
              child: const Text("10S"), //Icon(Icons.edit),
            ),
            //SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: () {
                _toggleMenu();
                _refreshSetup(60);
              },
              mini: true,
              child: const Text("60S"), //Icon(Icons.delete),
            ),
            //SizedBox(height: 16.0),
            FloatingActionButton(
              onPressed: () {
                _toggleMenu();
                setState(() {
                  _refreshTime = 300;
                });
              },
              mini: true,
              child: const Text("5M"), //Icon(Icons.share),
            ),
            FloatingActionButton(
              onPressed: () {
                _toggleMenu();
                setState(() {
                  _refreshTime = 3600;
                });
              },
              mini: true,
              child: const Text("10M"), //Icon(Icons.close),
            ),
          ],
          Tooltip(
            message: _refreshTime.toString(),
            child: ClipOval(
              child: Material(
                color: Colors.orange, // button color
                child: InkWell(
                  splashColor: Colors.red, // inkwell color
                  child: const SizedBox(
                      width: 45, height: 45, child: Icon(Icons.autorenew)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: returnMap,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            List<Map<String, dynamic>> stockDataList = snapshot.data!;

            var stdstock = stockDataList;
            var anystock = stockDataList.sublist(2);
            var asset = getAsset(anystock);
            return //Column(
                //children: <Widget>[
                Container(
              //width: 280,
              margin: const EdgeInsets.all(0.0),
              width: _getContainerWidth(context),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Stack(
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
                                        top: 0.0,
                                        left: 20.0,
                                        right: 0.0,
                                        bottom: 10.0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                              //),
                              Container(
                                margin: stdmargin,
                                //width: 500,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                ),
                                child: stackmarketView(stdstock),
                              ),
                              Container(
                                margin: stdmargin,
                                //width: 500,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                ),
                                child: stackAssetView(asset),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(
                                      top: 10.0, right: 0.0, bottom: 0.0),
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black,
                                        Colors.grey.shade800,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Please Watch to Comments: $moreHours",
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'NotoSansJP',
                                          //fontWeight: FontWeight.w900,
                                          color: Colors.yellowAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                margin: stdmargin,
                                //width: 500,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                ),
                                child: listView(anystock),
                              ),
                            ]),
                      )),
                  Positioned(
                    right: 100.0,
                    top: 20.0,
                    child: Text(
                        "  $formattedDate" /*+ '  ' + now.month.toString()*/,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold)),
                  ),
                  _buildFloatingActionButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
