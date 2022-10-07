import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Color(0xFF292837),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          )),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        InkWell(
          onTap: () {},
          child: Icon(
            Icons.home,
            size: 35,
            color: Colors.white,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Icon(
            Icons.category,
            size: 35,
            color: Colors.white,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Icon(
            Icons.favorite_border,
            size: 35,
            color: Colors.white,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Icon(
            Icons.download,
            size: 35,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}
