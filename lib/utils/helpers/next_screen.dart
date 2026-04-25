import 'package:flutter/material.dart';

void nextScreen(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}
