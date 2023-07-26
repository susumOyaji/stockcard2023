import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Number Input Example')),
        body: PickerPage(),
      ),
    );
  }
}

const List<String> colors = <String>[
  'Red',
  'Yellow',
  'Amber',
  'Blue',
  'Black',
  'Pink',
  'Purple',
  'White',
  'Grey',
  'Green',
];

class PickerPage extends StatefulWidget {
   const PickerPage({Key? key}) : super(key: key);

  @override
  _PickerPageState createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
  int _selectedIndex = 0;
  int _selectedHour = 0, _selectedMinute = 0;
  int _changedNumber = 0, _selectedNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupertino Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              "Normal Cupertino Picker",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Row(
              children: <Widget>[
                CupertinoButton(
                    child: Text("Select Color :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                  },
                                  children: List<Widget>.generate(colors.length,
                                      (int index) {
                                    return Center(
                                      child: Text(colors[index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  colors[_selectedIndex],
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
            const Text(
              "MutiSelect Cupertino Picker",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Row(
              children: <Widget>[
                CupertinoButton(
                    child: Text("Select Time:"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              color: Colors.white,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: CupertinoPicker(
                                        scrollController:
                                            FixedExtentScrollController(
                                          initialItem: _selectedHour,
                                        ),
                                        itemExtent: 32.0,
                                        backgroundColor: Colors.white,
                                        onSelectedItemChanged: (int index) {
                                          setState(() {
                                            _selectedHour = index;
                                          });
                                        },
                                        children: List<Widget>.generate(24,
                                            (int index) {
                                          return Center(
                                            child: Text('${index + 1}'),
                                          );
                                        })),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                        scrollController:
                                            FixedExtentScrollController(
                                          initialItem: _selectedMinute,
                                        ),
                                        itemExtent: 32.0,
                                        backgroundColor: Colors.white,
                                        onSelectedItemChanged: (int index) {
                                          setState(() {
                                            _selectedMinute = index;
                                          });
                                        },
                                        children: List<Widget>.generate(60,
                                            (int index) {
                                          return Center(
                                            child: Text('${index + 1}'),
                                          );
                                        })),
                                  ),
                                ],
                              ),
                            );
                          });
                    }),
                Text(
                  '${_selectedHour + 1}:${_selectedMinute + 1}',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            Text(
              "Cupertino Picker with Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Row(
              children: <Widget>[
                CupertinoButton(
                    child: Text("Select Number :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              color: Colors.white,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CupertinoButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                        scrollController:
                                            FixedExtentScrollController(
                                          initialItem: _selectedNumber,
                                        ),
                                        itemExtent: 32.0,
                                        backgroundColor: Colors.white,
                                        onSelectedItemChanged: (int index) {
                                          _changedNumber = index;
                                        },
                                        children: List<Widget>.generate(100,
                                            (int index) {
                                          return Center(
                                            child: Text('${index + 1}'),
                                          );
                                        })),
                                  ),
                                  CupertinoButton(
                                    child: Text("Ok"),
                                    onPressed: () {
                                      setState(() {
                                        _selectedNumber = _changedNumber;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          });
                    }),
                Text(
                  '${_selectedNumber + 1}',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
