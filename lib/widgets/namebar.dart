import 'package:flutter/material.dart';
import 'package:login/utils/config.dart';

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
              fontSize: 23,
              fontWeight: FontWeight.w300,
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
            child: Text(
              'see all',
              style: TextStyle(
                  fontSize: 20,
                  color: uppermodecolor,
                  fontWeight: FontWeight.w200),
            )),
      ],
    );
  }
}
