import 'package:flutter/material.dart';
import 'package:calculator_app/calcButton.dart';
import 'package:math_expressions/math_expressions.dart';

/*
need:
option for custom tip

formatting needed
  - subtotal 
    - needs to be placed in the top
    - contained needs to be used to thin out the box
  
  - tip
    - needs container to reformat

  - total
    - another container needed
    - round the subtotal + tip to the nearest dollar
*/


List<Tips> tipsList = [];
class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {

  final TextEditingController _expressionTEC = TextEditingController();

  String equation = "0";
  String result = "0";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  buttonPressed(String buttonText) {
    // used to check if the result contains a decimal
    if (buttonText == 'Custom') {

    }
    String doesContainDecimal(dynamic result) {
      if (result.toString().contains('.')) {
        List<String> splitDecimal = result.toString().split('.');
        if (!(int.parse(splitDecimal[1]) > 0)) {
          return result = splitDecimal[0].toString();
        }
      }
      return result;
    }

    setState(() {
      if (buttonText.contains('=')) {
        var _exp = _expressionTEC.text;
        expression = _exp + equation;
        expression = expression.replaceAll('15%', '*0.15');
        expression = expression.replaceAll('20%', '*0.2');
        expression = expression.replaceAll('25%', '*0.25');

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
      backgroundColor: Colors.grey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
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
            child: Text('Tip Calculator',style: TextStyle(color: Colors.white38)),
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
            TextField(
              controller: _expressionTEC, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // need to parse information from this
              scrollPadding: const EdgeInsets.all(0),
              decoration: 
                const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  hintText: 'Enter Subtotal',
                  border: OutlineInputBorder(),
                ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(result,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 80))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(equation,
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white38,
                              )),
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcButton('25%', Colors.white10, () => buttonPressed('25%')),
                calcButton('20%', Colors.white10, () => buttonPressed('20%')),
                calcButton("15%", Colors.white10, () => buttonPressed('15%')),
                
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _expressionTEC, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // need to parse information from this
              scrollPadding: const EdgeInsets.all(0),
              decoration: 
                const InputDecoration(
                  prefixIcon: Icon(Icons.percent),
                  hintText: 'Enter Custom Tip:',
                  border: OutlineInputBorder(),
                ),
            ),
            const SizedBox(height:10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcButton('=', Colors.orange, () => buttonPressed('=')),
                calcButton('Clear', Colors.orange, ()=>buttonPressed('Clear')),
              ],
            ),
            const SizedBox(height: 20),
            Row (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Text('Total:', style: const TextStyle(color: Colors.white, fontSize: 50))
                ),
                Container(
                  child: Text('0', style: const TextStyle(color: Colors.white, fontSize: 50))
                )
              ],
            )
        ],
      ),
    )
  );
  }
}

class Tips {
  String subtotal, percentage, tip;

  Tips(this.subtotal, this.percentage, this.tip);
  String getTotal() => subtotal + tip;
  String toString() => 'Percentage: $percentage, Tip: $tip, Subtotal: $subtotal';
}