import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 変更通知を行うためのModel（ChangeNotifier）
class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 変更を通知
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider( // ChangeNotifierProviderでモデルを提供
        create: (context) => CounterModel(),
        child: const CounterScreen(),
      ),
    );
  }
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final counterModel = Provider.of<CounterModel>(context); // モデルを取得

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChangeNotifier Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Count:',
            ),
            Consumer<CounterModel>( // Consumerでモデルの変更を受け取る
              builder: (context, model, child) {
                return Text(
                  '${model.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterModel.increment(); // ボタンを押すとモデルの変更通知が行われる
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
