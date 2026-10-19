import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pro Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '0';
  bool isScientific = false;
  List<String> history = [];
  bool isDark = true;

  final List<List<String>> basicButtons = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['00', '0', '.', '='],
  ];

  final List<String> scientificButtons = [
    'sin', 'cos', 'tan', 'log',
    'ln', '√', 'x²', 'xʸ',
    '(', ')', 'π', 'e',
    '!', 'Rad', 'Deg', 'Inv'
  ];

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
      } else if (value == '⌫') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
          if (input.isEmpty) result = '0';
          else calculate(false);
        }
      } else if (value == '=') {
        calculate(true);
      } else {
        if (input.isNotEmpty && _isOperator(value) && _isOperator(input[input.length - 1])) {
          input = input.substring(0, input.length - 1) + value;
        } else {
          input += value;
        }
        calculate(false);
      }
    });
  }

  bool _isOperator(String s) => ['+', '−', '×', '÷', '%', 'xʸ', '^'].contains(s);

  void calculate(bool finalCalc) {
    if (input.isEmpty) return;
    try {
      String expr = input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('%', '/100')
          .replaceAll('x²', '^2')
          .replaceAll('xʸ', '^')
          .replaceAll('√', 'sqrt')
          .replaceAll('π', '${math.pi}')
          .replaceAll('e', '${math.e}');

      expr = expr.replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (m) {
        double val = double.tryParse(m.group(1)!) ?? 0;
        return math.sin(val * math.pi / 180).toString();
      });

      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        result = 'Error';
      } else {
        if (eval == eval.toInt()) {
          result = eval.toInt().toString();
        } else {
          result = eval.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        if (finalCalc) {
          history.insert(0, '$input = $result');
          if (history.length > 20) history.removeLast();
          input = result;
        }
      }
    } catch (e) {
      if (finalCalc) result = 'Error';
    }
  }

  Color getBtnColor(String btn) {
    if (btn == '=') return const Color(0xFFFF9F0A);
    if (['C', '⌫', '%', '÷', '×', '−', '+'].contains(btn)) return isDark ? const Color(0xFF505050) : const Color(0xFFE0E0E0);
    if (['sin','cos','tan','log','ln','√','x²','xʸ','(',')','π','e','!'].contains(btn)) return const Color(0xFF1C1C1E);
    return isDark ? const Color(0xFF2C2C2E) : Colors.white;
  }

  Color getTextColor(String btn) {
    if (btn == '=') return Colors.white;
    if (['C', '⌫', '%', '÷', '×', '−', '+'].contains(btn)) return isDark ? Colors.white : Colors.black;
    return isDark ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => setState(() => isDark = !isDark),
                      ),
                      const SizedBox(width: 8),
                      Text('PRO CALC', style: GoogleFonts.jetBrainsMono(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isScientific = !isScientific),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isScientific ? const Color(0xFFFF9F0A) : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(isScientific ? 'SCI' : 'STD',
                            style: TextStyle(color: isScientific ? Colors.white : (isDark ? Colors.white : Colors.black), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.history, color: isDark ? Colors.white54 : Colors.black54),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (_) => HistorySheet(history: history, isDark: isDark),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: isScientific ? 2 : 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        input.isEmpty ? '0' : input,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 28,
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        result,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: input.length > 15 ? 36 : 56,
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isScientific)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2.2, mainAxisSpacing: 8, crossAxisSpacing: 8),
                  itemCount: scientificButtons.length,
                  itemBuilder: (ctx, i) {
                    final btn = scientificButtons[i];
                    return _buildButton(btn, isSmall: true);
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE8E8EA),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: basicButtons.map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: row.map((btn) {
                        return Expanded(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _buildButton(btn),
                        ));
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, {bool isSmall = false}) {
    final isEqual = text == '=';
    return Material(
      color: getBtnColor(text),
      borderRadius: BorderRadius.circular(isSmall ? 12 : 20),
      elevation: isEqual ? 8 : 0,
      shadowColor: const Color(0xFFFF9F0A).withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(isSmall ? 12 : 20),
        onTap: () => onButtonPressed(text),
        child: Container(
          height: isSmall ? 44 : 72,
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 16 : 26,
              fontWeight: isEqual ? FontWeight.bold : FontWeight.w500,
              color: getTextColor(text),
            ),
          ),
        ),
      ),
    );
  }
}

class HistorySheet extends StatelessWidget {
  final List<String> history;
  final bool isDark;
  const HistorySheet({super.key, required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('السجل', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          Expanded(
            child: history.isEmpty
                ? Center(child: Text('لا يوجد سجل بعد', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)))
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white12 : Colors.black12),
                    itemBuilder: (_, i) => ListTile(
                      title: Text(history[i], style: GoogleFonts.jetBrainsMono(color: isDark ? Colors.white : Colors.black)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}