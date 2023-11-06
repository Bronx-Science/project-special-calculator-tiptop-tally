import 'package:flutter/material.dart';

Widget calcButton(
    String buttonText, Color buttonColor, void Function()? buttonPressed) {
  return Container(
    width: !buttonText.contains('%') ? 160:100,
    height: 50,
    padding: const EdgeInsets.all(0),
    child: ElevatedButton(
      onPressed: buttonPressed,
      style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
              borderRadius:BorderRadius.all(Radius.circular(20))),
          backgroundColor: buttonColor),
      child: Text(buttonText,
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
    ),
  );
}

