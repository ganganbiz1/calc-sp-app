import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'キャラ電卓',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with SingleTickerProviderStateMixin {
  String _display = '0';
  String _input = '';
  String _lastResult = '';

  // アニメーション用
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  bool _isHandDown = false;

  // 電卓ボタンのラベル
  final List<String> _buttons = [
    '7', '8', '9', '÷',
    '4', '5', '6', '×',
    '1', '2', '3', '-',
    '0', 'C', '=', '+',
  ];

  @override
  void initState() {
    super.initState();
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _handAnimation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String value) {
    // 手を下げるアニメーション
    _handController.forward().then((_) {
      _handController.reverse();
    });
    setState(() {
      if (value == 'C') {
        _input = '';
        _display = '0';
        _lastResult = '';
      } else if (value == '=') {
        try {
          String expression = _input
              .replaceAll('×', '*')
              .replaceAll('÷', '/');
          double result = _calculateExpression(expression);
          _display = result.toString().replaceAll(RegExp(r'\.0+$'), '');
          _lastResult = _display;
          _input = '';
        } catch (e) {
          _display = 'Error';
          _input = '';
        }
      } else {
        if (_display == '0' || _display == 'Error') {
          _display = '';
        }
        _input += value;
        _display += value;
      }
    });
  }

  double _calculateExpression(String expr) {
    List<String> tokens = [];
    String num = '';
    for (int i = 0; i < expr.length; i++) {
      String c = expr[i];
      if ('0123456789.'.contains(c)) {
        num += c;
      } else if ('+-*/'.contains(c)) {
        if (num.isNotEmpty) {
          tokens.add(num);
          num = '';
        }
        tokens.add(c);
      }
    }
    if (num.isNotEmpty) tokens.add(num);
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double res = tokens[i] == '*' ? left * right : left / right;
        tokens[i - 1] = res.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i--;
      }
    }
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double val = double.parse(tokens[i + 1]);
      if (op == '+') result += val;
      if (op == '-') result -= val;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('キャラ電卓'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // ディスプレイ
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              _display,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // キャラクター（仮: 円＋手アニメーション）
          SizedBox(
            height: 120,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 手（左）
                  AnimatedBuilder(
                    animation: _handAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: 0,
                        top: 40 + _handAnimation.value,
                        child: Container(
                          width: 16,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  // キャラ本体
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'キャラ',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  // 手（右）
                  AnimatedBuilder(
                    animation: _handAnimation,
                    builder: (context, child) {
                      return Positioned(
                        right: 0,
                        top: 40 + _handAnimation.value,
                        child: Container(
                          width: 16,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // ボタンエリア
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: _buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () => _onButtonPressed(_buttons[index]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      textStyle: const TextStyle(fontSize: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(_buttons[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
