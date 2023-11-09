import 'package:flutter/material.dart';
import 'package:calculator_app/calcButton.dart';
import 'package:math_expressions/math_expressions.dart';

List<Tips> tipsList = [];
class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {

  final TextEditingController _expressionTEC = TextEditingController();
  final TextEditingController _tipTEC = TextEditingController();

  String equation = "0";
  String result = "0";
  String expression = "";
  String total = '0';
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  buttonPressed(String buttonText) {
    // used to check if the result contains a decimal
    String doesContainDecimal(dynamic result) {
      if (result.toString().contains('.')) {
        List<String> splitDecimal = result.toString().split('.');
        if (!(int.parse(splitDecimal[1]) > 0)) {
          return result = splitDecimal[0].toString();
        }
      }
      return result;
    }

    String toDecimal(String percentage) {
      if (percentage.contains('.')) {
        return percentage;
      }
      String numberString = percentage.replaceAll('%', '').trim();
      int length = numberString.length;
      if (length <= 2) {
        numberString = numberString.padLeft(3, '0');
        length = numberString.length;
      }
      String decimalString = numberString.substring(0, length - 2) + '.' + numberString.substring(length - 2);

      return decimalString;
    }

    setState(() { 
      if (buttonText == 'Clear') {
        equation = '0';
        result = '0';
        _expressionTEC.text = '';
        _tipTEC.text = '';
        total = '0';
      } else if (buttonText.contains('15%')) {
        _tipTEC.text = '15';
      } else if (buttonText.contains('20%')) {
        _tipTEC.text = '20';
      } else if (buttonText.contains('25%')) {
        _tipTEC.text = '25';
      } else if (buttonText.contains('=')) {
        var _exp = _expressionTEC.text; // balance
        var _customTip = _tipTEC.text; // custom tip
        equation = '%$_customTip';
        String computation = '*' + toDecimal(equation);
        expression = _exp + computation; // final computation

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          if (expression.contains('%')) {
            result = doesContainDecimal(result);
          }
        } catch (e) {
          result = "Error";
        }
        // add information into drawer for the history
        Tips temp = Tips(_exp, equation, result);
        tipsList.add(temp);
        equation = '0';
        total = temp.calculateTotal().toString();
        
      } else {
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color.fromARGB(255, 134, 177, 127),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 253, 208),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.blue),
          onPressed: () {
            if (scaffoldKey.currentState!.isDrawerOpen) {
              scaffoldKey.currentState!.closeDrawer();
                       //close drawer, if drawer is open
            } else {
              scaffoldKey.currentState!.openDrawer();
                       //open drawer, if drawer is closed
            }
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(top: 18.0),
            child: Text('Tip Calculator',style: TextStyle(color: Color.fromARGB(255, 255, 253, 208))),
            ),
            SizedBox(width: 20),
        ], 
      ),
      drawer: Drawer (
        child: ListView(
          children: [
            ListTile(
              title: const Text ('Tip History'),
              onTap: () {},
            ),
            Container (
              height: double.maxFinite,
              child: ListView.builder(
                itemCount: tipsList.length,
                itemBuilder: (context, i) {
                  return  ListTile (
                    title: Text(tipsList[i].toString())
                  );
                }
              )
            )  
          ]
        )
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Container(
              width: 300,
              height: 50,
              child: TextField(
                controller: _expressionTEC, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                scrollPadding: const EdgeInsets.all(0),
                cursorColor: Colors.white,
                decoration: 
                  const InputDecoration(
                    prefixIcon: Icon(Icons.attach_money_outlined),
                    hintText: 'Enter Subtotal',
                    border: OutlineInputBorder(),
                  ),
              ),
            ),
            Container(
              width: 190,
              height: 90,
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _tipTEC, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // need to parse information from this
                scrollPadding: const EdgeInsets.all(0),
                decoration: 
                  const InputDecoration(
                    prefixIcon: Icon(Icons.percent),
                    hintText: 'Custom Tip',
                    border: OutlineInputBorder(),
                  ),
              ),
            ),
          
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 32,
              runSpacing: 64,
              children: [
                calcButton('25%', Color.fromARGB(255, 255, 253, 208), () => buttonPressed('25%')),
                calcButton('20%', Color.fromARGB(255, 255, 253, 208), () => buttonPressed('20%')),
                calcButton("15%", Color.fromARGB(255, 255, 253, 208), () => buttonPressed('15%')),
              ],
            ),
            const SizedBox(height:10),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 32,
              runSpacing: 64,
              children: [
                calcButton('=', Colors.green, () => buttonPressed('=')),
                calcButton('Clear', Colors.green, () => buttonPressed('Clear')), // on press make exp = '0';
              ],
            ),
            const SizedBox(height: 30),
            Container(),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 32,
              runSpacing: 64,
              children: [
                Container(
                  child: Text('Tip:', style: const TextStyle(color: Colors.black, fontSize: 40))
                ),
                Container(
                  if (double.tryParse(result) != null) {
                    child: Text(((double.parse(result)*10.round())/10).toString(), style: const TextStyle(color: Colors.black, fontSize: 40))
                  } else {
                    child: Text((result).toString(), style: const TextStyle(color: Colors.black, fontSize: 40))
                  }
                  
                )
              ],
            ),
            const SizedBox(height: 10),
            Wrap ( // find total + reformat
              alignment: WrapAlignment.spaceEvenly,
              spacing: 32,
              runSpacing: 64,
              children: [
                Container(
                  child: Text('Total:', style: const TextStyle(color: Colors.black, fontSize: 40))
                ),
                Container(
                  child: Text((total).toStringAsFixed(2), style: const TextStyle(color: Colors.black, fontSize: 40)),
                )
              ]
            ),
        ],
      ),
    )
  );
  }
}

class Tips {
  String subtotal, percentage, tip;
  String total = '0';
  double tipNum = 0;

  Tips(this.subtotal, this.percentage, this.tip) {
    tipNum = double.parse(tip);
    total = calculateTotal();
  }

  boolean error = false;
  if (double.tryParse(subtotal)==null || double.tryParse(percentage)==null || double.tryParse(tip)==null)
    boolean = true;

  String calculateTotal() {
    if (double.tryParse(subtotal) == null) {
      return 'ERROR'; // Handle error case appropriately
    } else {
      return (double.parse(subtotal) + tipNum).toString();
    }
  }

  @override
  String toString() {
    if (error = false) {
      return 'Percentage: $percentage, Tip: ${tipNum.toStringAsFixed(2)}, Subtotal: $subtotal, Total: ${total.toStringAsFixed(2)}';
    } else {
      return 'Percentage: ERROR, Tip: ERROR, Subtotal: ERROR, Total: ERROR';
    }
  }
}



