import 'package:flutter/material.dart';

void openSnackbar(BuildContext context, String snackMessage, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    action:
        SnackBarAction(label: "Ok", textColor: Colors.white, onPressed: () {}),
    content: Text(
      snackMessage,
      style: const TextStyle(fontSize: 14),
    ),
  ));
}
