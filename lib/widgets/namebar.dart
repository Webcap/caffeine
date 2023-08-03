import 'package:flutter/material.dart';
import 'package:caffiene/utils/config.dart';

class Namebar extends StatelessWidget {
  const Namebar({Key? key, required this.namebar, required this.navigate})
      : super(key: key);

  final String namebar;
  final Widget navigate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            namebar,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w500,
              color: uppermodecolor,
            ),
          ),
        ),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => navigate),
              );
            },
            child: const Text(
              'see all',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500),
            )),
      ],
    );
  }
}
